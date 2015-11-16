//
//  ListViewController.swift
//  On The Map
//
//  Created by MacBook on 7/22/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var udacityClient = UdacityClient()
    var appDelegate = AppDelegate()
    var studentLocationData = StudentLocationData()
    
    @IBOutlet weak var listStudentLocations: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDelegate and UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "StudentLocationTableViewCell"
        let location = mapData[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        let fullName = "\(location.firstName) \(location.lastName)"
        cell.textLabel!.text = fullName
        let longDate = location.createdAt
        let shortDate = longDate.substringToIndex(longDate.startIndex.advancedBy(10))
        let placePlusURL = "\(shortDate)  -  \(location.mapString)  -  \(location.mediaURL)"
        cell.detailTextLabel?.text = placePlusURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mapData != nil {
            return mapData.count
        } else {
            return 4
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        let location = mapData[indexPath.row]
        app.openURL(NSURL(string: location.mediaURL)!)

    }
    
    @IBAction func logout(sender: AnyObject) {
        udacityClient.sessionID = nil
        let controller = self.storyboard!.instantiateInitialViewController()
        presentViewController(controller!, animated: true, completion: nil)
    }
    
    // MARK: - Refresh the data
    
    @IBAction func refreshButton(sender: AnyObject) {
        refresh()

    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            var locationsData:[StudentLocation]!
            self.udacityClient.getMapData({ (result, error) -> Void in
                if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    mapData = locationsData
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")
                    self.presentViewController(controller, animated: true, completion: nil)

                } else {
                    self.alertView("Unable to retrieve fresh data", message: "Try again in a few minutes, or check your internet connection.")
                }
            })
        })
    }

    
    // MARK: - Add a Student to the map/list
    
    @IBAction func switchToAddUserView(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SubmitInfoView") 
        self.presentViewController(controller, animated: false, completion: nil)
    }
    
    // Alert view
    func alertView(title:String, message:String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.shakeScreen()
            let newController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {action in
                newController.dismissViewControllerAnimated(true, completion: nil)}
            newController.addAction(okAction)
            self.presentViewController(newController, animated: true, completion: nil)
        })
        
    }
    
    // Shake screen on error
    
    func shakeScreen() {
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 50
            }, completion: { finished in
                self.shakeScreenLeft()
        })
    }
    
    func shakeScreenLeft() {
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x -= 100
            }, completion: { finished in
                self.shakeScreenRightAgain()
        })
    }
    
    func shakeScreenRightAgain() {
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 80
            }, completion: { finished in
                self.shakeScreenLeftAgain()
        })
    }
    
    func shakeScreenLeftAgain() {
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x -= 80
            }, completion: { finished in
                self.shakeScreenCenter()
        })
    }
    
    func shakeScreenCenter() {
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.frame.origin.x += 50
            }, completion: nil)
    }
    

}
