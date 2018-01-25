//
//  FlickrPhoto1.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/24/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation


struct FlickrPhoto1 {
    let photoId: String
    let photoUrl: String
    
    init(id: String, url: String) {
        self.photoId = id
        self.photoUrl = url
    }
}
