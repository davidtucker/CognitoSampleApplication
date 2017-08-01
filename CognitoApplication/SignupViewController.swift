//
//  SignupViewController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/1/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignupViewController : UIViewController {
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var user: AWSCognitoIdentityUser?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.submitButton.isEnabled = false
        self.firstName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.lastName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.email.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.password.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.confirmPassword.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    func inputDidChange(_ sender:AnyObject) {
        if(firstName.text == nil || lastName.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        if(email.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        if(password.text == nil || confirmPassword.text == nil) {
            self.submitButton.isEnabled = false
            return
        }
        self.submitButton.isEnabled = (password.text == confirmPassword.text)
    }
    
    @IBAction func signupPressed(_ sender: AnyObject) {
        let userPool = AppDelegate.defaultUserPool()
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: email.text!)
        let firstNameAttribute = AWSCognitoIdentityUserAttributeType(name: "given_name", value: firstName.text!)
        let lastNameAttribute = AWSCognitoIdentityUserAttributeType(name: "family_name", value: lastName.text!)
        userPool.signUp(UUID().uuidString, password: password.text!, userAttributes: [emailAttribute, firstNameAttribute, lastNameAttribute], validationData: nil)
        .continueWith { (response) -> Any? in
            if response.error != nil {
                let alert = UIAlertController(title: "Error", message: response.error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.user = response.result!.user
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "VerifySegue", sender: self)
                }
            }
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let verificationController = segue.destination as! VerificationViewController
        verificationController.user = self.user!
    }
    
}
