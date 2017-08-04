//
//  ForgotPasswordViewController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/2/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var verificationCode: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var emailAddress:String = ""
    var user:AWSCognitoIdentityUser?
    
    func clearFields() {
        self.verificationCode.text = ""
        self.newPassword.text = ""
        self.confirmPassword.text = ""
        self.emailAddress = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !emailAddress.isEmpty {
            let pool = AppDelegate.defaultUserPool()
            // Get a reference to the user using the email address
            user = pool.getUser(emailAddress)
            // Initiate the forgot password process which will send a verification code to the user
            user?.forgotPassword()
            .continueWith(block: { (response) -> Any? in
                if response.error != nil {
                    // Cannot request password reset due to error (for example, the attempt limit exceeded)
                    let alert = UIAlertController(title: "Cannot Reset Password", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.clearFields()
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return nil
                }
                // Password reset was requested and message sent.  Let the user know where to look for code.
                let result = response.result
                let isEmail = (result?.codeDeliveryDetails?.deliveryMedium == AWSCognitoIdentityProviderDeliveryMediumType.email)
                let destination:String = result!.codeDeliveryDetails!.destination!
                let medium = isEmail ? "an email" : "a text message"
                let alert = UIAlertController(title: "Verification Sent", message: "You should receive \(medium) with a verification code at \(destination).  Enter that code here along with a new password.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return nil
            })
        }
    }
    
    @IBAction func resetPasswordPressed(_ sender: AnyObject) {
        user?.confirmForgotPassword(self.verificationCode.text!, password: self.newPassword.text!)
        .continueWith { (response) -> Any? in
            if response.error != nil {
                // The password could not be reset - let the user know
                let alert = UIAlertController(title: "Cannot Reset Password", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Resend Code", style: .default, handler: { (action) in
                    self.user?.forgotPassword()
                    .continueWith(block: { (result) -> Any? in
                        print("Code Sent")
                        return nil
                    })
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                }))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                // Password reset.  Send the user back to the login and let them know they can login with new password.
                DispatchQueue.main.async {
                    let presentingController = self.presentingViewController
                    self.presentingViewController?.dismiss(animated: true, completion: {
                        let alert = UIAlertController(title: "Password Reset", message: "Password reset.  Please log into the account with your email and new password.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        presentingController?.present(alert, animated: true, completion: nil)
                            self.clearFields()
                        }
                    )
                }
            }
            return nil
        }
    }
    
    @IBAction func cancelForgotPasswordPressed(_ sender: AnyObject) {
        clearFields()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
