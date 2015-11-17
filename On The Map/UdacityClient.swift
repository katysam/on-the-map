//
//  UdacityClient.swift
//  On The Map
//
//  Created by MacBook on 7/22/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//

import Foundation


class UdacityClient : NSObject {
    
    var appDelegate: AppDelegate!
    
    /* Shared session */
    var session: NSURLSession
    var sessionID: String!
    var udacityID: String!
    var lastName: String!
    var firstName: String!
    
    var parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    var restApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    override init() {
        session = NSURLSession.sharedSession()
        /* Get the app delegate */
        appDelegate = AppDelegate() as AppDelegate

        super.init()
    }
    
    func createSession(username:String!, password:String!, completionHandler: (success: Bool, errorString: String?) -> Void){
        dispatch_async(dispatch_get_main_queue(), {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            self.session = NSURLSession.sharedSession()
            let task = self.session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    completionHandler(success: false, errorString: "You are not connected to the internet.")
                    return
                } else {
                    
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                    var parsingError: NSError? = nil
                    
                    let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                    if let udacityAccount = parsedResult["account"] as? NSDictionary {
                        if error != nil {
                            completionHandler(success: false, errorString: "Your username or password is incorrect.")
                        } else {
                            if let udacityKey = udacityAccount.valueForKey("key"){
                                loggedInAs = udacityKey as! String
                                // convert udacityKey to String
                                let udacityKeyString = String(udacityKey)
                                self.queryMapData(udacityKeyString)

                            }
                        }
                    }
                    if let udacitySession = parsedResult["session"] as? NSDictionary {
                        if error != nil {
                            completionHandler(success: false, errorString: "Your username or password is incorrect.")
                        } else {
                            if let dataSessionID = udacitySession.valueForKey("id") as? String {
                                completionHandler(success: true, errorString: nil)
                            } else {
                                completionHandler(success: false, errorString: "Login Failed (Create Session 01).")
                            }
                        }
                    } else {
                        completionHandler(success: false, errorString: "The username or password is incorrect.")
                    }

                }
            }
            task.resume()
        })
    }
    
    func endSession() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie!
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies)! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
        }
        task.resume()

    }
    
    // MARK: - GET
    
    func getMapData(completionHandler: (result: AnyObject!, error: String?) -> Void) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(result: nil, error: "error")
            } else {
                
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                
                /* 6. Use the data! */
                if let results = parsedResult["results"] {
                    completionHandler(result: results, error: nil)
                } else {
                    completionHandler(result: nil, error: "error")
                }
                
            }
        }
        /* 7. Continue  */
        task.resume()
        return task
    }
    
    // MARK: - POST
    
    func postMapData (mapString: String!, webAddress: String!, latitude: Double!, longitude: Double!, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(parseApplicationId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(udacityID)\", \"firstName\": \"\(loggedInFirstName)\", \"lastName\": \"\(loggedInLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(webAddress)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Your data did not post. Please try again.")
            } else {
                let parsedData =  (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                if let message = (parsedData.valueForKey("error")) {
                    completionHandler(success: false, errorString: "There was a problem posting your info to the map.")
                    return
                }
                completionHandler(success: true, errorString: nil)

            }
            
        }
        task.resume()

    }
    
    // MARK: - GET Public User Data
    func queryMapData(udacityKey: String) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(udacityKey)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in

            if error != nil { // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
            if let studentInfo = parsedResult.valueForKey("user") {
                
                // set properties for what is known
                let last = studentInfo.valueForKey("last_name")
                loggedInLastName = last as! String
                let first = studentInfo.valueForKey("first_name")
                loggedInFirstName = first as! String
            }
        }
        task.resume()

    }
    

    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

    
    /* Helper function: Given a dictionary of parameters, convert to a string with + instead of spaces for a url */
    func stripSpaces(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)" as String
            
            /* Escape it */
            var escapedValue = ""
            for element in stringValue.characters {
                if element == " " {
                    escapedValue += "+"
                }else {
                    escapedValue.append(element)
                }
            }
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue)"]
            
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper function: Given a location string, return latitude and longitude */
    func latLonFromString(locationString: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
//        http://maps.google.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=false
        
        var urlBase =  "https://maps.google.com/maps/api/geocode/json"
        var parameters = stripSpaces(["address" : locationString])
        var suffix = "&sensor=false"
        
        /* 1. Set the parameters */
        
        /* 2/3. Build the URL and configure the request */
        let urlString = urlBase + parameters + suffix
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            var parsingError: NSError? = nil
            let parsedResult = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as! NSDictionary
            if let error = downloadError {
                print("This is an error: \(error)")
                completionHandler(result: nil, error: downloadError)
            } else {
                let results = parsedResult["results"] as! [NSDictionary]
                let resultDict = results[0] as NSDictionary
                let geometry = resultDict["geometry"] as! NSDictionary
                let location = geometry["location"] as! NSDictionary
                completionHandler(result: location, error: nil)
            }
        }
        
        /* 7. Start the request */
        
        task.resume()
        return task
    }
    
    

    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }

    
}