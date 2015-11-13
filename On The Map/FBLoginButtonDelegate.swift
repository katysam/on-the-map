//
//  FBLoginButtonDelegate.swift
//  On The Map
//
//  Created by MacBook on 10/13/15.
//  Copyright © 2015 KSamalin. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

var loginViewController = LoginViewController()
var udacityClient = UdacityClient()
var facebookClient = FacebookClient()

class FBLoginButtonDelegate: NSObject, FBSDKLoginButtonDelegate {
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        //check login success
        
        if (error != nil) {
            print("FB Login Error: " + error.localizedDescription)
            
            loginViewController.alertView("FB Login Error", message: "")
        
        
        } else {
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            facebookClient.createSession(accessToken) {(success, errorString) in
                if success {
                     //do something
                    let controller = loginViewController.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")
                    loginViewController.presentViewController(controller, animated: true, completion: nil)

                } else {
                    //TODO: create an alert with errorString as the message
                    print(errorString)
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // TODO: FB Log out
        // Set Udacity token to nil
        // Switch the view to the Login page
    }
    
}

