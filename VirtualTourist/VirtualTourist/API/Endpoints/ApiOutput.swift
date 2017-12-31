//
//  ApiOutput.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import Foundation

// MARK: JSON Request Objects
struct ApiResponse: Codable {
    let stat: String
    let photos: ApiResponsePhotosArray
}

struct ApiResponsePhotosArray: Codable {
    let page: Int
    let pages: String
    let perpage: Int
    let total: String
    let photo: [ApiResponsePhoto]
}

struct ApiResponsePhoto: Codable {
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
