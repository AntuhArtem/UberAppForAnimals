//
//  UberHandler.swift
//  Uber App For Riderr
//
//  Created by Artem Antuh on 8/28/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func canCallUber(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriversLocation(lat: Double, long: Double)
    func acceptUber(lat: Double, long: Double)
    func riderCanceledUber()
    func uberCanceled()
    func updateRidersLocation(lat: Double, long: Double)
    func cancelUberForDriver()
    func uberAccepted(lat: Double, long: Double)
}

class UberHandler {
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    var driver_id = ""
    
    static var Instance: UberHandler {
        return _instance
    }
    
    
    func uberAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME : driver,
                                             Constants.LATITUDE: lat,
                                             Constants.LONGITUDE: long]
        DBProvider.Instance.requestAcceptedref.childByAutoId().setValue(data)
    }
    
    
    func cancelUberForDriver() {
        DBProvider.Instance.requestAcceptedref.child(driver_id).removeValue()
    }
    
    
    func updateDriverLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedref.child(driver_id).updateChildValues([Constants.LATITUDE: lat,
                                                                                   Constants.LONGITUDE: long])
    }
    
    
    func observeMessagesForRider() {
        
        //rider requested Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: true)
                        print("The value is \(self.rider_id)")
                    }
                }
            }
        }
        //canceled Uber
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        //                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childAdded)
        {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.driver == "" {
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
                    }
                }
            }
        }
        
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
            
        }
        
        //driver updating location
        DBProvider.Instance.requestAcceptedref.observe(DataEventType.childChanged){(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateDriversLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    
    func observeMessagesForDriver() {
        // rider requested uber
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) {(snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        
                        //inform driver about request
                        self.delegate?.acceptUber(lat: latitude,
                                                  long: longitude)
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.rider = name
                }
            }
            
            
            //rider canceled uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) {(DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider =  ""
                            self.delegate?.riderCanceledUber()
                        }
                    }
                }
            }
            
            
            //rider updating location
            DBProvider.Instance.requestRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let lat = data[Constants.LATITUDE] as? Double {
                        if let long = data[Constants.LONGITUDE] as? Double {
                            self.delegate?.updateRidersLocation(lat: lat, long: long)
                        }
                    }
                }
            }
            
            //driver accepts uber
            DBProvider.Instance.requestAcceptedref.observe(DataEventType.childAdded) { (DataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.driver {
                            self.driver_id = snapshot.key
                        }
                    }
                }
            }
            //observe messages
           
            
            //driver canceled uber
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.driver {
                            self.delegate?.uberCanceled()
                        }
                    }
                }
            }
        }
    }
    
    
    //request Uber
    func requestUber(latitude: Double,
                     longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: rider,
                                             Constants.LATITUDE: latitude,
                                             Constants.LONGITUDE: longitude]
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelUber() {
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat,
                                                                          Constants.LONGITUDE: long])
        
    }
    
    
    
}
