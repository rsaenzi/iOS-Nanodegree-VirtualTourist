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
    
    @IBOutlet private weak var map: MKMapView!
    
    override func viewDidLoad() {
        
        // Add the gesture to create map annotations
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 0
        gesture.minimumPressDuration = 0.35
        map.addGestureRecognizer(gesture)
        
        // Loads any persisted points
        let allPins = Storage.shared.getAllPins()
        if allPins.count > 0 {
            
            // Transform the points into a valid MKPointAnnotation objects
            let persistedAnnotations = allPins.map { pin -> MKPointAnnotation in
                let point = MKPointAnnotation()
                
                point.coordinate = CLLocationCoordinate2D(
                    latitude: CLLocationDegrees(pin.latitude),
                    longitude: CLLocationDegrees(pin.longitude))
                
                return point
            }
            
            // Add those to the map
            map.addAnnotations(persistedAnnotations)
            map.showAnnotations(persistedAnnotations, animated: true)
        }
    }
    
    @IBAction func onTapGallery(_ sender: UIBarButtonItem) {
        let screen: PhotoAlbumVC = loadViewController()
        present(screen, animated: true)
    }
    
    @objc func onLongTap(_ sender: UILongPressGestureRecognizer) {
        
        // This prevents to call this event twice
        if sender.state == .began {
            
            // Gets the coordinates from the long-press recognized gesture
            let coords = map.convert(sender.location(in: map), toCoordinateFrom: map)
            
            // Adds the location to map, to be rendered
            let newPin = MKPointAnnotation()
            newPin.coordinate = coords
            map.addAnnotation(newPin)
            
            // Save the pin on Core Data
            Storage.shared.savePin(latitude: Float(coords.latitude), longitude: Float(coords.longitude))
        }
    }
}

extension TravelLocationsVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Shows a Pin on the map, for every single annotation
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.pinTintColor = #colorLiteral(red: 0.003010978457, green: 0.7032318711, blue: 0.895259738, alpha: 1)
            pinView?.animatesDrop = true
        }
        
        pinView?.annotation = annotation
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Deselect the pin
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        // Show the Photo Album, using the select pin coordinate
        let screen: PhotoAlbumVC = loadViewController()
        screen.pinLocation = view.annotation as? MKPointAnnotation
        present(screen, animated: true)
    }
}
