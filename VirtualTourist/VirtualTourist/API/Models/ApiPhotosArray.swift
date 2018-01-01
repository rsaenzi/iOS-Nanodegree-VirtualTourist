//
//  ApiPhotosArray.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

struct ApiPhotosArray: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [ApiPhoto]
}
