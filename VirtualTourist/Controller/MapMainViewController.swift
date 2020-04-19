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

class MapMainViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var pins: [Pin] = []
    
    var selectedPinCoordinate: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCameraLocation()
        reloadPin()
    }
    
    fileprivate func setCameraLocation() {
        let lat = CLLocationDegrees(exactly: 13.736717)
        let long = CLLocationDegrees(exactly: 100.523186)
        
        let location = CLLocation(latitude: lat!, longitude: long!)
        mapView.centerToLocation(location, regionRadius: 10000)
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
    
//MARK: - Add Remove Pin
    fileprivate func pinOnSelectedLocation(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        
        // Get the coordinates of the point you pressed long.
        let location = sender.location(in: mapView)
        
        // Convert location to CLLocationCoordinate2D.
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Generate pins.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        // Set the coordinates.
        myPin.coordinate = myCoordinate
        
        myPin.title = "PIN"
        
        // Added pins to MapView.
        mapView.addAnnotation(myPin)
        
        let pin = Pin(context: DataController.shared.viewContext)
        pin.lat = myPin.coordinate.latitude
        pin.long = myPin.coordinate.longitude
        DataController.saveContext()
    }
    
    
    fileprivate func removePinInCoreData(_ view: MKAnnotation) {
        let pinLocationToRemove = view.coordinate
        
        for pin in pins {
            print("\(pinLocationToRemove.longitude) == \(pin.long)")
            
            if pinLocationToRemove.longitude == pin.long &&
                pinLocationToRemove.latitude == pin.lat {
                DataController.shared.viewContext.delete(pin)
            }
        }
        DataController.saveContext()
    }
    
//MARK: - IBAction
    @IBAction func longPressed(_ sender: UILongPressGestureRecognizer) {
        if segmentedControl.selectedSegmentIndex == 0 {
            pinOnSelectedLocation(sender)
        }
    }
    
//MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.mapImageCollection {
            let vc = segue.destination as! MapImageViewController
            vc.coordinate = selectedPinCoordinate
        }
    }
    
}

//MARK: - Map Delegate
extension MapMainViewController: MKMapViewDelegate {
    
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

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let lat = view.annotation?.coordinate.latitude,
            let long = view.annotation?.coordinate.longitude else {
                return
            }
            
            selectedPinCoordinate = CLLocation(latitude: lat, longitude: long)
            performSegue(withIdentifier: K.Segue.mapImageCollection, sender: nil)
        } else {
            guard let coordinate = view.annotation else { return }
            mapView.removeAnnotation(coordinate)
            removePinInCoreData(coordinate)
        }
    }
}
