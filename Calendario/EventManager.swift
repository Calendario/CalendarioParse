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
    
    @objc class func getEventAttendants(eventID: String, completion: (attendants: Array<AnyObject>) -> Void) {
        
        var attendantQuery: PFQuery!
        attendantQuery = PFQuery(className: "StatusUpdate")
        attendantQuery.whereKey("objectId", equalTo: eventID)
        attendantQuery.getFirstObjectInBackgroundWithBlock { (eventObject, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if ((error == nil) && (eventObject != nil))
                {
                    completion(attendants: eventObject!["rsvpArray"] as! Array<AnyObject>)
                }
                else
                {
                    completion(attendants: [])
                }
            })
        }
    }
    
    @objc class func getUserAttendingEvents(eventID: String, completion: (attendingEvents: Array<AnyObject>) -> Void) {
        
        var userAttendingEventsQuery: PFQuery!
        userAttendingEventsQuery = PFQuery(className: "StatusUpdate")
        userAttendingEventsQuery.whereKey("rsvpArray", containsString: PFUser.currentUser()?.objectId!)
        userAttendingEventsQuery.findObjectsInBackgroundWithBlock { (eventObjects, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if ((error == nil) && (eventObjects != nil))
                {
                    completion(attendingEvents: eventObjects!)
                }
                else
                {
                    completion(attendingEvents: [])
                }
            })
        }
    }
}