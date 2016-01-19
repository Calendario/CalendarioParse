//
//  LikeHelper.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class LikeHelper: NSObject {
    // relations
    static let ParseClassName = "Like"
    static let toPost = "ToPost"
    static let fromuser = "fromUser"
    
    static func LikePost(user:PFUser, post:String)
    {
        let likeObject = PFObject(className: ParseClassName)
        likeObject.setObject(user, forKey: fromuser)
        likeObject.setObject(post, forKey: toPost)
        likeObject.saveInBackground()
        print("like made")
    }
    
    static func UnlikePost(user:PFUser, post:String)
    {
        let query = PFQuery(className: ParseClassName)
        query.whereKey(fromuser, equalTo: user)
        query.whereKey(toPost, equalTo: post)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil
            {
                if let results = results as [PFObject]!
                {
                    for likes in results
                    {
                        likes.deleteInBackground()
                    }
                }
            }
        }
        
        
    }
    
    static func likesforPost(post:String, completiomBlock:PFQueryArrayResultBlock)
    {
        let query = PFQuery(className: ParseClassName)
        query.whereKey(toPost, equalTo: post)
        query.includeKey(ParseClassName)
        query.findObjectsInBackgroundWithBlock(completiomBlock)
    }
    
    
   

}
