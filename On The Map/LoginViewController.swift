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
    var facebookClient = FacebookClient()

    
    var appDelegate: AppDelegate!
    var session: NSURLSession!

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var udacityLoginButton: UIButton!

    @IBOutlet weak var udacityLogo: UIImageView!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.subscribeToKeyboardNotifications()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.unsubscribeFromKeyboardNotifications()
    }
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        FBSDKLoginButton()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginViaUdacity(sender: UIButton) {
        if username.text == "" {
            alertView("Login failure", message:"Please enter a username.")
        } else {
            if password.text == "" {
                alertView("Login failure", message:"Please enter a password")
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
   
    }
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            var locationsData:[StudentLocation]!
            self.udacityClient.GETMapData({ (result, error) -> Void in
                if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    if locationsData != nil {
                        self.appDelegate.mapData = locationsData
                    }
                }
            })
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") 
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    // Alert view 
    func alertView(title:String, message:String) {
        let newController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {action in self.dismissViewControllerAnimated(true, completion: nil)}
        newController.addAction(okAction)
        self.presentViewController(newController, animated: true, completion: nil)
        
    }


    // Move the screen up when typing
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        udacityLogo.hidden = true
        view.frame.origin.y -= getKeyboardHeight(notification)

    }
    
    func keyboardWillHide(notification: NSNotification) {
         udacityLogo.hidden = false
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }


}

