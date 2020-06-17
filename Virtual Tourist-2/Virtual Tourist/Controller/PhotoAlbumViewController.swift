//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    internal var coordinate: CLLocationCoordinate2D!
    internal var dataController = DataController.shared
    internal var pin: Pin!
    internal var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
        
        setupCollectionViewLayout()
        
        setupFetchedResultsController()
        
        setupPhotos()
                
    }
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        setNewCollectionButton(enabled: false)
        
        fetchNewPhotos()
    }
    
    fileprivate func updatePlaceholderLabel() {
        noImagesLabel.isHidden = !isSavedPhotosEmpty()
    }
    
    fileprivate func isSavedPhotosEmpty() -> Bool {
        if let photos = fetchedResultsController.fetchedObjects, photos.count > 0 {
            return false
        }
        return true
    }
    
    fileprivate func setNewCollectionButton(enabled: Bool) {
        newCollectionButton.isEnabled = enabled
    }
    
    fileprivate func reloadData() {
        collectionView.reloadData()
    }
    
    fileprivate func save(imageUrl: URL) {
        let photoObject = Photo(context: dataController.viewContext)
        photoObject.creationDate = Date()
        photoObject.imageURL = imageUrl
        photoObject.pin = pin
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }
    
    fileprivate func setupFetchedResultsController() {
        
        // Fetch saved pins
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
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
    
    fileprivate func setupPhotos() {
        guard let photos = fetchedResultsController.fetchedObjects, photos.count == 0 else {
            return
        }
        
        setNewCollectionButton(enabled: false)
        
        fetchNewPhotos()
    }
    
    fileprivate func fetchNewPhotos() {
        // Fetch the images from the server
        UdacityClient.getPhotosList(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: handleFlickrResponse(response:error:))
    }
    
    fileprivate func handleFlickrResponse(response: FlickrPhotosResponse?, error: Error?) {
        
        activityIndicator.stopAnimating()
        
        if let response = response {
            // Save total pages
            UdacityClient.totalPages = response.photos.pages
            
            // Parse photos and save image url
            for photo in response.photos.photoList {
                save(imageUrl: photo.getImageUrl())
            }
            // Update placeholder label
            updatePlaceholderLabel()
            
            // Reload collection view
            reloadData()
        } else {
            setNewCollectionButton(enabled: true)
            updatePlaceholderLabel()
            Alert.show(on: self, message: error?.localizedDescription)
        }
    }
    
    fileprivate func setupMap() {
        // Update region
        let regionRadius: CLLocationDistance = 2000
        let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func setupCollectionViewLayout() {
        let numberOfColumns: CGFloat = 3.0
        let dimension = (view.frame.size.width - ((numberOfColumns - 1) * numberOfColumns)) / numberOfColumns
        flowLayout.minimumInteritemSpacing = numberOfColumns
        flowLayout.minimumLineSpacing = numberOfColumns
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}

// MARK: Collection View Datasource
extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifer", for: indexPath) as! PhotoCollectionViewCell
        
        let photoObject = fetchedResultsController.object(at: indexPath)
        
        if let imageData = photoObject.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        } else {
            if let url = photoObject.imageURL {
                UdacityClient.downloadImage(url: url) { (data, error) in
                    guard let data = data else {
                        return
                    }
                    // Save image data
                    photoObject.imageData = data
                    try? self.dataController.viewContext.save()
                    cell.imageView?.image = UIImage(data: data)
                    cell.setNeedsLayout()
                }
            }
        }
        return cell
    }
}

// MARK: Collection View Delegate
extension PhotoAlbumViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        guard photoToDelete.imageData != nil else { return }
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
    }
}

// MARK: Fetched Result Delegate
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatePlaceholderLabel()
        guard
            let downloadedImageList = fetchedResultsController.fetchedObjects?.filter({ $0.imageData != nil}),
            let totalImageList = fetchedResultsController.fetchedObjects,
            downloadedImageList.count == totalImageList.count
            else {
                print("Still downloading images")
                return
        }
        print("All images downloaded")
        setNewCollectionButton(enabled: true)
    }
}
