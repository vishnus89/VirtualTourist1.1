//
//  VirtualTouristClient1.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/24/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation

class VirtualTouristClient1 {
    
    static let shared = VirtualTouristClient1()
    
    func searchByCoordinates(latitude: Double, longitude: Double, pageNumber: Int16, callback: @escaping (_ error: String?, _ response: [FlickrPhoto1]?, _ numberOfPages: Int16?) -> ()) {
        let methodParameters = [
            Constants1.FlickrParameterKeys.Method: Constants1.FlickrParameterValues.SearchMethod,
            Constants1.FlickrParameterKeys.APIKey: Constants1.FlickrParameterValues.APIKey,
            Constants1.FlickrParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            Constants1.FlickrParameterKeys.SafeSearch: Constants1.FlickrParameterValues.UseSafeSearch,
            Constants1.FlickrParameterKeys.Extras: Constants1.FlickrParameterValues.MediumURL,
            Constants1.FlickrParameterKeys.Format: Constants1.FlickrParameterValues.ResponseFormat,
            Constants1.FlickrParameterKeys.NoJSONCallback: Constants1.FlickrParameterValues.DisableJSONCallback,
            Constants1.FlickrParameterKeys.Page: String(pageNumber)
        ]
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLParameters(methodParameters as [String : AnyObject]))
        
        // create network request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                callback(error, nil, nil)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants1.FlickrResponseKeys.Status] as? String, stat == Constants1.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants1.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants1.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let numberOfPages = photosDictionary["pages"] as? Int16 else {
                return
            }
            
            guard let photos = photosDictionary[Constants1.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                return
            }
            
            callback(nil, self.getRandomFlickrPhotos(from: photos), numberOfPages)
        })
        
        // start the task!
        task.resume()
    }
    
    func getRandomFlickrPhotos(from photos: [[String: AnyObject]]) -> [FlickrPhoto1] {
        let startingPoint = Int(arc4random_uniform(UInt32(photos.count - Constants1.Flickr.NumberOfPhotosToSelect)))
        var currentPhotoNumber = 0
        var numberOfPhotosPicked = 0
        var finalPhotoArray = [FlickrPhoto1]()
        
        for photo in photos {
            if currentPhotoNumber >= startingPoint {
                if numberOfPhotosPicked < Constants1.Flickr.NumberOfPhotosToSelect {
                    if let photoId = photo[Constants1.FlickrResponseKeys.Id] as? String, let photoUrl = photo[Constants1.FlickrParameterValues.MediumURL] as? String {
                        
                        finalPhotoArray.append(FlickrPhoto1(id: photoId, url: photoUrl))
                        numberOfPhotosPicked += 1
                    }
                }
            }
            currentPhotoNumber += 1
        }
        return finalPhotoArray
    }

    
    
    fileprivate func bboxString(latitude: Double, longitude: Double) -> String {
        let minimumLongitude = max(longitude - Constants1.Flickr.SearchBBoxHalfWidth, Constants1.Flickr.SearchLonRange.0)
        let minimumLatitude = max(latitude - Constants1.Flickr.SearchBBoxHalfWidth, Constants1.Flickr.SearchLatRange.0)
        let maximumLongitude = min(longitude + Constants1.Flickr.SearchBBoxHalfWidth, Constants1.Flickr.SearchLonRange.1)
        let maximumLatitude = min(latitude + Constants1.Flickr.SearchBBoxHalfHeight, Constants1.Flickr.SearchLatRange.1)
        return "\(minimumLongitude),\(minimumLatitude),\(maximumLongitude),\(maximumLatitude)"
    }
    
    //MARK: Helper for creating a URL from parameters
    
    fileprivate func flickrURLParameters(_ parameters: [String:AnyObject]) -> URL {
    var components = URLComponents()
        components.scheme = Constants1.Flickr.APIScheme
        components.host = Constants1.Flickr.APIHost
        components.path = Constants1.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
        
        
            }
        }



