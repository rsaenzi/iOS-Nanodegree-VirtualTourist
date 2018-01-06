//
//  Model.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit

typealias GalleryItem = (image: UIImage?, status: DownloadStatus)

class Model {
    
    static let shared = Model()
    
    // Photo URL (and other info) for selected annotation point
    private var galleryInfo = [ApiPhoto]()
    
    // Photo files for selected annotation point
    private var galleryImages = [GalleryItem]()
    
    // Indicates if this is the first time this pin is tapped
    var pinHasStoredPhotos = false
}

// MARK: Case 1: When user taps the pin for the first time,
//       images are fetched from Flickr and stored in Core Data
extension Model {
    
    // Load info fetched from flickr
    func load(fetchedInfo: [ApiPhoto]) {
        galleryInfo = fetchedInfo
        galleryImages = [GalleryItem](repeating: GalleryItem(image: nil, status: .notDownloaded), count: galleryInfo.count)
    }
    
    func save(photoImage: UIImage, at index: Int) {
        if index < galleryImages.count {
            galleryImages[index] = GalleryItem(image: photoImage, status: .downloadFinished)
        }
    }
    
    func getPhotoInfo(from index: Int) -> ApiPhoto {
        if pinHasStoredPhotos == false {
            return galleryInfo[index]
        } else {
            fatalError("This should not happen")
        }
    }
    
    func setIsDownloadingStatus(at index: Int) {
        if index < galleryImages.count {
            galleryImages[index].status = DownloadStatus.isDownloading
        }
    }
}

// MARK: Case 2: When user taps the pin for the nth time,
//       image are loaded from Core Data
extension Model {
    
    // Load persisted images from Core Data
    func load(persistedPhotos: [StoredPhoto], totalPhotoCount: Int) {
        
        // Transform the storable model into the format required by this class
        let persistedImages = persistedPhotos.map({ storedPhoto -> (index: Int, icon: UIImage) in
            let imageData = storedPhoto.image
            let imageContent = UIImage(data: imageData!)
            return (index: Int(storedPhoto.index), icon: imageContent!)
        })
        
        // In this case, photo info is not required because
        // the images are not going to be downloaded, unless the user taps refresh button
        galleryInfo = []
        
        // Initialize the arrays
        galleryImages = [GalleryItem](repeating: GalleryItem(image: nil, status: .notDownloaded), count: persistedPhotos.count)
        
        // This keeps in the same order than when they were downloaded
        for singleImage in persistedImages {
            if singleImage.index < galleryImages.count {
                galleryImages[singleImage.index] = GalleryItem(image: singleImage.icon, status: .downloadFinished)
            }
        }
    }
}

// MARK: Collection View DataSource
extension Model {
    
    func getGalleryCount() -> Int {
        return galleryImages.count
    }
    
    func getPhotoImage(from index: Int) -> GalleryItem? {
        if index < galleryImages.count {
            return galleryImages[index]
        } else {
            return nil
        }
    }
}

// MARK: Objects deletion
extension Model {

    func resetGallery() {
        
        // Clears any gallery info
        galleryInfo = []
        galleryImages = []
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
