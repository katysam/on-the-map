//
//  SubmitInfoViewController.swift
//  On The Map
//
//  Created by MacBook on 7/27/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SubmitInfoViewController : UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var udacityClient = UdacityClient()
    var appDelegate = AppDelegate()
    var studentLocationData = StudentLocationData()

    @IBOutlet var mainView: UIView!
    var firstNameEntry: String!
    var lastNameEntry: String!
    @IBOutlet weak var loggedInName: UILabel!
    
    @IBOutlet weak var locationString: UITextField!
    @IBOutlet weak var webAddress: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var studyLocation: CLPlacemark!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if loggedInLastName != "" && loggedInFirstName != "" {
            loggedInName.text = "\(loggedInFirstName) \(loggedInLastName)"
        }

       // from Current Location tutorial: https://www.veasoftware.com/tutorials/2015/5/12/current-location-in-swift-xcode-63-ios-83-tutorial
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        if locationManager.location != nil {
            let region = MKCoordinateRegionMakeWithDistance(locationManager.location!.coordinate, 5000, 5000)
            mapView.setRegion(region, animated: true)
            let userLocationCoordinates = CLLocationCoordinate2DMake(locationManager.location!.coordinate.latitude, locationManager.location!.coordinate.longitude)
            let pinForUserLocation = MKPointAnnotation()
            pinForUserLocation.coordinate = userLocationCoordinates
            mapView.addAnnotation(pinForUserLocation)
            mapView.showAnnotations([pinForUserLocation], animated: true)
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations location: [CLLocation]){
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            if error != nil {
                self.alertView("Your location was not found.", message: "")
                print(error)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                self.studyLocation = pm
                self.displayLocationInfo(pm)
                
            }
        })
    }
    
    func displayLocationInfo (placemark: CLPlacemark) {
        self.locationManager.stopUpdatingLocation()
        locationString.text = "\(placemark.locality!), \(placemark.administrativeArea!)"
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Error: " + error.localizedDescription)
        alertView("Your location could not be found", message: "Please try again")
    }
    
    @IBAction func findUserLocationAndDropPin(sender: UIButton) {
        if locationString.text != "" {
            getLocationFromString(locationString.text!)
        } else {
            alertView("Enter a place to add to the map", message: "")
        }
    }
    
    func getLocationFromString(locationText: String) {
        CLGeocoder().geocodeAddressString(locationText, completionHandler: { (placemark, error) in
            if error != nil {
                self.alertView("There was a problem getting your place on the map", message: "")
            }
            if placemark != nil {
                self.studyLocation = placemark![0]
                let lat = (self.studyLocation.location?.coordinate.latitude)
                let lng = (self.studyLocation.location?.coordinate.longitude)
                let userLocationCoordinates = CLLocationCoordinate2DMake(lat!, lng!)
                let pinForUserLocation = MKPointAnnotation()
                pinForUserLocation.coordinate = userLocationCoordinates
                self.mapView.addAnnotation(pinForUserLocation)
                self.mapView.showAnnotations([pinForUserLocation], animated: true)
                
                let region = MKCoordinateRegionMakeWithDistance(userLocationCoordinates, 5000, 5000)
                self.mapView.setRegion(region, animated: true)
            }
        })
    }

    @IBAction func verifyURL(sender: AnyObject) {
        if webAddress.text == "" {
            alertView("Enter a URL", message: "")
        }
        else {
            let app = UIApplication.sharedApplication()
            if (app.openURL(NSURL(string: webAddress.text!)!)) {
                app.openURL(NSURL(string: webAddress.text!)!)
            }
            else {
                alertView("Enter a Valid URL", message: "")
            }
        }
    }
    
    @IBAction func submitData(sender: AnyObject){
        // Check that all fields are filled in
        if studyLocation == nil {
            alertView("Enter a place where you study", message: "")
        } else if self.webAddress.text == "" {
            alertView("Enter a favorite web address", message: "")
        }
        // Get the session and create a POST to Udacity
        var lat: CLLocationDegrees!
        var lng: CLLocationDegrees!

        if let _ = (self.studyLocation.location?.coordinate.latitude) {
            lat = (self.studyLocation.location?.coordinate.latitude)
        }
        if let _ = (self.studyLocation.location?.coordinate.longitude) {
            lng = (self.studyLocation.location?.coordinate.longitude)
        }
        
        /* Send the input to Parse */
        self.udacityClient.POSTMapData(loggedInFirstName, second: loggedInLastName, mapString: self.locationString.text, webAddress: self.webAddress.text, latitude: lat, longitude: lng)

        
        // Refresh the data
        self.refresh()
        
    }
    
    func refresh() {
        dispatch_async(dispatch_get_main_queue(), {
            var locationsData:[StudentLocation]!
            self.udacityClient.GETMapData({ (result, error) -> Void in
                if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    mapData = locationsData
                }
            })
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController") 
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Alert view
    func alertView(title:String, message:String) {
        dispatch_async(dispatch_get_main_queue(), {
            self.shakeScreen()
            let newController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default) {action in
                newController.dismissViewControllerAnimated(true, completion: nil)
            }
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
