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
    var coordinate: CLLocation!
    @IBOutlet weak var newCollectionBarButton: UIBarButtonItem!
    @IBOutlet weak var removeBarButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var photos: [Photo]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.centerToLocation(coordinate)
        
        let myPin: MKPointAnnotation = MKPointAnnotation()
        myPin.coordinate = CLLocationCoordinate2D(latitude: coordinate.coordinate.latitude, longitude: coordinate.coordinate.longitude)
        mapView.addAnnotation(myPin)
        
        FlickrClient.getImageFromLocation(coordinate: coordinate, completion: handlerGetImage(photos:error:))
    }
    
    func handlerGetImage(photos:[Photo]?, error: Error?) {
        guard let photos = photos else {
            return
        }
        self.photos = photos
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

extension MapImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = photos?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.CollectionView.mapImageReuseCell, for: indexPath) as? MapImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.activityIncicator.startAnimating()
        FlickrClient.downloadImage(photo: (photos?[indexPath.row])!) { (photoData) in
            DispatchQueue.main.async {
                        cell.configImage(image: UIImage(data: photoData) ?? UIImage())
                cell.activityIncicator.stopAnimating()
            }
        }
        
        return cell    }
    
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
