//
//  ResponseGetPhotos.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

struct ResponseGetPhotos: Codable {
    let stat: String
    let photos: ApiPhotosArray
}
