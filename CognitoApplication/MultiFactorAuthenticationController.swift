//
//  MultiFactorAuthenticationController.swift
//  CognitoApplication
//
//  Created by David Tucker on 8/1/17.
//  Copyright © 2017 David Tucker. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class MultiFactorAuthenticationController: UIViewController {
    
    @IBOutlet weak var authenticationCode: UITextField!
    @IBOutlet weak var submitCodeButton: UIButton!
    
    var mfaCompletionSource:AWSTaskCompletionSource<NSString>?
    
    @IBAction func submitCodePressed(_ sender: AnyObject) {
        self.mfaCompletionSource?.set(result: NSString(string: authenticationCode.text!))
    }
    
}

extension MultiFactorAuthenticationController: AWSCognitoIdentityMultiFactorAuthentication {
    
    func getCode(_ authenticationInput: AWSCognitoIdentityMultifactorAuthenticationInput, mfaCodeCompletionSource: AWSTaskCompletionSource<NSString>) {
        self.mfaCompletionSource = mfaCodeCompletionSource
    }
    
    func didCompleteMultifactorAuthenticationStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            self.authenticationCode.text = ""
        }
        if error != nil {
            let alertController = UIAlertController(title: "Cannot Verify Code",
                                                    message: (error! as NSError).userInfo["message"] as? String,
                                                    preferredStyle: .alert)
            let resendAction = UIAlertAction(title: "Try Again", style: .default, handler:nil)
            alertController.addAction(resendAction)

            let logoutAction = UIAlertAction(title: "Logout", style: .cancel, handler: { (action) in
                AppDelegate.defaultUserPool().currentUser()?.signOut()
                self.dismiss(animated: true, completion: {
                    self.authenticationCode.text = nil
                })
            })
            alertController.addAction(logoutAction)
            
            self.present(alertController, animated: true, completion:  nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
