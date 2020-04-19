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
        for image in photos {
            print(image.title)
        }
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
