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
        
        performUIUpdatesOnMain {
            FlickrClient.sharedInstance().taskForGETMethod(latitude: pin.latitude, longitude: pin.longitude) { (success, data, error) in
                
                if let data = data {
                    
                    for item in data {
                        
                        let imageUrl = item[Constants.FlickrParameterValues.MediumURL] as! String
                        
                        //let photo = Photo(imageData: nil, imageUrl: imageUrl, context:)
                    }
                }
            }
        }
    }
    
}
