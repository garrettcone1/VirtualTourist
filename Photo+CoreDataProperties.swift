//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 9/28/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var pin: Pin?

}
