//
//  AppViewController.swift
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

class AppViewController: UITableViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var mfaSwitch: UISwitch!
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    var mfaSettings:[AWSCognitoIdentityProviderMFAOptionType]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserValues()
    }
    
    func loadUserValues () {
        self.resetAttributeValues()
        self.fetchUserAttributes()
    }
    
    func fetchUserAttributes() {
        self.resetAttributeValues()
        user = AppDelegate.defaultUserPool().currentUser()
        user?.getDetails().continueOnSuccessWith(block: { (task) -> Any? in
            guard task.result != nil else {
                return nil
            }
            self.userAttributes = task.result?.userAttributes
            self.mfaSettings = task.result?.mfaOptions
            self.userAttributes?.forEach({ (attribute) in
                print("Name: " + attribute.name!)
            })
            DispatchQueue.main.async {
                self.setAttributeValues()
            }
            return nil
        })
    }
    
    func resetAttributeValues() {
        DispatchQueue.main.async {
            self.lastNameLabel.text = ""
            self.firstNameLabel.text = ""
            self.usernameLabel.text = ""
            self.phoneNumberLabel.text = ""
            self.mfaSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction func handleSwitch(_ sender: AnyObject) {
        let settings = AWSCognitoIdentityUserSettings()
        if mfaSwitch.isOn {
            // Enable MFA
            let mfaOptions = AWSCognitoIdentityUserMFAOption()
            mfaOptions.attributeName = "phone_number"
            mfaOptions.deliveryMedium = .sms
            settings.mfaOptions = [mfaOptions]
        } else {
            // Disable MFA
            settings.mfaOptions = []
        }
        user?.setUserSettings(settings)
        .continueOnSuccessWith(block: { (response) -> Any? in
            if response.error != nil {
                let alert = UIAlertController(title: "Error", message: (response.error! as NSError).userInfo["message"] as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion:nil)
                self.resetAttributeValues()
            } else {
                self.fetchUserAttributes()
            }
            return nil
        })
        
    }
    
    func isEmailMFAEnabled() -> Bool {
        let values = self.mfaSettings?.filter { $0.deliveryMedium == AWSCognitoIdentityProviderDeliveryMediumType.sms }
        if values?.first != nil {
            return true
        }
        return false
    }
    
    func setAttributeValues() {
        DispatchQueue.main.async {
            self.lastNameLabel.text = self.valueForAttribute(name: "family_name")
            self.firstNameLabel.text = self.valueForAttribute(name: "given_name")
            self.usernameLabel.text = self.valueForAttribute(name: "email")
            self.phoneNumberLabel.text = self.valueForAttribute(name: "phone_number")
            if self.mfaSettings == nil {
                self.mfaSwitch.setOn(false, animated: false)
            } else {
                self.mfaSwitch.setOn(self.isEmailMFAEnabled(), animated: false)
            }
        }
    }
    
    func valueForAttribute(name:String) -> String? {
        let values = self.userAttributes?.filter { $0.name == name }
        return values?.first?.value
    }
    
    @IBAction func logout(_ sender:AnyObject) {
        user?.signOut()
        self.fetchUserAttributes()
    }
    
}
