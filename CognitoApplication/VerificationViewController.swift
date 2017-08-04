//
//  VerificationViewController.swift
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

class VerificationViewController: UIViewController {
    
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var verificationLabel: UILabel!
    
    var codeDeliveryDetails:AWSCognitoIdentityProviderCodeDeliveryDetailsType?
    
    var user: AWSCognitoIdentityUser?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.verifyButton.isEnabled = false
        self.verificationField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        populateCodeDeliveryDetails()
    }
    
    func populateCodeDeliveryDetails() {
        let isEmail = (codeDeliveryDetails?.deliveryMedium == AWSCognitoIdentityProviderDeliveryMediumType.email)
        verifyButton.setTitle(isEmail ? "Verify Email Address" : "Verify Phone Number", for: .normal)
        let medium = isEmail ? "your email address" : "your phone number"
        let destination = codeDeliveryDetails!.destination!
        verificationLabel.text = "Please enter the code that was sent to \(medium) at \(destination)"
    }
    
    func inputDidChange(_ sender:AnyObject) {
        if(verificationField.text == nil) {
            self.verifyButton.isEnabled = false
            return
        }
        self.verifyButton.isEnabled = true
    }
    
    func resetConfirmation(message:String? = "") {
        self.verificationField.text = ""
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
        self.present(alert, animated: true, completion:nil)
    }
    
    @IBAction func verifyPressed(_ sender: AnyObject) {
        self.user?.confirmSignUp(verificationField.text!)
        .continueWith(block: { (response) -> Any? in
            if response.error != nil {
                self.resetConfirmation(message: (response.error! as NSError).userInfo["message"] as? String)
            } else {
                DispatchQueue.main.async {
                    // Return to Login View Controller - this should be handled a bit differently, but added in this manner for simplicity
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
            return nil
        })
    }
    
    @IBAction func resendConfirmationCodePressed(_ sender: AnyObject) {
        self.user?.resendConfirmationCode()
        .continueWith(block: { (respone) -> Any? in
            let alert = UIAlertController(title: "Resent", message: "The confirmation code has been resent.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion:nil)
            return nil
        })
    }
    
}
