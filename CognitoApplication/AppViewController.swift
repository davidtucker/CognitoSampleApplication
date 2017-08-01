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
    
    var user:AWSCognitoIdentityUser?
    var userAttributes:[AWSCognitoIdentityProviderAttributeType]?
    
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
        self.lastNameLabel.text = ""
        self.firstNameLabel.text = ""
        self.usernameLabel.text = ""
    }
    
    func setAttributeValues() {
        self.lastNameLabel.text = valueForAttribute(name: "family_name")
        self.firstNameLabel.text = valueForAttribute(name: "given_name")
        self.usernameLabel.text = valueForAttribute(name: "email")
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
