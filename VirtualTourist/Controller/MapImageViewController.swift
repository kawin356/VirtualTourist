//
//  MapImageViewController.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import MapKit
import UIKit
import CoreData

class MapImageViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet weak var removeBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // prepare Segue
    var coordinate: CLLocation!
    var pin: Pin!
    //fetch
    private var photos: [Photo] = []
    //Coredata
    private var ImageFromCoreData: [ImageStore] = []
    
    
    private var numberPageFetch: Int = 1
    private var isCoreDataHave: Bool = false
    private var selectedPhotos: [ImageStore] = [] {
        didSet {
            if selectedPhotos.count > 0 {
                removeBarButton.isEnabled = true
            } else {
                removeBarButton.isEnabled = false
            }
        }
    }
    
    fileprivate func taskLoadImageFromCoreData() {
        let fetchRequest:NSFetchRequest<ImageStore> = ImageStore.fetchRequest()
        let predict = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predict
        
        do {
            ImageFromCoreData = try DataController.shared.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if ImageFromCoreData.count > 0 {
            isCoreDataHave = true
        } else {
            isCoreDataHave = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        setupUI()
        taskLoadImageFromCoreData()
        FlickrClient.getImageFromLocation(coordinate: coordinate, completion: handlerGetImage(flickrMain:error:))
    }

//MARK: - Helper
    
    fileprivate func addCurrentPin() {
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = CLLocationCoordinate2D(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        mapView.addAnnotation(myPin)
    }
    
    fileprivate func setupUI() {
        collectionView.allowsMultipleSelection = true
        removeBarButton.isEnabled = false
        mapView.centerToLocation(coordinate)
        addCurrentPin()
    }
    
    private func handlerGetImage(flickrMain:FlickrMain?, error: Error?) {
        guard let flickrMain = flickrMain else {
            return
        }
        self.photos = flickrMain.photos.photo
        numberPageFetch = flickrMain.photos.pages
        checkCountPhoto()
        collectionView.reloadData()
        activityIndicator.stopAnimating()
    }
    
    private func checkCountPhoto() {
        if photos.count == 0 {
            let alertController = UIAlertController(title: "No Photo", message: "Try again!", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            show(alertController, sender: nil)
        }
    }
    
    //reset all
    fileprivate func clearAllData() {
        removeBarButton.isEnabled = false
        for delete in ImageFromCoreData {
            DataController.shared.viewContext.delete(delete)
        }
        DataController.saveContext()
        photos = []
        ImageFromCoreData = []
        collectionView.reloadData()
        isCoreDataHave = false
    }
    
//MARK: - IBAction
    
    
    @IBAction func newCollectionBarButtonPressed(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        clearAllData()
        FlickrClient.getImageFromLocation(coordinate: coordinate, page: Int.random(in: 1...numberPageFetch), completion: handlerGetImage(flickrMain:error:))
    }
    
    @IBAction func removeImageBarButtonPressed(_ sender: UIBarButtonItem) {
        for image in ImageFromCoreData {
            for imageToDelete in selectedPhotos {
                if image == imageToDelete {
                    DataController.shared.viewContext.delete(image)
                }
            }
        }
        DataController.saveContext()
        
        for indexPath in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        
        isCoreDataHave = true
        taskLoadImageFromCoreData()
        collectionView.reloadData()
    }
}


extension MapImageViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}

//MARK: - UICollection
extension MapImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isCoreDataHave ? ImageFromCoreData.count : photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionView.mapImageReuseCell, for: indexPath) as? MapImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.activityIncicator.startAnimating()
        
        if isCoreDataHave {
            
            guard let data = ImageFromCoreData[indexPath.row].data  else {
                return UICollectionViewCell()
            }
            cell.configImage(image: UIImage(data: data) ?? UIImage())
            cell.activityIncicator.stopAnimating()
            
        } else {
            
            FlickrClient.downloadImage(photo: photos[indexPath.row]) { (photoData) in
                
                DispatchQueue.main.async {
                            cell.configImage(image: UIImage(data: photoData) ?? UIImage())
                    cell.activityIncicator.stopAnimating()
                }
                
                let saveImage = ImageStore(context: DataController.shared.viewContext)
                saveImage.data = photoData
                saveImage.pin = self.pin
                self.ImageFromCoreData.append(saveImage)
                DataController.saveContext()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        let photoPressed = ImageFromCoreData[indexPath.row]
        if let index = selectedPhotos.firstIndex(of: photoPressed) {
          selectedPhotos.remove(at: index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoPressed = ImageFromCoreData[indexPath.row]
        selectedPhotos.append(photoPressed)
    }
    
//MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size.width/3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
