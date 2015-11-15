//
//  MapViewController.swift
//  On The Map
//
//  Created by MacBook on 7/22/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewControllerDelegate {
    func locationPicker(locationPicker: MapViewController, didPickMLocation location: StudentLocation?)
}

class MapViewController: UIViewController, MKMapViewDelegate  {
    
    var appDelegate = AppDelegate()
    var delegate: MapViewControllerDelegate?
    var udacityClient = UdacityClient()
    var studentLocationData = StudentLocationData()
    var locations: [StudentLocation]!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if mapData == nil {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("LoginView")
            self.presentViewController(controller, animated: true, completion: nil)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), {

            self.locations = mapData
            
            // We will create an MKPointAnnotation for each dictionary in "locations". The
            // point annotations will be stored in this array, and then provided to the map view.
            var annotations = [MKPointAnnotation]()
            
            // The "locations" array is loaded with the sample data below. We are using the dictionaries
            // to create map annotations. This would be more stylish if the dictionaries were being
            // used to create custom structs. Perhaps StudentLocation structs.
            
            if self.locations != nil {
                
                for dictionary in self.locations {
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.println
                    let lat = CLLocationDegrees(dictionary.latitude as Double)
                    let long = CLLocationDegrees(dictionary.longitude as Double)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = dictionary.firstName as String
                    let last = dictionary.lastName as String
                    let mediaURL = dictionary.mediaURL as String
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
            } else {
                print("there are no locations available")
            }
            
            // When the array is complete, we add the annotations to the map.
            self.mapView.addAnnotations(annotations)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        activityIndicator.hidden = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {

        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    
    
    // MARK: - Go back and start over
    
    @IBAction func logout(sender: AnyObject) {
        udacityClient.sessionID = nil
        let controller = self.storyboard!.instantiateInitialViewController()
        presentViewController(controller!, animated: true, completion: nil)
    }
    
    // MARK: - Refresh the data

    @IBAction func refreshButton(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            
            self.refresh()
        })
        
    }
    
    func refresh() {
        var locationsData:[StudentLocation]!
            self.udacityClient.GETMapData({ (result, error) -> Void in
                if result != nil {
                    let resultArray = result as! [[String: AnyObject]]
                    locationsData = StudentLocation.locationsFromResults(resultArray)
                    mapData = locationsData
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NavigationController")
                    self.presentViewController(controller, animated: true, completion: nil)
                    self.mapView.reloadInputViews()
                } else {
                    self.alertView("Unable to retrieve fresh data", message: "Try again in a few minutes, or check your internet connection.")
                }
            })
    }
    
    // MARK: - Switch to "Add a Student to the map/list" view
    
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