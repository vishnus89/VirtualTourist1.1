//
//  Photo1-CoreData.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/19/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo1");
        
    }
    @NSManaged public var image: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var pin: Pin?
    
}
