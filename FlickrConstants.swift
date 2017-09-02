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
        
        // API Key
        static let RestAPIKey: String = "c0f2426a708d22d2e8b92f07625fdfcd"
        
        // Secret Key
        static let SecretKey: String = "aa6d38b15d64a18c"
        
        // URLs
        static let BaseURL: String = "http://api.flickr.com/services/rest/"
        static let BaseURLSecure: String = "https://api.flickr.com/services/rest/"
        
        static let Format: String = "json"
        static let NoJsonCallback: String = "1"
        static let Extras: String = "url_m"
        static let PerPage: String = "20"
    }
    
    struct Methods {
        
        // Search photos by location
        static let PhotosSearch: String = "flickr.photos.search"
    }
    
    struct ParameterKeys {
        
        static let ApiKey = "api_key"
        
        static let Method = "method"
        static let Format = "format"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let PerPage = "per_page"
        static let Extras = "extras"
    }
    
    struct JSONResponseKeys {
        
        static let Photo = "photo"
        static let Photos = "photos"
        static let Url = "url_m"
        static let ID = "id"
    }
    
}
