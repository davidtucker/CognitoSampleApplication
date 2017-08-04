//
//  SignupViewController.swift
//
//  Copyright (c) 2017 David Tucker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
    @IBOutlet weak var phoneNumber: UITextField!
    
    var user: AWSCognitoIdentityUser?
    var codeDeliveryDetails:AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.submitButton.isEnabled = false
        self.firstName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.lastName.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.email.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.password.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.confirmPassword.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.phoneNumber.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
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
        if phoneNumber.text == nil || phoneNumber.text!.isEmpty == true {
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
        let phoneNumberAttribute = AWSCognitoIdentityUserAttributeType(name: "phone_number", value: phoneNumber.text!)
        let attributes:[AWSCognitoIdentityUserAttributeType] = [emailAttribute, firstNameAttribute, lastNameAttribute, phoneNumberAttribute]
        userPool.signUp(email.text!, password: password.text!, userAttributes: attributes, validationData: nil)
        .continueWith { (response) -> Any? in
            if response.error != nil {
                // Error in the Signup Process
                let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.user = response.result!.user
                // Does user need confirmation?
                if (response.result?.userConfirmed?.intValue != AWSCognitoIdentityUserStatus.confirmed.rawValue) {
                    // User needs confirmation, so we need to proceed to the verify view controller
                    DispatchQueue.main.async {
                        self.codeDeliveryDetails = response.result?.codeDeliveryDetails
                        self.performSegue(withIdentifier: "VerifySegue", sender: self)
                    }
                } else {
                    // User signed up but does not need confirmation.  This should rarely happen (if ever).
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let verificationController = segue.destination as! VerificationViewController
        verificationController.codeDeliveryDetails = self.codeDeliveryDetails
        verificationController.user = self.user!
    }
    
}
