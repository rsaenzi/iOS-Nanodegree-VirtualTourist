//
//  ResponseGetPhotos.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

// MARK: JSON Response Objects
struct ResponseGetPhotos: Codable {
    let stat: String
    let photos: ResponsePhotosArray
}

struct ResponsePhotosArray: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}
