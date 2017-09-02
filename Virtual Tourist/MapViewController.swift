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

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "CollectionController") as! UICollectionViewController
        
        //controller.setMapViewAnnotation(view.annotation!)
        self.present(controller, animated: true, completion: nil)
    }
}


