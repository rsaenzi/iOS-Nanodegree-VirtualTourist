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
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionAlbum: UICollectionView!
    @IBOutlet weak var itemNewAlbum: UIBarButtonItem!
    var pinLocation: MKPointAnnotation?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        RequestGetPhotos.get(latitude: 4.713781, longitude: -74.052767) { result in
        }
    }
    
    @IBAction func onTapClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func onTapReload(_ sender: UIBarButtonItem) {
        RequestGetPhotos.get(latitude: 4.713781, longitude: -74.052767) { result in
        }
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
    
}
