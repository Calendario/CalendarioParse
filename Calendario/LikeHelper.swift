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
    
    static func LikePost(_ user:PFUser, post:String)
    {
        let likeObject = PFObject(className: ParseClassName)
        likeObject.setObject(user, forKey: fromuser)
        likeObject.setObject(post, forKey: toPost)
        likeObject.saveInBackground()
    }
    
    static func UnlikePost(_ user:PFUser, post:String)
    {
        let query = PFQuery(className: ParseClassName)
        query.whereKey(fromuser, equalTo: user)
        query.whereKey(toPost, equalTo: post)
        query.findObjectsInBackground { (results, error) -> Void in
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
    
    /*static func likesforPost(_ post:String, completiomBlock:@escaping PFQueryArrayResultBlock) {
        let query = PFQuery(className: ParseClassName)
        query.whereKey(toPost, equalTo: post)
        query.includeKey(ParseClassName)
        query.findObjectsInBackground { (object: [PFObject]?, error: Error?) in
            completiomBlock(nil)
        }
    }*/
}
