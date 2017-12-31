//
//  ResponseGetPhotos.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import Foundation

// MARK: JSON Response Objects
struct ResponseGetPhotos: Codable {
    let stat: String
    let photos: ResponsePhotosArray
}

struct ResponsePhotosArray: Codable {
    let page: Int
    let pages: String
    let perpage: Int
    let total: String
    let photo: [ResponsePhoto]
}

struct ResponsePhoto: Codable {
    let id: String
    let title: String
    let url: String
    let height: String
    let width: String
    
    // MARK: Decoding & Encoding to JSON
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url = "url_m"
        case height = "height_m"
        case width = "width_m"
    }
}
