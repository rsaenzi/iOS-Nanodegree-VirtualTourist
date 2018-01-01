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
    
    private var photoGallery = [ApiPhoto]()
    private var photoGalleryContent = [UIImage?]()
    
    func set(gallery: [ApiPhoto]) {
        photoGallery = gallery
        photoGalleryContent = [UIImage?](repeating: nil, count: photoGallery.count)
    }
    
    func getPhotoCount() -> Int {
        return photoGallery.count
    }
    
    func getPhoto(at index: Int) -> ApiPhoto {
        return photoGallery[index]
    }
    
    func getPhotoContent(at index: Int) -> UIImage? {
        return photoGalleryContent[index]
    }
    
    func deletePhoto(at index: Int) {
        photoGallery.remove(at: index)
        photoGalleryContent.remove(at: index)
    }
    
    func set(photoContent: UIImage, at index: Int) {
        photoGalleryContent[index] = photoContent
    }
    
    func fetchContent(from photoUrl: String, for cell: PhotoAlbumCell, at index: Int) {
        
        // In a background queue we fetch the image
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Download the image file
            guard let imageUrl = URL(string: photoUrl),
                let imageData = try? Data(contentsOf: imageUrl),
                let imageContent = UIImage(data: imageData) else {
                    return
            }
            
            // Saves the image file in the model
            Model.shared.set(photoContent: imageContent, at: index)
            
            // TODO Saves the images content to Core Data
            
            // When the download completes, we load the image in the main queue
            DispatchQueue.main.async {
                cell.imagePhoto.image = imageContent
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
        }
    }
}
