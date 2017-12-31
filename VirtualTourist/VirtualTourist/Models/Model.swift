//
//  Model.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit

class Model {
    
    static let shared = Model()
    
    private var photoGallery = [Photo]()
    private var photoGalleryContent = [UIImage?]()
    
    func set(gallery: [Photo]) {
        photoGallery = gallery
        photoGalleryContent = [UIImage?](repeating: nil, count: photoGallery.count)
    }
    
    func getPhotoCount() -> Int {
        return photoGallery.count
    }
    
    func getPhoto(at index: Int) -> Photo {
        return photoGallery[index]
    }
    
    func set(photoContent: UIImage, at index: Int) {
        photoGalleryContent[index] = photoContent
    }
    
    func getPhotoContent(at index: Int) -> UIImage? {
        return photoGalleryContent[index]
    }
}
