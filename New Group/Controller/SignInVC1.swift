//
//  SignInVC.swift
//  Uber App For Driver
//
//  Created by Artem Antuh on 8/9/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC1: UIViewController, SignInVC {
    
    private let DRIVER_SEGUE = "DriverVC";
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logIn(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.login(withEmail: emailTextField.text!,
                                        password: passwordTextField.text!,
                                        loginHandler: {(message) in
                                            
                                            if message != nil {
                                                self.alertTheUser(title: "Problem With Authentication",
                                                                  message: message!)
                                            }
                                            else
                                            {
                                                UberHandler.Instance.driver = self.emailTextField.text!
                                                
                                                self.emailTextField.text = ""
                                                self.passwordTextField.text = ""
                                                
                                                self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                                            }
            })
        }
        else
        {
            alertTheUser(title: "Email And Password Are Required",
                         message: "Please Enter Email And Password ")
        }
        
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating User", message: message!)
                }
                else
                {
                    UberHandler.Instance.driver = self.emailTextField.text!
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                }
            })
        }
        else
        {
            alertTheUser(title: "Email And Password Are Required",
                         message: "Please Enter Email And Password ")
        }
    }
    
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
