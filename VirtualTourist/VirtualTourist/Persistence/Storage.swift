//
//  Storage.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit
import CoreData

class Storage {
    
    static let shared = Storage()
    
    func savePin(latitude: Float, longitude: Float) {
        
        // We get a valid context
        let context = getContext()
        
        // Creates a new StoredPin inside the context
        let newPin = StoredPin(context: context)
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        // Finally we save any change on the context
        do {
            if context.hasChanges {
                try context.save()
                print("Saved = latitude:\(newPin.latitude) longitude:\(newPin.longitude) photos:\(newPin.photos?.count)")
            }
        } catch {
            print("Error when saving a new StoredPin object")
        }
    }
    
    func getPin(latitude: Float, longitude: Float) -> StoredPin? {
        
        // We get a valid context
        let context = getContext()

        // Then we create the query to exceute
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StoredPin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "latitude = %f AND longitude = %f", latitude, longitude)
        fetchRequest.returnsObjectsAsFaults = false

        // Here we try to fetch the items executing the query
        var results: [NSFetchRequestResult]
        var selectedPin: StoredPin? = nil

        do {
            results = try context.fetch(fetchRequest)
            
            if let first = results.first, let item = first as? StoredPin {
                selectedPin = item
                print("Selection = latitude:\(item.latitude) longitude:\(item.longitude) photos:\(item.photos?.count)")
            }
            
        } catch {
            print("Error when fetching a specific StoredPin object")
        }

        // Finally we return the fetched item
        return selectedPin
    }
    
    func getAllPins() -> [StoredPin] {
        
        // We get a valid context
        let context = getContext()
        
        // Then we create the query to exceute
        let fetchRequest: NSFetchRequest<StoredPin> = StoredPin.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        // Here we try to fetch the items executing the query
        var allPins = [StoredPin]()
        
        do {
            allPins = try context.fetch(fetchRequest)
            
            // TODO Debug
            for item in allPins {
                print("SavedItem = latitude:\(item.latitude) longitude:\(item.longitude) photos:\(item.photos?.count)")
            }
            
        } catch {
            print("Error when fetching all StoredPin objects")
        }
        
        // Finally we return the fetched items in the required format
        return allPins
    }
    
    func save(photo: UIImage, index: Int, latitude: Float, longitude: Float) {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("Error when fetching the pin to store the image")
            return
        }
        
        // We get a valid context
        let context = getContext()
        
        // Creates a new StoredPhoto inside the context
        let newPhoto = StoredPhoto(context: context)
        newPhoto.index = Int32(index)
        newPhoto.image = UIImagePNGRepresentation(photo)
        newPhoto.parentPin = pin
        
        // Adds the photo to pin
        pin.addToPhotos(newPhoto)
        
        // Finally we save any change on the context
        do {
            if context.hasChanges {
                try context.save()
                print("Photo = index:\(index) longitude:\(longitude) latitude:\(latitude) image:\(photo)")
            }
        } catch {
            print("Error when saving a new StoredPin object")
        }
    }
    
    func getPhotos(latitude: Float, longitude: Float) -> [UIImage] {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("Error when fetching the pin to get all its images")
            return []
        }
        
        guard let photos = pin.photos else {
            print("Error when converting unwrapping photos property")
            return []
        }
        
        var images = [UIImage]()
        for item in photos {
            
            guard let storedPhoto = item as? StoredPhoto,
                  let photoData = storedPhoto.image,
                  let validImage = UIImage(data: photoData) else {
                    
                print("Error when converting photos property format from Set to StoredPhoto")
                break
            }
            images.append(validImage)
        }
        
        return images
    }
    
    private func getContext() -> NSManagedObjectContext {
        
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get a valid NSManagedObjectContext object from the AppDelegate")
        }
        return app.persistentContainer.viewContext
    }
}
