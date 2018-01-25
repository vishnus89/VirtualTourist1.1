//
//  Photo1.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/19/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import CoreData

public class Photo: NSManagedObject {
    convenience init(image1: NSData?, imageUrl1: String, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Photo1", in: context) {
            self.init(entity: entity, insertInto:context)
            self.image = image1
            self.imageUrl = imageUrl1
        } else {
            fatalError("No such Entity")
        }
    }
}
