//
//  UserConstants.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/21/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class UserConstants {
    static func isFirstLaunch() -> Bool {
        if UserDefaults.standard.object(forKey: "latitude") == nil || UserDefaults.standard.object(forKey: "longitude") == nil {
            return true
        }
        return false
    }
    
    static func save(coordinates: CLLocationCoordinate2D) {
        UserDefaults.standard.set(coordinates.latitude, forKey: "latitude")
        UserDefaults.standard.set(coordinates.latitude, forKey: "longitude")
    }
    
    static func savedCoordinates() -> CLLocationCoordinate2D {
        let latitude = UserDefaults.standard.value(forKey: "latitude")
        let longitude = UserDefaults.standard.value(forKey: "longitude")
        let coordinate = CLLocationCoordinate2DMake(latitude as! CLLocationDegrees, longitude as! CLLocationDegrees)
        return coordinate
    }
    
    static func save( latitudeD: Double, longitudeD: Double) {
        UserDefaults.standard.set(latitudeD, forKey: "latitudeD")
        UserDefaults.standard.set(longitudeD, forKey: "longitudeD")
    }
    
    static func getSavedLatitudeD() -> CLLocationDegrees {
        let delta = UserDefaults.standard.value(forKey: "latitudeD") as! Double
        return CLLocationDegrees(delta)
    }
    
    static func getSavedLongitudeD() -> CLLocationDegrees {
        let delta = UserDefaults.standard.value(forKey: "longitudeD") as! Double
        return CLLocationDegrees(delta)
    }
}
