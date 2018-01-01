//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/30/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController {
    
    @IBOutlet private weak var map: MKMapView!
    @IBOutlet private weak var collectionAlbum: UICollectionView!
    @IBOutlet private weak var itemNewAlbum: UIBarButtonItem!
    @IBOutlet private weak var buttonClose: UIBarButtonItem!
    @IBOutlet private weak var waitingAlert: UIView!
    
    fileprivate let cellSize = UIScreen.main.bounds.width / 2
    var pinLocation: MKPointAnnotation?
    
    override func viewDidLoad() {
        
        // Add the selected pin to the map
        map.addAnnotation(pinLocation!)
        map.showAnnotations([pinLocation!], animated: false)
        
        // Ask core data if we have a photo count associated to this pin,
        // which means that this pin was tapped previously
        if let count = Storage.shared.getPhotoCount(
            latitude: Float(pinLocation!.coordinate.latitude),
            longitude: Float(pinLocation!.coordinate.longitude)), count > 0 {
            
            // Previous fetch, possible persisted images
            Model.shared.resetGallery(photoCount: count)
            
            // Fetch any saved photos from Core Data
            let persistedPhotos = Storage.shared.getPhotos(
                latitude: Float(pinLocation!.coordinate.latitude),
                longitude: Float(pinLocation!.coordinate.longitude))
            
            // Load the persisted images into the model
            Model.shared.load(persistedGalleryImages: persistedPhotos)
            collectionAlbum.reloadData()

        } else {
            
            // This is the first time we ask Flickr photos for this pinLocation
            Model.shared.resetGallery(photoCount: 0)
        }
        
        // Start a request to get photos info from Flickr
        fetchPhotosInfoFromFlicker()
    }
    
    @IBAction func onTapReload(_ sender: UIBarButtonItem) {
        fetchPhotosInfoFromFlicker()
    }
    
    private func fetchPhotosInfoFromFlicker() {
        
        // To prevent user to interrupt the image content fetching process
        enableControls(false)
        
        // Scrolls to the top
        collectionAlbum.setContentOffset(.zero, animated: true)
        
        RequestGetPhotos.get(location: pinLocation!.coordinate) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
                
            case .success(let studentResults):
                
                // Save the photo count for this pin location
                Storage.shared.setPhotoCount(
                    latitude: Float(self.pinLocation!.coordinate.latitude),
                    longitude: Float(self.pinLocation!.coordinate.longitude),
                    photoCount: studentResults.photos.photo.count)
                
                // Save the photo info array into the model
                Model.shared.load(galleryInfo: studentResults.photos.photo)
                
                // Shows the fetched images in the collectionView
                self.collectionAlbum.reloadData()
                self.enableControls(true)
                
            default:
                break
            }
        }
    }
    
    private func enableControls(_ enable: Bool) {
        itemNewAlbum.isEnabled = enable
        buttonClose.isEnabled = enable
        waitingAlert.isHidden = enable
    }
    
    @IBAction func onTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

extension PhotoAlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.shared.getGalleryCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the cell
        let cell: PhotoAlbumCell = collectionView.dequeue(indexPath)
        
        // If the image was previously downloaded or fetched from Core Data...
        if let imageContent = Model.shared.getPhotoImage(from: indexPath.row) {
            cell.imagePhoto.image = imageContent
            cell.loadingIndicator.isHidden = true
            cell.loadingIndicator.stopAnimating()
            
        } else {
            // While the image is being downloaded, we display an activity indicator
            cell.imagePhoto.image = nil
            cell.loadingIndicator.isHidden = false
            cell.loadingIndicator.startAnimating()
            
            // Starts downloading the image content
            let photoInfo = Model.shared.getPhotoInfo(from: indexPath.row)
            fetchImage(from: photoInfo, for: cell, at: indexPath.row)
        }
        
        return cell
    }
}

extension PhotoAlbumVC {
    
    private func fetchImage(from photoInfo: ApiPhoto, for cell: PhotoAlbumCell, at index: Int) {
        
        // In a background queue we fetch the image
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let `self` = self else { return }
            
            // Download the image file
            guard let imageUrl = URL(string: photoInfo.url),
                  let imageData = try? Data(contentsOf: imageUrl),
                  let imageContent = UIImage(data: imageData) else {
                return
            }
            
            // Saves the image file in the model
            Model.shared.set(photoImage: imageContent, at: index)
            
            // When the download completes, we load the image in the main queue
            DispatchQueue.main.async {
                
                // Saves the images content to Core Data
                Storage.shared.save(photo: imageContent, index: index,
                                    latitude: Float(self.pinLocation!.coordinate.latitude),
                                    longitude: Float(self.pinLocation!.coordinate.longitude))
                
                cell.imagePhoto.image = imageContent
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
        }
    }
}

extension PhotoAlbumVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Deletes the image from the model
        Model.shared.deletePhoto(at: indexPath.row)
        
        // Deletes the image from the collection view
        collectionView.deleteItems(at: [indexPath])
        
        // TODO Deletes the image from Core Data
    }
}

extension PhotoAlbumVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PhotoAlbumVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Shows a Pin on the map, for every single annotation
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = #colorLiteral(red: 0.003010978457, green: 0.7032318711, blue: 0.895259738, alpha: 1)
            pinView?.animatesDrop = false
        }
        
        pinView?.annotation = annotation
        return pinView
    }
}
