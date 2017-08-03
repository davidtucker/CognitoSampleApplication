//
//  LoginViewController.swift
//  Created by David Tucker (davidtucker.net) on 5/4/17.
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

class LoginViewController: UIViewController {
    
    @IBOutlet weak var passwordInput: UITextField?
    @IBOutlet weak var usernameInput: UITextField?
    @IBOutlet weak var loginButton: UIButton?
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.usernameInput?.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.passwordInput?.text == nil) {
            return
        }
        
        let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.usernameInput!.text!, password: self.passwordInput!.text! )
        self.passwordAuthenticationCompletion?.set(result: authDetails)
    }
    
    @IBAction func forgotPasswordPressed(_ sender: AnyObject) {
        if (self.usernameInput?.text == nil || self.usernameInput!.text!.isEmpty) {
            let alertController = UIAlertController(title: "Enter Username",
                                                    message: "Please enter your username and then select Forgot Password if you want to reset your password.",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(retryAction)
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        self.performSegue(withIdentifier: "ForgotPasswordSegue", sender: self)
    }
    
    func inputDidChange(_ sender:AnyObject) {
        if (self.usernameInput?.text != nil && self.passwordInput?.text != nil) {
            self.loginButton?.isEnabled = true
        } else {
            self.loginButton?.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForgotPasswordSegue" {
            let forgotPasswordController = segue.destination as! ForgotPasswordViewController
            forgotPasswordController.emailAddress = self.usernameInput!.text!
        }
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {

    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameInput?.text == nil) {
                self.usernameInput?.text = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
                let alertController = UIAlertController(title: "Cannot Login",
                                                        message: (error! as NSError).userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.dismiss(animated: true, completion: { 
                    self.usernameInput?.text = nil
                    self.passwordInput?.text = nil
                })
            }
        }
    }
    
}
