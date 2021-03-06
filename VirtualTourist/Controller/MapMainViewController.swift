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
    
    private var selectedPinCoordinate: CLLocation?
    
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
    
    fileprivate func dropImageDownload(_ myPin: MKPointAnnotation, _ pin: Pin) {
        let locationToFetch = CLLocation(latitude: myPin.coordinate.latitude, longitude: myPin.coordinate.longitude)
        FlickrClient.getImageFromLocation(coordinate: locationToFetch) { (object, error) in
            guard let object = object else { return }
            for photo in object.photos.photo {
                FlickrClient.downloadImage(photo: photo) { (imageData) in
                    let saveToImage = ImageStore(context: DataController.shared.viewContext)
                    saveToImage.data = imageData
                    saveToImage.pin = pin
                    DataController.saveContext()
                }
            }
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
        
        // Added pins to MapView.
        mapView.addAnnotation(myPin)
        
        let pin = Pin(context: DataController.shared.viewContext)
        pin.lat = myPin.coordinate.latitude
        pin.long = myPin.coordinate.longitude
        pins.append(pin)
        DataController.saveContext()
        
        dropImageDownload(myPin, pin)
    }
        
    fileprivate func removePinInCoreData(_ view: MKAnnotation) {
        let pinLocationToRemove = view.coordinate
        
        for pin in pins
            where pinLocationToRemove.latitude == pin.lat && pinLocationToRemove.longitude == pin.long {
                //print("\(pinLocationToRemove.longitude) == \(pin.long)")
                DataController.shared.viewContext.delete(pin)
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
            
            for selectedPin in pins where selectedPin.lat == selectedPinCoordinate?.coordinate.latitude &&
                selectedPin.long == selectedPinCoordinate?.coordinate.longitude {
                    vc.pin = selectedPin
            }
        }
    }
    
}

//MARK: - Map Delegate
extension MapMainViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let lat = view.annotation?.coordinate.latitude,
            let long = view.annotation?.coordinate.longitude else {
                return
            }
            
            selectedPinCoordinate = CLLocation(latitude: lat, longitude: long)
            mapView.deselectAnnotation(view.annotation, animated: true)
            performSegue(withIdentifier: K.Segue.mapImageCollection, sender: nil)
        } else {
            guard let coordinate = view.annotation else { return }
            mapView.removeAnnotation(coordinate)
            removePinInCoreData(coordinate)
        }
    }
}
