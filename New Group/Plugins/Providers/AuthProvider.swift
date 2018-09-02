//
//  AuthProvider.swift
//  Uber App For Rider
//
//  Created by Artem Antuh on 8/20/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

typealias LoginHandler = (_ msg: String?) -> Void

struct LoginnErrorCode{
    static let INVALID_EMAIL = "Invalid Emai address, Please Provide A Real Email Address"
    static let WRONG_PASSWORD = "Wrong Password, Please Enter Correct Password"
    static let PROBLEM_CONNECTING = "Problem Connecting To DB, Try Later"
    static let USER_NOT_FOUND = "User Not Found, Please Register"
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use, Enter Another Email"
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long"
}

class AuthProvider {
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: {(user, error) in
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else
            {
                loginHandler?(nil)
            }
        })
    }
    
    
    //login function
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?) {
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: {(user, error) in
            
            if error != nil {
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            }
            else
            {
                if user?.user.uid != nil {
                    DBProvider.Instance.saveUser(withID: user!.user.uid, email: withEmail, paasword: password)
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        })
    }
    
    
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                return true
            }
            catch
            {
                return false
            }
        }
        return true
    }
    
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        if let errCode = AuthErrorCode(rawValue: err.code) {
            switch errCode {
                
            case .wrongPassword:
                loginHandler?(LoginnErrorCode.WRONG_PASSWORD);
                break;
            case .invalidEmail:
                loginHandler?(LoginnErrorCode.INVALID_EMAIL);
                break;
            case .userNotFound:
                loginHandler?(LoginnErrorCode.USER_NOT_FOUND);
                break;
            case .emailAlreadyInUse:
                loginHandler?(LoginnErrorCode.EMAIL_ALREADY_IN_USE);
                break;
            case .weakPassword:
                loginHandler?(LoginnErrorCode.WEAK_PASSWORD);
                break;
            default :
                loginHandler?(LoginnErrorCode.PROBLEM_CONNECTING);
                break;
            }
        }
    }
}

