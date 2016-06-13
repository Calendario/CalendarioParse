//
//  ParseCalls.swift
//  Calendario
//
//  Created by Brian King on 3/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

public class ParseCalls: NSObject {
    
    class func findUserDetails(passedObject: PFObject, usernameLabel: UILabel, profileImageView: UIImageView) {
        
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: (passedObject.objectForKey("user")?.objectId)!)
        
        // Download the user detials.
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                usernameLabel.text = userObject?.username
                
                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                let userImageFile = userObject!["profileImage"] as! PFFile
                
                // Download the profile image.
                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (imageData != nil)) {
                        profileImage = UIImage(data: imageData!)
                    }
                    profileImageView.image = profileImage
                }
            }
        }
        
    }
    
    class func checkForUserPostedImage(imageView: UIImageView, passedObject: PFObject, cell: NewsfeedTableViewCell) {
        
        if (passedObject.objectForKey("image") == nil) {
            imageView.image = nil
            cell.userImageViewContainerHeightContstraint.constant = 0
            cell.layoutIfNeeded()
            cell.updateConstraintsIfNeeded()
        } else {
            
            // Setup the user profile image file.
            let statusImage = passedObject["image"] as! PFFile
            
            // Download the profile image.
            statusImage.getDataInBackgroundWithBlock { (mediaData: NSData?, error: NSError?) -> Void in
                
                if ((error == nil) && (mediaData != nil)) {
                    imageView.image = UIImage(data: mediaData!)
                    cell.userImageViewContainerHeightContstraint.constant = 205
                }
                
                else {
                    imageView.image = nil
                    cell.userImageViewContainerHeightContstraint.constant = 0
                }
                
                cell.layoutIfNeeded()
                cell.updateConstraintsIfNeeded()
            }
        }
    }
    
    class func updateCommentsLabel(commentsLabel: UILabel, passedObject: PFObject) {
        var commentsquery:PFQuery!
        commentsquery = PFQuery(className: "comment")
        commentsquery.orderByAscending("createdAt")
        commentsquery.addAscendingOrder("updatedAt")
        commentsquery.whereKey("statusOBJID", equalTo: passedObject.objectId!)
        commentsquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                if (objects!.count == 1) {
                    commentsLabel.text = "1 comment"
                }
                else {
                    commentsLabel.text = "\(String(objects!.count)) comments"
                }
            }
            else {
                commentsLabel.text = "0 comments"
            }
        }
    }
}
