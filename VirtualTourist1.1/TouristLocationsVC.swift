//
//  TouristLocationsVC.swift
//  VirtualTourist1.1
//
//  Created by Vishnu Deep Samikeri on 6/20/17.
//  Copyright © 2017 Vishnu Deep Samikeri. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData
import CoreLocation

class TouristLocationsVC: UIViewController {
    
    
    @IBOutlet weak var mapView1: MKMapView!
    
    var gestureRecognizer1: UILongPressGestureRecognizer!
    var locationManager1 = CLLocationManager()
    var fRequest: NSFetchRequest<NSFetchRequestResult>!
    var fResultController: NSFetchedResultsController<NSFetchRequestResult>!
    let delegate1 = UIApplication.shared.delegate as! AppDelegate
    var isFirstLaunch: Bool!
    
    var storedPins = [Pin]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        isFirstLaunch = UserConstants.isFirstLaunch()
        fRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true), NSSortDescriptor(key: "longitude", ascending: true)]
        fResultController = NSFetchedResultsController(fetchRequest: fRequest, managedObjectContext: (delegate1.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
        
        if UserConstants.isFirstLaunch() {
            
            
        }
    }
    
    func mapView1(_ mapView1: MKMapView, regionDidChangeAnimated animated: Bool) {
        let latitudeDelta = mapView1.region.span.latitudeDelta
        let longitudeDelta = mapView1.region.span.longitudeDelta
        UserConstants.save(latitudeD: latitudeDelta, longitudeD: longitudeDelta)
        UserConstants.save(coordinates: mapView1.centerCoordinate)
    }
    
    func mapView1(_ mapView1: MKMapView, didSelect view: MKAnnotationView) {
        mapView1.deselectAnnotation(view.annotation, animated: true)
        
        searchPin(coordinates: (view.annotation?.coordinate)!) { (error, pin) -> Void in
            if let pin = pin {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]
                let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
                fetchRequest.predicate = predicate
                let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (self.delegate1.stack?.context)!, sectionNameKeyPath: nil, cacheName: nil)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumVC
                vc.pin = pin
                vc.fResultsController = fc
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "OK", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
                
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                print(error!)
            }
        }
        
        
    }
    func centerMapView(toCoordinate coordinate: CLLocationCoordinate2D, latitudeD: CLLocationDegrees, longitudeD: CLLocationDegrees) {
        let span = MKCoordinateSpanMake(latitudeD, longitudeD)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView1.setRegion(region, animated: true)

    }
}


extension TouristLocationsVC: CLLocationManagerDelegate {
    func setUpLocaitonManager() {
        locationManager1.requestAlwaysAuthorization()
        locationManager1.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager1.delegate = self
            locationManager1.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager1.startUpdatingLocation()
        }
    }



    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
        
        if isFirstLaunch == true {
            
            UserConstants.save(coordinates: locationValue)
            UserConstants.save(latitudeD: 0.005, longitudeD: 0.005)
            centerMapView(toCoordinate: locationValue, latitudeD: CLLocationDegrees(0.005), longitudeD: CLLocationDegrees(0.005))
            isFirstLaunch = false
            
        }
    }
}

extension TouristLocationsVC {
    func searchPin(coordinates: CLLocationCoordinate2D, callback: @escaping (_ error: String?, _ pin: Pin?) -> Void) {
        let latPred = NSPredicate(format: "latitude = %@", argumentArray: [coordinates.latitude])
        let lonPred = NSPredicate(format: "longitude = %@", argumentArray: [coordinates.longitude])
        let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [latPred, lonPred])
        fRequest.predicate = andPredicate
        
        performFetch()
        let selectedPin = fResultController?.fetchedObjects?[0] as! Pin
        print("Found a saved pin. latitude = \(selectedPin.latitude), longitude = \(selectedPin.longitude)")
        callback(nil, selectedPin)
    }
    
    func performFetch() {
        do {
            try fResultController?.performFetch()
        } catch {
            print("Error fetching Pin")
        }
    }
    
}



