//
//  Pin-CoreDataProperties.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/24/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    @nonobjc public class func fRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var flickrPage: Int16
    @NSManaged public var photos: NSSet?
}

extension Pin {
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
    
}
