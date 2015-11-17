//
//  LoginViewController.swift
//  On The Map
//
//  Created by MacBook on 7/21/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var udacityClient = UdacityClient()
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    let loginDelegate = FBLoginButtonDelegate()

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var udacityLoginButton: UIButton!

    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var FBButton: FBSDKLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var wholeScreen: UIView!

    override func viewWillAppear(animated: Bool) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")

        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        FBSDKLoginButton()
        self.FBButton.delegate = loginDelegate
        activityIndicator.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginViaUdacity(sender: UIButton) {
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
        activityIndicator.hidden = false
        view.alpha = 0.9
        if username.text == "" {
            alertView("Please enter a username", message:"")
        } else {
            if password.text == "" {
                alertView("Please enter a password", message:"")
            }else {
                udacityClient.createSession(username.text, password: password.text) { (success, errorString) in
                    if success {
                        self.completeLogin()
                    } else {
                        let message = errorString
                        self.alertView("Login failure", message:message!)
                    }
                }
            }
        }
    }
    
    @IBAction func joinUdacity(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: "https://udacity.com/account/auth#!/signup")!)

    }
    
    @IBAction func loginViaFacebook(sender: AnyObject) {
//        completeLogin()
        print("I am logging in via Facebook")
    }
    
    func completeLogin() {
        var locationsData:[StudentLocation]!
        dispatch_async(dispatch_get_main_queue(), {
            self.udacityClient.getMapData({ (result, error) -> Void in
                if error != nil {
                    self.alertView("Data not available", message: "There was a problem retrieving the map data")
                } else if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    // SORT data by createdAt
                    locationsData.sortInPlace({$0.createdAt > $1.createdAt })
                    // TRIM data to 100 entries
                    if locationsData.count > 100 {
                        let tempLocationsData = locationsData[0...99]
                        var newLocationsData = [StudentLocation]()
                        for i in tempLocationsData {
                            newLocationsData.append(i)
                        }
                        locationsData = newLocationsData
                    }
                    
                    mapData = locationsData

                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            })
        })

    }
    
    // Alert view
    func alertView(title:String, message:String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicator.hidden = true
            self.view.alpha = 1.0
            self.shakeScreen()
            let newController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {action in self.dismissViewControllerAnimated(true, completion: nil)}
            newController.addAction(okAction)
            self.presentViewController(newController, animated: true, completion: nil)
        })
        
    }


    
    // Shake screen on error
    
    func shakeScreen() {
        
        UIView.animateWithDuration(0.08, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 50
            }, completion: { finished in
                self.shakeScreenLeft()
        })
    }
    
    func shakeScreenLeft() {
        
        UIView.animateWithDuration(0.14, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x -= 100
            }, completion: { finished in
                self.shakeScreenRightAgain()
        })
    }
    
    func shakeScreenRightAgain() {
        
        UIView.animateWithDuration(0.14, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 80
            }, completion: { finished in
                self.shakeScreenLeftAgain()
        })
    }
    
    func shakeScreenLeftAgain() {
        
        UIView.animateWithDuration(0.14, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x -= 80
            }, completion: { finished in
                self.shakeScreenCenter()
        })
    }
    
    func shakeScreenCenter() {
        
        UIView.animateWithDuration(0.08, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 50
            }, completion: nil)
    }
    

}

