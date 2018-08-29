//
//  SignInVC.swift
//  Uber App For Rider
//
//  Created by Artem Antuh on 8/9/18.
//  Copyright © 2018 Artem Antuh. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    private let RIDER_SEGUE = "RiderVC"
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //    @IBOutlet weak var emailTextField: UITextField!
    //    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUp(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating User", message: message!)
                }
                else
                {
                    UberHandler.Instance.rider = self.emailTextField.text!
                    
                    //if we logout, our text fields must be empty
                    self.emailTextField.text! = ""
                    self.passwordTextField.text! = ""
                    
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                }
            })
        }
        else
        {
            alertTheUser(title: "Email And Password Are Required",
                         message: "Please Enter Email And Password ")
        }
        
    }


    @IBAction func logIn(_ sender: Any) {
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
                                                self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
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
