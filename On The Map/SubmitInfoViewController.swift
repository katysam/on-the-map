//
//  SubmitInfoViewController.swift
//  On The Map
//
//  Created by MacBook on 7/27/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import UIKit
import MapKit

class SubmitInfoViewController : UIViewController {
    
    var udacityClient = UdacityClient()
    var appDelegate = AppDelegate()
    var locations: [StudentLocation]!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!

    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var locationString: UITextField!
    @IBOutlet weak var webAddress: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var lat: Double!
    var lng: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        locations = appDelegate.mapData
        
        // Init the zoom level
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.70, longitude: -73.99)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapView.setRegion(region, animated: true)
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
    
    
    @IBAction func searchButtonClick(sender: AnyObject) {
        //1
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        //2
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.locationString.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.locationString.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    @IBAction func browseButtonClick(sender: AnyObject) {
        if webAddress.text == "" {
            let alertController = UIAlertController(title: nil, message: "Enter a URL", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

        }
        else {
            let app = UIApplication.sharedApplication()
            if (app.openURL(NSURL(string: webAddress.text!)!)) {
                app.openURL(NSURL(string: webAddress.text!)!)
            }
            else {
                let alertController = UIAlertController(title: nil, message: "Enter a Valid URL", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func submitData(sender: AnyObject){
        // Get the session and create a POST to Udacity
        let string = locationString.text
        udacityClient.latLonFromString(string!) {(result, error) in
            
            /* Convert locationString to lat/lon */
            if let result = result as? NSDictionary {
                self.lat = result["lat"] as! Double
                self.lng = result["lng"] as! Double
                
                /* Send the input to Parse */
                self.udacityClient.POSTMapData(self.firstName.text, second: self.lastName.text, mapString: self.locationString.text, webAddress: self.webAddress.text, latitude: self.lat, longitude: self.lng)

                // Refresh the data
                
                self.refresh()
            }
        }
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

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
