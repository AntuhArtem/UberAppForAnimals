//
//  UberHandler.swift
//  Uber App For Driver
//
//  Created by Artem Antuh on 8/29/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func acceptUber(lat: Double, long: Double)
    func riderCanceledUber()
    func uberCanceled()
    func updateRidersLocation(lat: Double, long: Double)
    func cancelUberForDriver()
    func updateDriverLocation(lat: Double, long: Double)
    func uberAccepted(lat: Double, long: Double)
}

class UberHandler {
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance: UberHandler {
        return _instance
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
    
    
    //observe messages
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
}

