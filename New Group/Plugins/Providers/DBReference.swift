//
//  DBProvider.swift
//  Uber App For Riderr
//
//  Created by Artem Antuh on 8/27/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    //reference to Firebase DB
    var dbRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference {
        return dbRef.child(Constants.DRIVERS)
    }
    
    //request
    var requestRef: DatabaseReference{
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedref: DatabaseReference {
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    //request Accepted
    func saveUser(withID: String, email:String, paasword: String) {
        let data: Dictionary <String, Any> = [Constants.EMAIL : email,
                                              Constants.PASSWORD : paasword,
                                              Constants.isRider : true]//Key and value
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
    }
}
