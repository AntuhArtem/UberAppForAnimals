//
//  DriverVC.swift
//  Uber App For Riderr
//
//  Created by Artem Antuh on 9/2/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
import MapKit

class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    func canCallUber(delegateCalled: Bool) {
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
    }
    
    func cancelUberForDriver() {
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
    }
    
    func uberAccepted(lat: Double, long: Double) {
    }
    
    
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var acceptUberBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var riderLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    private var acceptedUber = false
    private var driverCanceledUber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        
        UberHandler.Instance.delegate = self as UberController 
        UberHandler.Instance.observeMessagesForDriver()
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
            
            if riderLocation != nil {
                if acceptedUber {
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Riders location"
                    myMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Drivers Loaction"
            myMap.addAnnotation(annotation)
        }
        
    }
    func acceptUber(lat: Double, long: Double) {
        //        uberRequest(title: "Uber Request", message: "You have a request for an Uber for this location Lat: \(lat), Long: \(long)", requestAlive: true)
        if !acceptedUber {
            uberRequest(title: "Uber Request",
                        message: "You have a request for an Uber for this location Lat: \(lat), Long: \(long)",
                requestAlive: true)
        }
    }
    
    func riderCanceledUber() {
        if !driverCanceledUber {
            //cancel
            self.acceptedUber = false
            self.acceptUberBtn.isHidden = true
            uberRequest(title: "Uber canceled", message: "The rider has canceled the Uber", requestAlive: false)
        }
    }
    
    func uberCanceled() {
        acceptedUber = false
        acceptUberBtn.isHidden = true
        timer.invalidate()
        
    }
    
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @objc func updateDriversLocation() {
        UberHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber {
            driverCanceledUber = true
            acceptUberBtn.isHidden = true
            UberHandler.Instance.cancelUberForDriver()
            timer.invalidate()
        }
    }
    //
    
    
    @IBAction func logOut(_ sender: UIButton) {
        if AuthProvider.Instance.logOut() {
            if acceptedUber {
                acceptUberBtn.isHidden = true
                UberHandler.Instance.cancelUberForDriver()
                timer.invalidate()
            }
            dismiss(animated: true, completion: nil)
        }
        else
        {
            //problem
            uberRequest(title: "Could Not LogOut", message: "Try later", requestAlive: false)
        }
    }

    
    private func uberRequest(title: String,message: String,requestAlive: Bool) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert);
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: {(alertAction: UIAlertAction) in
                
                self.acceptedUber = true
                self.acceptUberBtn.isHidden = false
//                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                
                //inform we accepted uber
                UberHandler.Instance.uberAccepted(lat: Double((self.userLocation?.latitude)!),
                                                  long: Double((self.userLocation?.longitude)!))
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        }
        else
        {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        present(alert, animated: true, completion: nil)
    }
}
