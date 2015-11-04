//
//  Follow.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/3/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class Follow: NSObject {
    
    var numberoffollwers = 0
    
    
    var followersArray:NSMutableArray = NSMutableArray()
    
    var isfollowing = [PFObject:Bool]()
    
    
    
    // method that loads user class data
    
    func loadData()
    {
        followersArray.removeAllObjects()
        isfollowing.removeAll(keepCapacity: true)
        
        // query the user class
        var userQuery = PFUser.query()
        userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        if let user = object as? PFObject
                        {
                            if user.objectId != PFUser.currentUser()?.objectId
                            {
                                self.followersArray.addObject(user)
                                
                                
                                // query the followers class
                                
                                var followersQuery:PFQuery = PFQuery(className: "Followers")
                                followersQuery.whereKey("user", equalTo: PFUser.currentUser()!)
                                
                                
                                // start query
                                
                                followersQuery.findObjectsInBackgroundWithBlock({ (objects ,error) -> Void in
                                    if let object = objects
                                    {
                                        if objects?.count > 0
                                        {
                                            self.isfollowing[user] = true
                                            
                                        }
                                        else
                                        {
                                            self.isfollowing[user] = false
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
    }
    
    func Follow()
    {
        let followID = followersArray.valueForKey("objectId") as! PFObject
        
        if isfollowing[followID] == false
        {
            isfollowing[followID] = true
            // set button text to unfollow here
            
        }
        
        
        // get objectIDs 
        
        let objectIDQuery = PFUser.query()
        objectIDQuery?.whereKey("objectId", equalTo: followID.objectId!)
        objectIDQuery?.getFirstObjectInBackgroundWithBlock({ (foundobject:PFObject?, error:NSError?) -> Void in
            if let object = foundobject
            {
                var followers:PFObject = PFObject(className: "Followers")
                followers["user"] = object
                followers["follower"] = PFUser.currentUser()
                
                followers.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error != nil
                    {
                        print(error?.localizedDescription)
                    }
                    else
                    {
                        print("saved")
                    }
                })
                
            }
        })
    }
}
