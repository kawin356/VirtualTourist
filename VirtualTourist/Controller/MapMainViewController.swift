//
//  MapMainViewController.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapMainViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    
    fileprivate func setCameraLocation() {
        let lat = CLLocationDegrees(exactly: 13.736717)
        let long = CLLocationDegrees(exactly: 100.523186)
        
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat!, long!)
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    fileprivate func reloadPin() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        do {
            pins = try DataController.shared.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for pin in pins {
            
            let myCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.long)
            
            let myPin: MKPointAnnotation = MKPointAnnotation()
            
            // Set the coordinates.
            myPin.coordinate = myCoordinate
            
            // Added pins to MapView.
            mapView.addAnnotation(myPin)
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCameraLocation()
        reloadPin()
    }
    
    fileprivate func pinOnSelectedLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        print("long Pressed")
        
        // Get the coordinates of the point you pressed long.
        let location = sender.location(in: mapView)
        
        // Convert location to CLLocationCoordinate2D.
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Generate pins.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        // Set the coordinates.
        myPin.coordinate = myCoordinate
        
        // Added pins to MapView.
        mapView.addAnnotation(myPin)
        
        let pin = Pin(context: DataController.shared.viewContext)
        pin.lat = myPin.coordinate.latitude
        pin.long = myPin.coordinate.longitude
//        DataController.saveContext()
        try? DataController.shared.viewContext.save()
    }
    
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        pinOnSelectedLocation(sender)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}
