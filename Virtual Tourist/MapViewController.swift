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

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.mapView.delegate = self
    }

    func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "CollectionController") as! UICollectionViewController
        
        //controller.setMapViewAnnotation(view.annotation!)
        self.present(controller, animated: true, completion: nil)
    }
}


