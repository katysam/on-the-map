//
//  FacebookClient.swift
//  On The Map
//
//  Created by MacBook on 7/27/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import Foundation

class FacebookClient {
    
    var appDelegate = AppDelegate()
    var udacityClient = UdacityClient()
    var loginViewController = LoginViewController()
    
    func createSession(accessToken:String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        print("... Getting a Udacity session")
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error...
                return
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                var parsingError: NSError? = nil
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                let udacityAccountInfo = parsedResult["account"]
                if let udacityAccountKey = udacityAccountInfo!["key"]! {
                    loggedInAs = udacityAccountKey as! String
                    print("I am logged in as: \(loggedInAs)")
                    self.loginViewController.completeLogin()
               } else {
                    parsingError = error
                    
                    //TODO: create an alert
                    print("There was a problem getting your Udacity information.")
                }
                
            }
            

        }
        task.resume()

    }
    
//    func completeLogin() {
//        dispatch_async(dispatch_get_main_queue(), {
//            var locationsData:[StudentLocation]!
//            self.udacityClient.GETMapData({ (result, error) -> Void in
//                if result != nil {
//                    let resultArray = result as! [[String: AnyObject]]
//                    locationsData = StudentLocation.locationsFromResults(resultArray)
//                    if locationsData != nil {
//                        self.appDelegate.mapData = locationsData
//                    }
//                }
//            })
//            let controller = loginViewController.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")
//            loginViewController.presentViewController(controller, animated: true, completion: nil)
//        })
//    }

}
