//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AudioToolbox

class TravelLocationsMapViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
        
    // MARK: - Properties
    internal let dataController = DataController.shared
    internal var storedPins = [Pin]()
    internal var annotations = [MKPointAnnotation]()
    internal var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add long press gestures
        addLongPressGestureOnMapView()
        
        // Setup fetched result view controller
        setupFetchedResultsController()
        
        // Add Annotation if available
        updateAnnotationsFromPersistant()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    fileprivate func setupFetchedResultsController() {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: dataController.viewContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add Annotation
    fileprivate func updateAnnotationsFromPersistant() {
        
        // Remove old annotations
        let oldAnnotations = mapView.annotations
        mapView.removeAnnotations(oldAnnotations)
        // Fetch saved pins

        guard let storedPins = fetchedResultsController.fetchedObjects else {
            return
        }
        
        self.storedPins = storedPins
                
        // Annotations from saved pins
        storedPins.forEach { pinModel in
            let coordinate = CLLocationCoordinate2D(latitude: pinModel.latitude, longitude: pinModel.longitude)
            annotations.append(createAnnotation(from: coordinate))
        }
        
        // Add annotations on mapview
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - Long Press Geature
    func addLongPressGestureOnMapView() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Find the coordinate
            let touchPoint = gesture.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            // Add annotation
            addAnnotation(to: coordinate)
            
        case .ended:
            
            // Vibrate the device for confirmation
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            
        default:
            break
        }
    }
    
    /// Add annotation to the provided coordinate.
    func addAnnotation(to coordinate: CLLocationCoordinate2D) {
        
        // Add annotation
        mapView.addAnnotation(createAnnotation(from: coordinate))
        
        // Save Pin
        let pinObject = Pin(context: dataController.viewContext)
        pinObject.latitude = coordinate.latitude
        pinObject.longitude = coordinate.longitude
        pinObject.creationDate = Date()

        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }
    
    func createAnnotation(from coordinate: CLLocationCoordinate2D) -> MKPointAnnotation {
        let annotation =  MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        guard let annotation = view.annotation as? MKPointAnnotation else { return }

        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let photoAlbumVC = storyboard?.instantiateViewController(identifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        let filteredPins = self.storedPins.filter { pin -> Bool in
            return pin.latitude == annotation.coordinate.latitude && pin.longitude == annotation.coordinate.longitude
        }
        
        if let selectedPin = filteredPins.first {
            photoAlbumVC.pin = selectedPin
        }
        
        photoAlbumVC.coordinate = view.annotation!.coordinate
        navigationController?.pushViewController(photoAlbumVC, animated: true)
        
    }
}


extension TravelLocationsMapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            storedPins = fetchedResultsController.fetchedObjects ?? storedPins
        case .delete:
            storedPins = fetchedResultsController.fetchedObjects ?? storedPins
            break
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}
