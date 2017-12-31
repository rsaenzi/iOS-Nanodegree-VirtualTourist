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
        
        itemNewAlbum.isEnabled = false
        buttonClose.isEnabled = false
        waitingAlert.isHidden = false
        
        RequestGetPhotos.get(location: pinLocation!.coordinate) { [weak self] result in
            
            guard let `self` = self else {
                return
            }
        
            self.itemNewAlbum.isEnabled = true
            self.buttonClose.isEnabled = true
            self.waitingAlert.isHidden = true
        }
    }
    
    @IBAction func onTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: Temporal
    func pointIsPersisted() -> Bool {
        // TODO
        return false
    }
}

extension PhotoAlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PhotoAlbumCell = collectionView.dequeue(indexPath)
        return cell
    }
}

extension PhotoAlbumVC: UICollectionViewDelegate {
    
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
