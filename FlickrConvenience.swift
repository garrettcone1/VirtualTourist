//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 8/31/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    func getPhotosForPin(pin: Pin) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let coreDataStack = appDelegate.coreDataStack
        
        DispatchQueue.main.async {
            FlickrClient.sharedInstance().taskForGETMethod(latitude: pin.latitude, longitude: pin.longitude) { (success, data, error) in
                
                if let data = data {
                    
                    for item in data {
                        
                        let imageUrl = item[Constants.FlickrParameterValues.MediumURL] as! String
                        
                        let photo = Photo(imageData: nil, imageURL: imageUrl, context: coreDataStack.context)
                        
                        pin.addToPhotos(photo)
                        
                        coreDataStack.save()
                        
                    }
                }
                
                pin.isDownloaded = true
                
            }
        }
    }
}
