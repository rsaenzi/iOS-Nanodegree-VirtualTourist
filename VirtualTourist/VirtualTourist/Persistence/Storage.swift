//
//  Storage.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import UIKit
import MapKit
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
    
    func savePin(at position: MKPointAnnotation) {
        
        // Gets the coordinates from the annotation point
        let latitude: Float = Float(position.coordinate.latitude)
        let longitude: Float = Float(position.coordinate.longitude)
        
        // We get a valid context
        let context = getContext()
        
        // Creates a new StoredPin inside the context
        let newPin = StoredPin(context: context)
        newPin.latitude = latitude
        newPin.longitude = longitude
        
        // Finally we save any change on the context
        let status = saveChanges()
        if status {
            print("savePin() latitude:\(newPin.latitude) longitude:\(newPin.longitude) photos:\(String(describing: newPin.photos?.count))")
        } else {
            print("savePin() Error when saving a new StoredPin object")
        }
    }
    
    func getPin(at position: MKPointAnnotation) -> StoredPin? {
        
        // Gets the coordinates from the annotation point
        let latitude: Float = Float(position.coordinate.latitude)
        let longitude: Float = Float(position.coordinate.longitude)
        
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
                print("getAllPins() latitude:\(item.latitude) longitude:\(item.longitude) photos:\(String(describing: item.photos?.count))")
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
    
    func setPhotoCount(at position: MKPointAnnotation, photoCount: Int) {
        
        // Gets the coordinates from the annotation point
        let latitude: Float = Float(position.coordinate.latitude)
        let longitude: Float = Float(position.coordinate.longitude)
        
        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
            print("setPhotoCount() Error when fetching the pin to set its Photo Count")
            return
        }
        
        // Sets the value
        pin.photosCount = Int32(photoCount)
        
        // Finally we save any change on the context
        let status = saveChanges()
        if status {
            print("setPhotoCount() longitude:\(longitude) latitude:\(latitude) photos:\(String(describing: pin.photos?.count))")
        } else {
            print("setPhotoCount() Error when saving a new photoCount value for a pin object")
        }
    }
    
    func getPhotoCount(at position: MKPointAnnotation) -> Int? {
        
        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
            print("getPhotoCount() Error when fetching the photoCount value of a pin object")
            return nil
        }
        
        return Int(pin.photosCount)
    }
}

// MARK: Photos
extension Storage {
    
    func save(photo: UIImage, index: Int, at position: MKPointAnnotation) {
        
        // Gets the coordinates from the annotation point
        let latitude: Float = Float(position.coordinate.latitude)
        let longitude: Float = Float(position.coordinate.longitude)
        
        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
            print("save(photo) Error when fetching the pin to store the photo")
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
            print("save(photo) index:\(index) longitude:\(longitude) latitude:\(latitude) photos:\(String(describing: pin.photos?.count))")
        } else {
            print("save(photo) Error when saving a new photo object on a pin")
        }
    }
    
    func deletePhoto(at position: MKPointAnnotation, index indexToDelete: Int) {

        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
            print("deletePhoto() Error when fetching the pin to store the image")
            return
        }
        
        // If pin has photos to delete
        if let photoSet = pin.photos, let pinPhotos = photoSet as? Set<StoredPhoto> {
        
            // Find the photo to delete
            let itemsToDelete = pinPhotos.filter({ itemToCheck -> Bool in
                return itemToCheck.index == indexToDelete
            })
            
            // Deletion is also done using the context
            let context = getContext()
            for item in itemsToDelete {
                context.delete(item)
            }
            
            // Remove the photo
            pin.removeFromPhotos(itemsToDelete as NSSet)
            
            // We save any change on the context
            let status = saveChanges()
            if status {
                print("deletePhoto() index:\(indexToDelete) photos:\(String(describing: pin.photos?.count))")
            } else {
                print("deletePhoto() Error when saving trying to delete a photo from a pin object")
            }

            // Here we update the indexes on the remaining photos
            let remainingPhotos = getPhotos(at: position)
                .sorted(by: { (photo1, photo2) -> Bool in
                    return photo1.index < photo2.index
                })
            
            var cumulativeIndex: Int32 = 0
            for item in remainingPhotos {
                
                if cumulativeIndex != item.index {
                    item.index = cumulativeIndex
                }
                cumulativeIndex += 1
            }
            
            // Finally we save any change on the context
            saveChanges()
        }
    }
    
    func getPhotos(at position: MKPointAnnotation) -> [StoredPhoto] {
        
        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
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
    
    func deleteAllPhotos(at position: MKPointAnnotation) {
        
        // Gets the coordinates from the annotation point
        let latitude: Float = Float(position.coordinate.latitude)
        let longitude: Float = Float(position.coordinate.longitude)
        
        // First we get a pin object
        guard let pin = self.getPin(at: position) else {
            print("deleteAllPhotos() Error when fetching the pin to delete all its images")
            return
        }
        
        print("deletePhoto() Items to delete:\(String(describing: pin.photos?.count))")
        
        if let allPhotos = pin.photos {
            
            // Deletion is also done using the context
            let context = getContext()
            for item in allPhotos {
                context.delete(item as! StoredPhoto)
            }
        
            // Remove all photos from pin object
            pin.removeFromPhotos(allPhotos)
            pin.photos = nil
        }
        
        // Finally we save any change on the context
        let status = saveChanges()
        if status {
            print("deleteAllPhotos() longitude:\(longitude) latitude:\(latitude) photos:\(String(describing: pin.photos?.count))")
        } else {
            print("deleteAllPhotos() Error when trying to delete all photos from a pin object")
        }
    }
}
