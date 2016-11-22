//
//  ParseCalls.swift
//  Calendario
//
//  Created by Brian King on 3/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

open class ParseCalls: NSObject {
    
    class func findUserDetails(_ passedObject: PFObject, usernameLabel: UILabel, profileImageView: UIImageView) {
        
        // Setup the user details query.
        var findUser:PFQuery<PFObject>!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: ((passedObject.object(forKey: "user") as! PFObject).objectId)!)
        
        // Download the user details.
        findUser.findObjectsInBackground { (objects:[PFObject]?, error: Error?) in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                usernameLabel.text = userObject?.username
                
                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                if let userImageFile = userObject!["profileImage"] {
                    
                    // Download the profile image.
                    (userImageFile as AnyObject).getDataInBackground(block: { (imageData: Data?, error: Error?) in
                        
                        if ((error == nil) && (imageData != nil)) {
                            profileImage = UIImage(data: imageData!)
                        }
                        profileImageView.image = profileImage
                    })
                } else {
                    profileImageView.image = profileImage
                }
            }
        }
    }
    
    class func checkForUserPostedMedia(passedObject: PFObject, imageViewTwo: UIImageView, imageViewThree: UIImageView, completion: @escaping (_ extraImageNum: Int) -> Void) {
        
        // Setup the media details query.
        var findMedia:PFQuery<PFObject>!
        findMedia = PFQuery(className: "statusMedia")
        findMedia.whereKey("statusUpdateID", equalTo: passedObject.objectId!)
        
        // Download the media data.
        findMedia.getFirstObjectInBackground { (object:PFObject?, error: Error?) in
            
            if (error == nil) {
                
                if object?.value(forKey: "imageDataTwo") != nil {
                    
                    // Setup the user profile image file.
                    let statusImageTwo = object?["imageDataTwo"] as! PFFile
                    
                    // Download the profile image.
                    statusImageTwo.getDataInBackground(block: { (mediaDataTwo: Data?, errorTwo: Error?) in
                        
                        if ((errorTwo == nil) && (mediaDataTwo != nil)) {
                            
                            imageViewTwo.image = UIImage(data: mediaDataTwo!)
                            
                            if object?.value(forKey: "imageDataThree") != nil {
                                
                                // Setup the user profile image file.
                                let statusImageThree = object?["imageDataThree"] as! PFFile
                                
                                // Download the profile image.
                                statusImageThree.getDataInBackground(block: { (mediaDataThree: Data?, errorThree: Error?) in
                                    
                                    if ((errorThree == nil) && (mediaDataThree != nil)) {
                                        
                                        imageViewThree.image = UIImage(data: mediaDataThree!)
                                        
                                        // Return the number of set images.
                                        DispatchQueue.main.async(execute: {
                                            completion(2)
                                        })
                                    }
                                        
                                    else {
                                        
                                        imageViewThree.image = nil
                                        
                                        // Return the number of set images.
                                        DispatchQueue.main.async(execute: {
                                            completion(1)
                                        })
                                    }
                                })
                            } else {
                                
                                imageViewThree.image = nil
                                
                                // Return the number of set images.
                                DispatchQueue.main.async(execute: {
                                    completion(1)
                                })
                            }
                        }
                            
                        else {
                            
                            imageViewTwo.image = nil
                            imageViewThree.image = nil
                            
                            // Return the number of set images.
                            DispatchQueue.main.async(execute: {
                                completion(0)
                            })
                        }
                    })
                } else {
                    
                    imageViewTwo.image = nil
                    imageViewThree.image = nil
                    
                    // Return the number of set images.
                    DispatchQueue.main.async(execute: {
                        completion(0)
                    })
                }
            }
                
            else {
                
                imageViewTwo.image = nil
                imageViewThree.image = nil
                
                // Return the number of set images.
                DispatchQueue.main.async(execute: {
                    completion(0)
                })
            }
        }
    }
    
    class func checkForUserPostedImage(_ imageView: UIImageView, passedObject: PFObject, cell: NewsfeedTableViewCell, autolayoutCheck: Bool) {
        
        if (passedObject.object(forKey: "image") == nil) {
            imageView.image = nil
            
            if (autolayoutCheck == true) {
                cell.userImageViewContainerHeightContstraint.constant = 0
            }
            
            cell.layoutIfNeeded()
            cell.updateConstraintsIfNeeded()
        } else {
            
            // Setup the user profile image file.
            let statusImage = passedObject["image"] as! PFFile
            
            // Download the profile image.
            statusImage.getDataInBackground(block: { (mediaData: Data?, error: Error?) in
                
                if ((error == nil) && (mediaData != nil)) {
                    imageView.image = UIImage(data: mediaData!)
                    
                    if (autolayoutCheck == true) {
                        cell.userImageViewContainerHeightContstraint.constant = 205
                    }
                }
                    
                else {
                    imageView.image = nil
                    
                    if (autolayoutCheck == true) {
                        cell.userImageViewContainerHeightContstraint.constant = 0
                    }
                }
                
                cell.layoutIfNeeded()
                cell.updateConstraintsIfNeeded()
            })
        }
    }
    
    class func updateCommentsLabel(_ commentsLabel: UILabel, passedObject: PFObject) {
        var commentsquery:PFQuery<PFObject>!
        commentsquery = PFQuery(className: "comment")
        commentsquery.order(byAscending: "createdAt")
        commentsquery.addAscendingOrder("updatedAt")
        commentsquery.whereKey("statusOBJID", equalTo: passedObject.objectId!)
        commentsquery.findObjectsInBackground { (objects, error) -> Void in
            
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
