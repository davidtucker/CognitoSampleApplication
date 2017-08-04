//
//  AppDelegate.swift
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

let userPoolID = "SampleUserPool"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    class func defaultUserPool() -> AWSCognitoIdentityUserPool {
        return AWSCognitoIdentityUserPool(forKey: userPoolID)
    }
    
    var window: UIWindow?
    
    var loginViewController: LoginViewController?
    
    var resetPasswordViewController: ResetPasswordViewController?
    
    var multiFactorAuthenticationController: MultiFactorAuthenticationController?
    
    var navigationController: UINavigationController?
    
    var cognitoConfig:CognitoConfig?
    
    var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // setup logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        // setup cognito config
        self.cognitoConfig = CognitoConfig()
        
        // setup cognito
        setupCognitoUserPool()
        
        // Override point for customization after application launch.
        return true
    }
    
    func setupCognitoUserPool() {
        let clientId:String = self.cognitoConfig!.getClientId()
        let poolId:String = self.cognitoConfig!.getPoolId()
        let clientSecret:String = self.cognitoConfig!.getClientSecret()
        let region:AWSRegionType = self.cognitoConfig!.getRegion()
        
        let serviceConfiguration:AWSServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: nil)
        let cognitoConfiguration:AWSCognitoIdentityUserPoolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: clientSecret, poolId: poolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: cognitoConfiguration, forKey: userPoolID)
        let pool:AWSCognitoIdentityUserPool = AppDelegate.defaultUserPool()
        pool.delegate = self
    }

}

extension AppDelegate: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        if(self.navigationController == nil) {
            self.navigationController = self.window?.rootViewController as? UINavigationController
        }
        
        if(self.loginViewController == nil) {
            self.loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        
        DispatchQueue.main.async {
            if(self.loginViewController!.isViewLoaded || self.loginViewController!.view.window == nil) {
                self.navigationController?.present(self.loginViewController!, animated: true, completion: nil)
            }
        }
        
        return self.loginViewController!
    }
    
    func startNewPasswordRequired() -> AWSCognitoIdentityNewPasswordRequired {
        if (self.resetPasswordViewController == nil) {
            self.resetPasswordViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordController") as? ResetPasswordViewController
        }
        
        DispatchQueue.main.async {
            if(self.resetPasswordViewController!.isViewLoaded || self.resetPasswordViewController!.view.window == nil) {
                self.navigationController?.present(self.resetPasswordViewController!, animated: true, completion: nil)
            }
        }
        
        return self.resetPasswordViewController!
    }
    
    func startMultiFactorAuthentication() -> AWSCognitoIdentityMultiFactorAuthentication {
        if (self.multiFactorAuthenticationController == nil) {
            self.multiFactorAuthenticationController = self.storyboard?.instantiateViewController(withIdentifier: "MultiFactorAuthenticationController") as? MultiFactorAuthenticationController
        }
        
        DispatchQueue.main.async {
            if(self.multiFactorAuthenticationController!.isViewLoaded || self.multiFactorAuthenticationController!.view.window == nil) {
                self.navigationController?.present(self.multiFactorAuthenticationController!, animated: true, completion: nil)
            }
        }
        
        return self.multiFactorAuthenticationController!
    }
    
}



