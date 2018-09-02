//
//  RiderVC.swift
//  Uber App For Rider
//
//  Created by Artem Antuh on 8/26/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
import MapKit

class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    func acceptUber(lat: Double, long: Double) {
    }
    
    func riderCanceledUber() {
    }
    
    func uberCanceled() {
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
    }
    
    func cancelUberForDriver() {
    }
    
    func uberAccepted(lat: Double, long: Double) {
    }
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var callUberBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        UberHandler.Instance.observeMessagesForRider()
        UberHandler.Instance.delegate = self
    }
    
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have coordinates from the manager
        if let location = locationManager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            //setting up navigation region
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            myMap.setRegion(region, animated: true)
            myMap.removeAnnotations(myMap.annotations)
            
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Drivers Loaction"
            myMap.addAnnotation(annotation)
        }
    }
    
    
    @objc func updateRidersLocation() {
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude,
                                                 long: userLocation!.longitude)
    }
    
    
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        }
        else
        {
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal) // setImage ????????????????????????????????????/
            canCallUber = true
            UberHandler.Instance.cancelUber()
        }
    }
    
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest {
            if requestAccepted {
                alertTheUser(title: "Uber Accepted", message: "\(driverName) accepted your request")
            }
            else
            {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertTheUser(title: "Uber canceled", message: "\(driverName) cancel Uber request")
            }
        }
        riderCanceledRequest = false
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    
    @IBAction func callUber(_ sender: UIButton) {
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude),
                                                 longitude: Double(userLocation!.longitude))
//                timer = Timer.scheduledTimer(timeInterval: 10,
//                                             target: self,
//                                             selector: #selector(RiderVC.updateRidersLocation),
//                                             userInfo: nil,
//                                             repeats: true)
            }
            else
            {
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                // cancel uber
            }
        }
    }
    
    
    @IBAction func logout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }
        else
        {
            //problem
            alertTheUser(title: "Could Not LogOut", message: "Try later")
        }
    }
    
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK",
                               style: .default,
                               handler: nil);
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    
}
