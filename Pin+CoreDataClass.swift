//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 9/28/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    
    convenience init(lat: Double, long: Double, isDownloaded: Bool, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude = lat
            self.longitude = long
            self.isDownloaded = isDownloaded
        } else {
            fatalError("Unable to find entity name")
        }
    }
}
