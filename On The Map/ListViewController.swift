//
//  ListViewController.swift
//  On The Map
//
//  Created by MacBook on 7/22/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit

class ListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var locations: [StudentLocation]!
    var udacityClient = UdacityClient()
    var appDelegate: AppDelegate!

    
    @IBOutlet weak var listStudentLocations: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        locations = appDelegate.mapData
        
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
        let location = locations[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        let fullName = "\(location.firstName) \(location.lastName)"
        cell.textLabel!.text = fullName
        let placePlusURL = "\(location.mapString)  -  \(location.mediaURL)"
        cell.detailTextLabel?.text = placePlusURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication()
        let location = locations[indexPath.row]
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
            self.udacityClient.GETMapData({ (result, error) -> Void in
                if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    self.appDelegate.mapData = locationsData
                }
            })
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") 
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }

    
    // MARK: - Add a Student to the map/list
    
    @IBAction func switchToAddUserView(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("SubmitInfoView") 
        self.presentViewController(controller, animated: false, completion: nil)
    }
    

}
