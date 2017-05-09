//
//  ResetPasswordViewController.swift
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

import Foundation
import UIKit
import AWSCognitoIdentityProvider

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var newPasswordButton: UIButton!
    @IBOutlet weak var newPasswordInput: UITextField!
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    
    var currentUserAttributes:[String:String]?
    
    var resetPasswordCompletion: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.newPasswordInput.text = nil
        self.newPasswordInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.firstNameInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
        self.lastNameInput.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
    }
    
    func inputDidChange(_ sender:AnyObject) {
        if (self.newPasswordInput.text != nil && self.firstNameInput != nil && self.lastNameInput != nil) {
            self.newPasswordButton.isEnabled = true
        } else {
            self.newPasswordButton.isEnabled = false
        }
    }
    
    @IBAction func submitNewPassword(_ sender:AnyObject) {
        var userAttributes:[String:String] = [:]
        userAttributes["family_name"] = self.lastNameInput.text
        userAttributes["given_name"] = self.firstNameInput.text
        let details = AWSCognitoIdentityNewPasswordRequiredDetails(proposedPassword: self.newPasswordInput.text!, userAttributes: userAttributes)
        self.resetPasswordCompletion?.set(result: details)
    }
    
}

extension ResetPasswordViewController: AWSCognitoIdentityNewPasswordRequired {
    
    public func getNewPasswordDetails(_ newPasswordRequiredInput: AWSCognitoIdentityNewPasswordRequiredInput, newPasswordRequiredCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails>) {
        self.currentUserAttributes = newPasswordRequiredInput.userAttributes
        self.resetPasswordCompletion = newPasswordRequiredCompletionSource
    }
    
    public func didCompleteNewPasswordStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.newPasswordInput.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}
