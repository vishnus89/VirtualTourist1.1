//
//  Pin1.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/24/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    convenience init(latititude: Double, longitude: Double, flickrpage: Int16, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin1", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latititude
            self.longitude = longitude
            self.flickrPage = flickrpage
        } else {
            fatalError("Unable to find Entity name Pin!")
        }
        
    }
}
