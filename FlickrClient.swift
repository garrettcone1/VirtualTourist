//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 8/31/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    // Shared Session
    let session = URLSession.shared
    
    func taskForGETMethod(latitude: Double, longitude: Double, _ completionHandlerForGET: @escaping (_ success: Bool, _ data: [[String: AnyObject]]?, _ error: String?) -> Void) {
        
        let randomPageNumber = UInt64(arc4random_uniform(50) + 1)
        
        let methodParameters = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                                Constants.FlickrParameterKeys.ApiKey: Constants.FlickrParameterValues.APIKey,
                                Constants.FlickrParameterKeys.Latitude: latitude,
                                Constants.FlickrParameterKeys.Longitude: longitude,
                                Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.JSONFormat,
                                Constants.FlickrParameterKeys.NoJSONCallBack: Constants.FlickrParameterValues.DisableJSONCallback,
                                Constants.FlickrParameterKeys.BBox: createBBox(latitude: latitude, longitude: longitude),
                                Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
                                Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPageLimit,
                                Constants.FlickrParameterKeys.Page: randomPageNumber] as [String : Any]
        
        // Create URL from Flickr Constants
        let urlString = Constants.Flickr.APIScheme +
            Constants.Flickr.APIHost +
            Constants.Flickr.APIPath +
            escapedParameters(methodParameters as [String: AnyObject])
        
        let url = URL(string: urlString)!
        
        // Configure request with URL
        let request = NSMutableURLRequest(url: url)
        
        // Create task and make request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
            func sendError(error: String) {
                
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(false, nil, String(describing: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo)))
            }
            
            // Check if there was an error
            guard error == nil else {
                sendError(error: "There was an error with your request: \(String(describing: error?.localizedDescription))")
                return
            }
            
            // Check to see if we got a successful 2xx response
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Your request returned a status code other than 2xx!: \(String(describing: response))")
                return
            }
            
            // Check to see if there was any data returned
            guard let data = data else {
                sendError(error: "No data was returned by the request!")
                return
            }
            
            // Parse the JSON data
            var parsedResult: [String: AnyObject]! = nil
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
            } catch {
                print("Could not parse JSON data")
            }
            
            guard let photoDictionary = parsedResult[Constants.JSONResponseKeys.Photos] as? [String: AnyObject], let photoArray = photoDictionary[Constants.JSONResponseKeys.Photo] as? [[String: AnyObject]] else {
                return
            }
            
            completionHandlerForGET(true, photoArray, nil)
        }
        
        task.resume()
    }
    
    public func loadURLPhoto(imagePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
        
        let session = URLSession.shared
        let imageURL = URL(string: imagePath)
        let request = URLRequest(url: imageURL! as URL)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                completionHandler(nil, "Error downloading image: \(String(describing: error))")
                return
            }
            completionHandler(data, nil)
        }
        
        task.resume()
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
}

extension FlickrClient {
    
    public func escapedParameters(_ parameters: [String: AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
        
            for (key, value) in parameters {
            
                let stringValue = "\(value)"
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
        
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    public func createBBox(latitude: Double, longitude: Double) -> String {
        
        let longitudeMin = max(longitude - Constants.Flickr.BBoxHalfWidth, Constants.Flickr.SearchLongRange.0)
        let latitudeMin = max(latitude - Constants.Flickr.BBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
        let longitudeMax = min(longitude + Constants.Flickr.BBoxHalfWidth, Constants.Flickr.SearchLongRange.1)
        let latitudeMax = min(latitude + Constants.Flickr.BBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
        
        return "\(longitudeMin), \(latitudeMin), \(longitudeMax), \(latitudeMax)"
    }
}
