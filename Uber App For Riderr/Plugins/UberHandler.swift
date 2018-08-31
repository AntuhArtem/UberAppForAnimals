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
}

class UberHandler {
    private static let _instance = UberHandler()
    
    weak var delegate: UberController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    static var Instance: UberHandler {
        return _instance
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
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded)
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
        
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) {(snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name = self.driver {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
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
    
}
