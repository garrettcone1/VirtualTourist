//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 7/10/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var coreDataController: CoreDataStack!
    
    lazy var fetchedResultsController: NSFetchedResultsController <NSFetchRequestResult> = {
        
        // Get the stack
        let delgate = UIApplication.shared.delegate as! AppDelegate
        let stack = delgate.coreDataStack
        
        // Create a fetchRequest
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                                        NSSortDescriptor(key: "longitude", ascending: true)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        performUIUpdatesOnMain {
            self.loadMapDefaults()
        }
        
        self.mapView.delegate = self
        
        var objects: [Any]?
        
        do {
            try fetchedResultsController.performFetch()
            objects = (fetchedResultsController.sections?[0].objects)!
        } catch let error {
            print(error)
        }
        
        addAnnotationsToMapView(objects: objects)
    }
    
    @IBAction func addTappedPin(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let coreDataStack = delegate.coreDataStack
            //let backgroundContext = coreDataController.backgroundContext
            
            let pin = Pin(lat: coordinate.latitude, long: coordinate.longitude, isDownloaded: false, context: coreDataStack.context)
            //let objectIdPin = pin.objectID
            
            //backgroundContext.perform {
                
                //let backgroundPin = backgroundContext.object(with: objectIdPin) as! Pin
                
                //print(backgroundPin.photos!)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                // Add the pin to the map
                self.mapView.addAnnotation(annotation)
                
                if !pin.isDownloaded {
                    
                    FlickrClient.sharedInstance().getPhotosForPin(pin: pin)
                }
                
                coreDataStack.save()
            //}
        }
    }
    
    public func movePinToCollectionVC(pin: Pin) {
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "CollectionVC") as! CollectionViewController
        
        controller.pin = pin
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    public func addAnnotationsToMapView(objects: [Any]?) {
        
        if let objects = objects {
            
            for object in objects {
                
                guard let pin = object as? Pin else {
                    
                    return
                }
                
                let lat = CLLocationDegrees(pin.latitude)
                let long = CLLocationDegrees(pin.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    fileprivate func loadMapDefaults() {
        
        let span = MKCoordinateSpanMake(UserDefaults.standard.double(forKey: "latDeltaKey"), UserDefaults.standard.double(forKey: "longDeltaKey"))
        
        let location = CLLocationCoordinate2D(latitude: UserDefaults.standard.double(forKey: "latitudeKey"), longitude: UserDefaults.standard.double(forKey: "longitudeKey"))
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.mapView.setRegion(region, animated: true)
    }

}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let latitudePredicate = NSPredicate(format: "latitude == %lf", (view.annotation?.coordinate.latitude)!)
        let longitudePredicate = NSPredicate(format: "longitude == %lf", (view.annotation?.coordinate.longitude)!)
        let request = NSCompoundPredicate(type: .and, subpredicates: [latitudePredicate, longitudePredicate])
        
        fetchedResultsController.fetchRequest.predicate = request
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error {
            print(error)
        }
        
        let pin = fetchedResultsController.sections?[0].objects?[0] as! Pin
        
        movePinToCollectionVC(pin: pin)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "latitudeKey")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "longitudeKey")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "latDeltaKey")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey:"longDeltaKey")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func editButton(_ sender: Any) {
        
    }
    
}
