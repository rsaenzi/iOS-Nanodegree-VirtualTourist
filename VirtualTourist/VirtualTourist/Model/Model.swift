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
    
    func resetGallery() {
        
        // Clears any gallery info
        galleryInfo = []
        galleryImages = []
    }
    
    // Load info fetched from flickr
    func load(fetchedPhotos: [ApiPhoto]) {
        galleryInfo = fetchedPhotos
    }
    
    // Load persisted images from Core Data
    func load(persistedPhotos: [StoredPhoto], totalPhotoCount: Int) {

        let persistedImages = persistedPhotos.map({ storedPhoto -> (index: Int, icon: UIImage) in
            let imageData = storedPhoto.image
            let imageContent = UIImage(data: imageData!)
            return (index: Int(storedPhoto.index), icon: imageContent!)
        })
        
        galleryImages = [UIImage?](repeating: nil, count: totalPhotoCount)
        
        for singleImage in persistedImages {
            if singleImage.index < galleryImages.count {
                galleryImages[singleImage.index] = singleImage.icon
            }
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
        if index < galleryImages.count {
            return galleryImages[index]
        } else {
            return nil
        }
    }
    
    func set(photoImage: UIImage, at index: Int) {
        if index < galleryImages.count {
            galleryImages[index] = photoImage
        }
    }
    
    func deletePhoto(at index: Int) {
        if index < galleryInfo.count {
            galleryInfo.remove(at: index)
        }
        if index < galleryImages.count {
            galleryImages.remove(at: index)
        }
    }
}
