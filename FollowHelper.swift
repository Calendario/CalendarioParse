//
//  FollowHelper.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/8/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class FollowHelper: NSObject {
    let ParseFollowFromUser   = "fromUser"
     let ParseFollowToUser     = "toUser"
    
    
    override init()
    {
        
    }
    
    func addFollowingRelationshipFromUser(_ user:String, toUser:String )
    {
        let followObject = PFObject(className: "Followers")
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        followObject.saveInBackground()
    }
    
    // unfollow method
    
    func RemoveFollowingRelationshipFromUser(_ user:String, toUser:String)
    {
        let query = PFQuery(className: "Followers")
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackground { (results, error) -> Void in
            if error == nil
            {
                let results = results! as [PFObject] 
                
                for relationship in results
                {
                    relationship.deleteInBackground(block: { (sucess, error) -> Void in
                        if  sucess
                        {
                            print("Unfollowed")
                        }
                        else
                        {
                            print("error")
                        }
                    })
                }
            }
        }
    }
    
    
    
    
}
