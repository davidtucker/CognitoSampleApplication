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
    
    @IBAction func submitCodePressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func resendCodePressed(_ sender: AnyObject) {
        
    }
    
}
