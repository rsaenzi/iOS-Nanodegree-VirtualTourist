//
//  TravelLocationsVC.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/30/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsVC: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        RequestGetPhotos.get(latitude: 4.713781, longitude: -74.052767) { result in
            
        }
    }
}

extension TravelLocationsVC: MKMapViewDelegate {
    
}
