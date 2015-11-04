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
    
    var savedObjectID:String!
    
    
    // follow method
    
    
    func Follow(UserName:String)
    {
        var query = PFQuery(className: "User")
        query.whereKey("ussername", equalTo: UserName)
        query.findObjectsInBackgroundWithBlock { (users:[PFObject]?, error:NSError?) -> Void in
            if error == nil
            {
                print("usernames found")
                if let objects = users as [PFObject]!
                {
                    for object in objects
                    {
                        print(object.objectId)
                        
                        self.savedObjectID = object.objectId
                        
                        self.followersArray.addObject(self.savedObjectID)
                        self.numberoffollwers = self.numberoffollwers + 1
                        
                    } // end of for loop
                    
            } // end of inner let
                
            }// outter if
            else
            {
                print(error?.localizedDescription)
            }
        } // end of block
        
        
        // this part updates the parse database and to include the new follower to the right user
        
        var updatequery = PFQuery(className: "User")
        updatequery.getObjectInBackgroundWithId(savedObjectID) { (userUpdate:PFObject?, error:NSError?) -> Void in
            if error == nil
            {
                let updatedinfo = userUpdate
                updatedinfo!["followers"] = self.followersArray
                updatedinfo!["numoffollowers"] = self.numberoffollwers
                updatedinfo?.saveInBackground()
            }
        }
        
        
    
    }
    
    

}
