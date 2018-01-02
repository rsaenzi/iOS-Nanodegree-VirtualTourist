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
    
    // Photo URL (and other info) for selected annotation point
    private var galleryInfo = [ApiPhoto]()
    
    // Photo files for selected annotation point
    private var galleryImages = [UIImage?]()
    
    func resetGallery(photoCount: Int) {
        
        // Clears any gallery info (fetched from flickr)
        galleryInfo = []
        
        // Inits an array of gallery images. If photoCount is greater that zero
        // means that a previous request to flickr was made, and some images are stored in Core Data
        galleryImages = [UIImage?](repeating: nil, count: photoCount)
    }
    
    // Load info fetched from flickr
    func load(galleryInfo: [ApiPhoto]) {
        self.galleryInfo = galleryInfo
        
        // If no previous request to Flickr was made...
        if galleryImages.count == 0 {
            galleryImages = [UIImage?](repeating: nil, count: galleryInfo.count)
        }
    }
    
    // Load persisted images from Core Data
    func load(persistedGalleryImages: [StoredPhoto]) {
        
        for persistedImage in persistedGalleryImages {
            
            guard let imageData = persistedImage.image,
                  let imageContent = UIImage(data: imageData) else {
                break
            }
            galleryImages[Int(persistedImage.index)] = imageContent
        }
    }
}

extension Model {
    
    func getGalleryCount() -> Int {
        return galleryInfo.count
    }
    
    func getPhotoInfo(from index: Int) -> ApiPhoto {
        return galleryInfo[index]
    }
    
    func getPhotoImage(from index: Int) -> UIImage? {
        return galleryImages[index]
    }
    
    func set(photoImage: UIImage, at index: Int) {
        galleryImages[index] = photoImage
    }
    
    func deletePhoto(at index: Int) {
        galleryInfo.remove(at: index)
        galleryImages.remove(at: index)
    }
}
