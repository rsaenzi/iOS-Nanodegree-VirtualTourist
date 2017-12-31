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
        
        if pointIsPersisted() {
            // TODO Get the saved photos from Core Data
            
        } else {
            
            // Start a request to get photos from Flickr
            fetchFhotos()
        }
    }
    
    @IBAction func onTapReload(_ sender: UIBarButtonItem) {
        fetchFhotos()
    }
    
    private func fetchFhotos() {
        
        enableControls(false)
        
        RequestGetPhotos.get(location: pinLocation!.coordinate) { [weak self] result in
            
            guard let `self` = self else {
                return
            }
            
            switch result {
                
            case .success(let studentResults):
                Model.shared.set(gallery: studentResults.photos.photo)
                
            default:
                Model.shared.set(gallery: [])
            }
            
            // Shows the fetched images in the collectionView
            self.collectionAlbum.reloadData()
            self.enableControls(true)
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
    
    // MARK: Temporal
    func pointIsPersisted() -> Bool {
        // TODO Here we fill the Model cache
        return false
    }
}

extension PhotoAlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Model.shared.getPhotoCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the cell
        let cell: PhotoAlbumCell = collectionView.dequeue(indexPath)
        
        // If the image was previously downloaded or fetched from Core Data...
        if let imageContent = Model.shared.getPhotoContent(at: indexPath.row) {
            cell.imagePhoto.image = imageContent
            cell.loadingIndicator.isHidden = true
            cell.loadingIndicator.stopAnimating()
            
        } else {
            // While the image is being downloaded, we display an activity indicator
            cell.imagePhoto.image = nil
            cell.loadingIndicator.isHidden = false
            cell.loadingIndicator.startAnimating()
            
            // Starts downloading the image content
            let photo = Model.shared.getPhoto(at: indexPath.row)
            fetchContent(from: photo.url, for: cell, at: indexPath.row)
        }
        
        return cell
    }
    
    private func fetchContent(from photoUrl: String, for cell: PhotoAlbumCell, at index: Int) {
        
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
            
            // When the download completes, we load the image in the main queue
            DispatchQueue.main.async {
                cell.imagePhoto.image = imageContent
                cell.loadingIndicator.isHidden = true
                cell.loadingIndicator.stopAnimating()
            }
        }
    }
}

extension PhotoAlbumVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Photo Selected")
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
