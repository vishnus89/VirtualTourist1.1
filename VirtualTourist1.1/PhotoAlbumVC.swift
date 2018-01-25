//
//  ViewController.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/12/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class PhotoAlbumVC: CoreDataCollectionVC {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        collectionView.delegate = self
        collectionView.dataSource = self
        updateItemSizeBasedOnOrientation()
    }
    
    func updateItemSizeBasedOnOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        let space: CGFloat = 3.0
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            width = (collectionView.frame.size.width - (2 * space)) / 3.0
            height = (collectionView.frame.size.height - (3 * space)) / 4.0
        } else if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            width = (collectionView.frame.size.width - (4 * space)) / 5.0
            height = (collectionView.frame.size.height - (2 * space)) / 3.0
        }
        if height > 0 && width > 0 {
            var itemSize: CGSize = CGSize()
            itemSize.height = height
            itemSize.width = width
            
            flowLayout.minimumInteritemSpacing = space
            flowLayout.itemSize = itemSize
        }
    }
    
    func subscribeToOrientationChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateItemSizeBasedOnOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func unsubscribeToOrientationChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func getNewCollection(_ sender: Any) {
        deleteAllPhotos { (result) in
            if result {
                self.getPinFromBackgroundContext { (result, pin) in
                    if let pin = pin {
                        DispatchQueue.main.async {
                            self.getNewPhotos(newPin: pin)
                        }
                    }
                }
            }
        }
    }
    
    func displayError(error: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error!", message: error, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension PhotoAlbumVC: MKMapViewDelegate {
    func setUpMapView() {
        mapView.delegate = self
        
        if let pin = pin {
            let pinCoordinates = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let region = MKCoordinateRegion(center: pinCoordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = pinCoordinates
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pin.animatesDrop = true
        return pin
    }
}

    
extension PhotoAlbumVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
        {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageViewCell1", for: indexPath) as! ImageViewCell1
        cell.image.image = nil
        
        let photo = fResultsController?.object(at: indexPath) as? Photo
        
        if let photo = photo {
            if photo.image == nil {
                cell.activityIndicate.startAnimating()
                DownloadService.shared.downloadImage(imagePath: photo.imageUrl!) { (data, error) in
                    if error != nil {
                        print(error!)
                    } else {
                        DispatchQueue.main.async {
                            photo.image = NSData(data: data!)
                            self.delegate.stack?.save()
                        }
                    }
                }
            } else {
                cell.image.image = UIImage(data: photo.image! as Data)
                cell.activityIndicate.stopAnimating()
            }
        }
        
        return cell
    }

}
    

extension PhotoAlbumVC {
    func deleteAllPhotos(callback: (_ result: Bool) -> Void) {
        let photos = pin?.photos
        if let photos = photos {
            for photo in photos {
                fResultsController?.managedObjectContext.delete(photo as! NSManagedObject)
            }
            delegate.stack?.save()
            callback(true)
        }
    }
    
    func getNewPhotos(newPin: Pin) {
        self.delegate.stack?.backgroundContext.perform {
            let pageChoosen = Int16(arc4random_uniform(UInt32((newPin.flickrPage))))
            DownloadService.shared.searchFlickrAndSavePhotos(pin: newPin, pageNumber: pageChoosen) { (error, result) in
                if result {
                    print("Flickr search finished.")
                } else {
                    if let error = error {
                        self.displayError(error: error)
                    }
                }
            }
        }
    }
    
    func getPinFromBackgroundContext(callback: @escaping (_ result: Bool, _ pin: Pin?) -> Void) {
        let latitude = pin!.latitude
        let longitude = pin!.longitude
        self.delegate.stack?.backgroundContext.perform {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                                  NSSortDescriptor(key: "longitude", ascending: true)]
            let latPred = NSPredicate(format: "latitude = %@", argumentArray: [latitude])
            let lonPred = NSPredicate(format: "longitude = %@", argumentArray: [longitude])
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [latPred, lonPred])
            fr.predicate = andPredicate
            let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (self.delegate.stack?.backgroundContext)!, sectionNameKeyPath: nil, cacheName: nil)
            
            do {
                try fc.performFetch()
            } catch {
                print("Error fetching Pin in background context.")
                callback(false, nil)
            }
            
            let selectedPin = fc.fetchedObjects?[0] as! Pin
            print("Found a saved pin. latitude = \(selectedPin.latitude), longitude = \(selectedPin.longitude)")
            callback(true, selectedPin)
        }
    }
}

