//
//  VerificationViewController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/1/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class VerificationViewController: UIViewController {
    
    @IBOutlet weak var verificationField: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    
    var user: AWSCognitoIdentityUser?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.verifyButton.isEnabled = false
        self.verificationField.addTarget(self, action: #selector(inputDidChange(_:)), for: .editingChanged)
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
                self.resetConfirmation(message: response.error!.localizedDescription)
            } else {
                DispatchQueue.main.async {
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
