//
//  EventManager.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 08/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import Parse
 
// EventManager class contains methods related to
// events such as: find all the attendants of an event.
@objc class EventManager : NSObject {
    
    @objc class func getEventAttendants(_ eventID: String, completion: @escaping (_ attendants: Array<AnyObject>) -> Void) {
        
        var attendantQuery: PFQuery<PFObject>!
        attendantQuery = PFQuery(className: "StatusUpdate")
        attendantQuery.whereKey("objectId", equalTo: eventID)
        attendantQuery.getFirstObjectInBackground { (eventObject, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                if ((error == nil) && (eventObject != nil))
                {
                    completion(eventObject!["rsvpArray"] as! Array<AnyObject>)
                }
                else
                {
                    completion([])
                }
            })
        }
    }
    
    @objc class func getUserAttendingEvents(_ eventID: String, forUser: PFUser, completion: @escaping (_ attendingEvents: Array<AnyObject>) -> Void) {
        
        var userAttendingEventsQuery: PFQuery<PFObject>!
        userAttendingEventsQuery = PFQuery(className: "StatusUpdate")
        userAttendingEventsQuery.whereKey("rsvpArray", contains: forUser.objectId!)
        userAttendingEventsQuery.findObjectsInBackground { (eventObjects, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                if ((error == nil) && (eventObjects != nil))
                {
                    completion(eventObjects!)
                }
                else
                {
                    completion([])
                }
            })
        }
    }
}
