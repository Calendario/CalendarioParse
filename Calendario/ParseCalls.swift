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
    
    class func checkForUserPostedImage(imageView: UIImageView, passedObject: PFObject, animatedConstraint: NSLayoutConstraint, cell: UITableViewCell) {
        if (passedObject.objectForKey("image") == nil) {
            imageView.alpha = 0.0
            animatedConstraint.constant = 1
            cell.updateConstraintsIfNeeded()
        }
        else {
            // Show the Media image view.
            imageView.alpha = 1.0
            animatedConstraint.constant = 127
            cell.updateConstraintsIfNeeded()
            
            // Setup the user profile image file.
            let statusImage = passedObject["image"] as! PFFile
            
            // Download the profile image.
            statusImage.getDataInBackgroundWithBlock { (mediaData: NSData?, error: NSError?) -> Void in
                if ((error == nil) && (mediaData != nil)) {
                    imageView.image = UIImage(data: mediaData!)
                }
                else {
                    imageView.image = UIImage(imageLiteral: "no-image-icon + Rectangle 4")
                }
            }
        }
    }
    
    class func updateCommentsLabel(commentsLabel: UILabel, passedObject: PFObject) {
        var commentsquery:PFQuery!
        commentsquery = PFQuery(className: "comment")
        commentsquery.orderByDescending("createdAt")
        commentsquery.addDescendingOrder("updatedAt")
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
