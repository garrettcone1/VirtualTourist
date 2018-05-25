//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 8/31/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    struct Constants {
        
        struct Flickr {
            
            static let APIScheme = "https://"
            static let APIHost = "api.flickr.com"
            static let APIPath = "/services/rest/"
            
            static let SearchLatRange = (-90.0, 90.0)
            static let SearchLongRange = (-180.0, 180.0)
            static let BBoxHalfWidth = 0.5
            static let BBoxHalfHeight = 0.5
        }
    
        struct FlickrParameterKeys {
        
            static let ApiKey = "api_key"
            static let Method = "method"
            static let Format = "format"
            static let Latitude = "lat"
            static let Longitude = "lon"
            static let NoJSONCallBack = "nojsoncallback"
            static let BBox = "bbox"
            static let PerPage = "per_page"
            static let Page = "page"
            static let Extras = "extras"
        }
    
        struct FlickrParameterValues {
            
            static let APIKey = "c0f2426a708d22d2e8b92f07625fdfcd"
            static let SecretKey = "aa6d38b15d64a18c"
            
            static let SearchMethod = "flickr.photos.search"
            static let JSONFormat = "json"
            static let DisableJSONCallback = "1"
            static let MediumURL = "url_m"
            static let PerPageLimit = 21
            
        }
        
        struct JSONResponseKeys {
        
            static let Status = "stat"
            static let Photo = "photo"
            static let Photos = "photos"
            static let Url = "url_m"
            static let Title = "title"
        }
    }
}
