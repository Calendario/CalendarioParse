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
    
    func addFollowingRelationshipFromUser(user:String, toUser:String )
    {
        let followObject = PFObject(className: "Followers")
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowToUser)
        followObject.saveInBackground()
    }
    
    
}