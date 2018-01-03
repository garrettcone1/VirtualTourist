//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 9/28/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var photos: Photo?

}
