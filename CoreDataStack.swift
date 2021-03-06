//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 9/28/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName) in the main bundle.")
            return nil
        }
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            
            print("Unable to create a model from \(modelURL)")
            return nil
        }
        
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (a private queue) and a child one (a main queue)
        // Create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder.")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject: AnyObject]?)
        } catch {
            print("Unable to add store at \(dbURL)")
        }
        
    }
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject: AnyObject]?) throws {
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
}

internal extension CoreDataStack {
    
    func deleteData() throws {
        // Delete all objects in the database to leave empty tables
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

extension CoreDataStack {
    
    typealias Batch = (_ workingContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            // Save this to the parent context
            do {
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

extension CoreDataStack {
    
    func save() {
        
        /* We call this synchronously, but it's a very fast
         operation (it doesn't hit the disk). We need to know when it ends
         so we can call the next save (on the persisting context). This last
         one might take some time and is done in a background queue
         */
        
        context.performAndWait() {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // Save in the background
                self.persistingContext.perform() {
                    
                    do {
                        try self.persistingContext.save()
                    } catch {
                        
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(_ secondsDelayed: Int) {
        
        if secondsDelayed > 0 {
            do {
                try self.context.save()
                print("Autosaving")
            } catch {
                print("Error while autosaving")
            }
            
            let nanoSecondsDelayed = UInt64(secondsDelayed) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(nanoSecondsDelayed)) / Double(NSEC_PER_SEC)
            
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(secondsDelayed)
            }
        }
    }
}
