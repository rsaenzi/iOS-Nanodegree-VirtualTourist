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
    private let queue = DispatchQueue.global(qos: .default)
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "VirtualTourist")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("persistentContainer Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @discardableResult
    func saveChanges() -> Bool {
        
        let context = getContext()
        
        do {
            if context.hasChanges {
                try context.save()
                
            } else {
                print("saveChanges() No changes on Context are available to be saved")
            }
            return true
            
        } catch {
            let nserror = error as NSError
            
            print("saveChanges() Error when saving changes on context. More info below:")
            print("saveChanges() Unresolved error \(nserror), \(nserror.userInfo)")
            
            return false
        }
    }
}

// MARK: Pins
extension Storage {
    
    func savePin(latitude: Float, longitude: Float) {
        
        // We get a valid context
        let context = getContext()
        
        // Creates a new StoredPin inside the context
        let newPin = StoredPin(context: context)
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        // Finally we save any change on the context
        let status = saveChanges()
        if status {
            print("savePin() latitude:\(newPin.latitude) longitude:\(newPin.longitude) photos:\(newPin.photos?.count)")
        } else {
            print("savePin() Error when saving a new StoredPin object")
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
                print("getPin() latitude:\(item.latitude) longitude:\(item.longitude) photos:\(item.photos?.count)")
            }
        } catch {
            print("getPin() Error when fetching a specific StoredPin object")
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
            
            for item in allPins {
                print("getAllPins() latitude:\(item.latitude) longitude:\(item.longitude) photos:\(item.photos?.count)")
            }
        } catch {
            print("getAllPins() Error when fetching all StoredPin objects")
        }
        
        // Finally we return the fetched items in the required format
        return allPins
    }
}

// MARK: Photo Count
extension Storage {
    
    func setPhotoCount(latitude: Float, longitude: Float, photoCount: Int) {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("setPhotoCount() Error when fetching the pin to set its Photo Count")
            return
        }
        
        // Sets the value
        pin.photosCount = Int32(photoCount)
        
        // Finally we save any change on the context
        let status = saveChanges()
        if status {
            print("setPhotoCount() longitude:\(longitude) latitude:\(latitude) photoCount:\(photoCount)")
        } else {
            print("setPhotoCount() Error when saving a new StoredPin object")
        }
    }
    
    func getPhotoCount(latitude: Float, longitude: Float) -> Int? {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("setPhotoCount() Error when fetching the pin to set its Photo Count")
            return nil
        }
        
        return Int(pin.photosCount)
    }
}

// MARK: Photos
extension Storage {
    
    func save(photo: UIImage, index: Int, latitude: Float, longitude: Float) {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("savePhoto() Error when fetching the pin to store the image")
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
        let status = saveChanges()
        if status {
            print("savePhoto() index:\(index) longitude:\(longitude) latitude:\(latitude) image:\(photo)")
        } else {
            print("savePhoto() Error when saving a new StoredPin object")
        }
    }
    
    func getPhotos(latitude: Float, longitude: Float) -> [StoredPhoto] {
        
        // First we get a pin object
        guard let pin = self.getPin(latitude: latitude, longitude: longitude) else {
            print("getPhotos() Error when fetching the pin to get all its images")
            return []
        }
        
        guard let photoSet = pin.photos else {
            print("getPhotos() Error when converting unwrapping photos property")
            return []
        }
        
        var images = [StoredPhoto]()
        for item in photoSet {
            
            guard let storedPhoto = item as? StoredPhoto else {
                print("getPhotos() Error when converting photos property format from Set to StoredPhoto")
                break
            }
            images.append(storedPhoto)
        }
        
        return images
    }
}
