//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Garrett Cone on 8/8/17.
//  Copyright © 2017 Garrett Cone. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var pin: Pin!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    fileprivate let numOfCellsPerRow: CGFloat = 3
    fileprivate let distanceForView = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var blankPhotoLabel = UILabel()
    
    lazy var fetchedResultsController: NSFetchedResultsController <Photo> = {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let coreDataStack = delegate.coreDataStack
        
        let fetchedRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Photo")
        fetchedRequest.sortDescriptors = []
        let predicate = NSPredicate(format: "pin = %@", self.pin)
        fetchedRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedRequest, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController as! NSFetchedResultsController<Photo>
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = true
        
        addPinToView()
        
        performUIUpdatesOnMain {
            self.blankPhotoLabel = self.blankPhotosLabel()
        }
        
        fetchPhotos()
        
        performUIUpdatesOnMain {
            self.collectionView.reloadData()
        }
        
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        collectionView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let observedObject = object as? UICollectionView, observedObject == collectionView {
            // The collection view is done loading
            performUIUpdatesOnMain {
                self.newCollectionButton.isEnabled = true
            }
        }
    }
    
    func fetchPhotos() {
        performUIUpdatesOnMain {
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                print("Unable to fetch Photos.")
            }
        }
    }
    
    public func addPinToView() {
        
        let lat = CLLocationDegrees(pin.latitude)
        let long = CLLocationDegrees(pin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    public func blankPhotosLabel() -> UILabel {
        
        let label = UILabel()
        label.text = "No photos were found for this location."
        label.isHidden = true
        label.frame = CGRect(x: self.view.frame.size.width / 10, y: self.view.frame.size.height / 2, width: 300, height: 50)
        
        self.view.addSubview(label)
        return label
    }
    
    public func deletePhotoCollection() {
        
        for collection in fetchedResultsController.fetchedObjects! {
            
            fetchedResultsController.managedObjectContext.delete(collection as NSManagedObject)
            do {
                try fetchedResultsController.managedObjectContext.save()
            } catch {
                print("An error occurred while saving")
            }
        }
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        
        deletePhotoCollection()
        pin.isDownloaded = false
        
        FlickrClient.sharedInstance().getPhotosForPin(pin: pin)

        pin.isDownloaded = true
        print(pin.isDownloaded)
        
        performUIUpdatesOnMain {
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let sections = fetchedResultsController.sections![section]
        
        if sections.numberOfObjects == 0 {
            
            performUIUpdatesOnMain {
                self.blankPhotoLabel.isHidden = false
            }
        } else {
            performUIUpdatesOnMain {
                self.blankPhotoLabel.isHidden = true
            }
        }
        
        return sections.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let coreDataStack = delegate.coreDataStack
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        if let imageData = photo.imageData {
            
            let image = UIImage(data: imageData as Data)
            
            performUIUpdatesOnMain {
                cell.placeHolderView.isHidden = true
                cell.photoImageView.image = image
            }
        } else {
            
            performUIUpdatesOnMain {
                self.newCollectionButton.isEnabled = false
                cell.activityIndicator.startAnimating()
                cell.placeHolderView.isHidden = false
            }
            
            FlickrClient.sharedInstance().loadURLPhoto(imagePath: photo.imageURL!) { (imageData, error) in
                
                guard error == nil else {
                    
                    print("An error occurred loading the photo from the URL: \(String(describing: error))"); return
                }
            
                photo.imageData = imageData as NSData?
                coreDataStack.save()
                
                performUIUpdatesOnMain {
                    
                    cell.activityIndicator.hidesWhenStopped = true
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        fetchedResultsController.managedObjectContext.delete(fetchedResultsController.object(at: indexPath) as NSManagedObject)
        
        do {
            try fetchedResultsController.managedObjectContext.save()
        } catch {
            print("An error occurred while saving the photos")
        }
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalDistances = distanceForView.left * (numOfCellsPerRow + 1)
        let width = view.frame.width - totalDistances
        let widthPerItem = width / numOfCellsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return distanceForView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return distanceForView.left
    }
}

extension CollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert: collectionView.insertItems(at: [newIndexPath!])
            
        case .delete: collectionView.deleteItems(at: [indexPath!])
            
        case .update: collectionView.reloadItems(at: [indexPath!])
            
        default:
            return
        }
    }
}
