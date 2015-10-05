//
//  StudentLocation.swift
//  On The Map
//
//  Created by MacBook on 7/26/15.
//  Copyright (c) 2015 KSamalin. All rights reserved.
//


struct StudentLocation {
    
    var createdAt = ""
    var firstName = ""
    var lastName = ""
    var latitude = 0.0
    var longitude = 0.0
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    var updatedAt = ""
    
    /* Construct a Location from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        createdAt = dictionary["createdAt"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        if dictionary["objectID"] != nil {
            objectId = dictionary["objectID"] as! String
        }
        if let key = dictionary["uniqueKey"] {
            uniqueKey = String(key)
        }
        if dictionary["updatedAt"] != nil {
            updatedAt = dictionary["updatedAt"] as! String
        }
        
    }
    
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func locationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
}
