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
