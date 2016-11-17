//
//  ManageUser.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 01/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import Parse

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/***************************************************

 IMPORTANT PLEASE READ:
 
 This class is all about user specific 
 functions such as (un)following/counts/etc.
 Please do NOT edit it as furthur work is required.

***************************************************/

// Final data array used for user 
// follower/following data methods.
var finalData:NSMutableArray = []

// ManageUser class contains all the methods
// in relations to the user account (ie: follow).
@objc class ManageUser : NSObject {
    
    // Status media data methods.
    
    class func deleteStatusUpdate(_ statusupdate: PFObject, _ viewController: AnyObject, completion: @escaping (_ deletionSuccess: Bool) -> Void ) {
        
        // Setup the status post deletion query.
        var query:PFQuery<PFObject>!
        query = PFQuery(className: "StatusUpdate")
        query.includeKey("user")
        query.whereKey("objectId", equalTo: statusupdate.objectId!)
        
        // Search for any matching status updates.
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            
            // Check for errors first.
            
            if (error == nil) {
                
                // Loop through the returned objects
                // and fine any matching status updates.
                
                for object in objects! {
                    
                    // Get the username of the user who posted the status update.
                    let userstr = (object["user"] as AnyObject).username!
                    
                    // Only allow the user to delete their own status updates.
                    
                    if (userstr == PFUser.current()?.username) {
                        
                        // Setup the extra media deletion query.
                        var queryExtraMedia:PFQuery<PFObject>!
                        queryExtraMedia = PFQuery(className: "statusMedia")
                        queryExtraMedia.whereKey("statusUpdateID", equalTo: statusupdate.objectId!)
                        
                        // Get any extra media objects.
                        queryExtraMedia.getFirstObjectInBackground(block: { (object, errorMedia: Error?) in
                            
                            // Check for errors before continuing.
                            
                            if (errorMedia == nil) {
                                
                                object?.deleteInBackground(block: { (success, error) in
                                    
                                    if ((error == nil) && (success == true)) {
                                        
                                        // Delete the main status update.
                                        statusupdate.deleteInBackground(block: { (success, error) -> Void in
                                            
                                            DispatchQueue.main.async(execute: {
                                                completion(true)
                                            })
                                        })
                                    }
                                    
                                    else {
                                        
                                        DispatchQueue.main.async(execute: {
                                            completion(true)
                                        })
                                    }
                                })
                            }
                            
                            else {
                                
                                // Delete the main status update.
                                statusupdate.deleteInBackground(block: { (success, error) -> Void in
                                    
                                    DispatchQueue.main.async(execute: {
                                        completion(true)
                                    })
                                })
                            }
                        })
                    }
                        
                    else {
                        
                        DispatchQueue.main.async(execute: {
                            
                            // Present the deletion error alert.
                            let alert = UIAlertController(title: "Error", message: "You can only delete your own posts.", preferredStyle: .alert)
                            alert.view.tintColor = UIColor.flatGreen()
                            let next = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                            alert.addAction(next)
                            viewController.present(alert, animated: true, completion:nil)
                            
                            completion(false)
                        })
                    }
                }
            }
            
            else {
                
                DispatchQueue.main.async(execute: {
                    completion(false)
                })
            }
        })
    }
    
    // Check username string methods.
    
    class func correctStringWithUsernames(_ inputString: String, completion: @escaping (_ correctString: String) -> Void) {

        DispatchQueue.main.async(execute: {
            
            // Create the final string and get all
            // the seperate strings from the data.
            var finalString: String!
            var commentSegments: NSArray!
            commentSegments = inputString.components(separatedBy: " ") as NSArray
            
            if (commentSegments.count > 0) {
                
                for loop in 0..<commentSegments.count {
                    
                    // Check the username to ensure that there
                    // are no capital letters in the string.
                    let currentString = commentSegments[loop] as! String
                    let capitalLetterRegEx  = ".*[A-Z]+.*"
                    let textData = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
                    let capitalResult = textData.evaluate(with: currentString)
                    
                    // Check if the current loop string
                    // is a @user mention string or not.
                    
                    if (currentString.contains("@")) {
                        
                        // If we are in the first loop then set the
                        // string otherwise concatenate the string.
                        
                        if (loop == 0) {
                            
                            if (capitalResult == true) {
                                
                                // The username contains capital letters
                                // so change it to a lower case version.
                                finalString = currentString.lowercased()
                            }
                                
                            else {
                                
                                // The username does not contain capital letters.
                                finalString = currentString
                            }
                        }
                            
                        else {
                            
                            if (capitalResult == true) {
                                
                                // The username contains capital letters
                                // so change it to a lower case version.
                                finalString = "\(finalString!) \(currentString.lowercased())"
                            }
                                
                            else {
                                
                                // The username does not contain capital letters.
                                finalString = "\(finalString!) \(currentString)"
                            }
                        }
                    }
                        
                    else {
                        
                        // The current string is NOT a @user mention
                        // so simply set or concatenate the finalString.
                        
                        if (loop == 0) {
                            finalString = currentString
                        }
                            
                        else {
                            finalString = "\(finalString!) \(currentString)"
                        }
                    }
                }
            }
                
            else {
                
                // No issues pass back the string.
                finalString = inputString
            }
            
            // Pass back the correct username string.
            completion(finalString!)
        })
    }
    
    // Follow/Unfollow user methods.
    
    class func followOrUnfolowUser(_ userData:PFUser, completion: @escaping (_ followUnfollowstatus: Bool, String, String) -> Void) {
        
        // Check if the logged in user is
        // already following the passed in user.
        self.alreadyFollowingUser(userData, currentUserCheckMode: true) { (followStatus, objectID) -> Void in
            
            // Get the user private profile status.
            let privateCheck = userData["privateProfile"] as! Bool
            
            // If the user is not being followed and the user is private then call
            // the follow request method otherwise continue with the follow code.
            
            if ((privateCheck == true) && (followStatus == false)) {
                
                // Submit the follow request.
                FollowRequest(userData, completion: { (requestStatus) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        
                        var messageAlert:String!
                        
                        if (requestStatus == true) {
                            messageAlert = "The follow request has been submitted. You will be able to view the users posts if they accept your request."
                        }
                        
                        else {
                            messageAlert = "The follow request has failed."
                        }
                        
                        // Set the follow request completion.
                        completion(requestStatus, messageAlert, "Follow")
                    })
                })
            }
                
            else {
                
                // Setup the follow/unfollow.
                var dataQuery:PFQuery<PFObject>!
                dataQuery = PFQuery(className: "FollowersAndFollowing")
                dataQuery.getObjectInBackground(withId: objectID, block: { (returnObject, error) -> Void in
                    
                    // Follow/unfollow alert/button string.
                    var messageAlert:String!
                    var buttonTitle:String!
                    
                    // Follow or unfollow the user depending
                    // on the current user following status.
                    
                    if (followStatus == true) {
                        
                        // Set the message string.
                        messageAlert = "The user @\(userData.username!) has been unfollowed."
                        
                        // Set the button title.
                        buttonTitle = "Follow"
                        
                        // Unfollow the user account.
                        returnObject!.remove(userData.objectId!, forKey: "userFollowing")
                    }
                        
                    else {
                        
                        // Set the message string.
                        messageAlert = "The user @\(userData.username!) has been followed."
                        
                        // Set the button title.
                        buttonTitle = "Following"
                        
                        // Follow the user account.
                        returnObject!.addUniqueObject(userData.objectId!, forKey: "userFollowing")
                    }
                    
                    // Save the data for the logged in user
                    // and the other (un)followed user.
                    returnObject!.saveInBackground(block: { (success, error) -> Void in
                        
                        if (success) {
                            
                            // Update the follow/unfollow data for the other user.
                            self.updateOtherUserData(userData, followType: followStatus, completion: { (updateUserStatus) -> Void in
                                
                                // Send a push notification if the
                                // user follow request has worked.
                                
                                if (followStatus == false) {
                                    
                                    // Create the push notification message.
                                    let pushMessage = "\(PFUser.current()!.username!) has followed you."
                                    
                                    // Submit the push notification.
                                    PFCloud.callFunction(inBackground: "FollowersAndFollowing", withParameters: ["message" : pushMessage, "user" : "\(userData.objectId!)"])
                                    
                                    // Save the push notification string on the notification class.
                                    self.saveUserNotification(pushMessage, fromUser: PFUser.current()!, toUser: userData, extType: "user", extObjectID: "n/a")
                                }
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    // The follow/unfollow operation has succeded.
                                    completion(updateUserStatus, messageAlert, buttonTitle)
                                })
                            })
                        }
                            
                        else {
                            
                            DispatchQueue.main.async(execute: {
                                
                                // The follow/unfollow operation has failed.
                                completion(false, (error?.localizedDescription)!, buttonTitle)
                            })
                        }
                    })
                })
            }
        }
    }
    
    class func updateOtherUserData(_ userData:PFUser, followType:Bool, completion: @escaping (_ updateUserStatus: Bool) -> Void) {
        
        // Get the passed in users following/followers
        // row objectID and add the new 'followers' data.
        self.alreadyFollowingUser(userData, currentUserCheckMode: false) { (status, objectID) -> Void in
            
            // Setup the follow/unfollow request.
            var dataQuery:PFQuery<PFObject>!
            dataQuery = PFQuery(className: "FollowersAndFollowing")
            dataQuery.getObjectInBackground(withId: objectID, block: { (returnObject, error) -> Void in
                
                // Add or remove the new follower depending on
                // the current status of the 'followers' array.
                
                if (followType == true) {
                    
                    // Remove the follower.
                    returnObject!.remove(PFUser.current()!.objectId!, forKey: "userFollowers")
                }
                    
                else {
                    
                    // Add the user as a new follower.
                    returnObject!.addUniqueObject(PFUser.current()!.objectId!, forKey: "userFollowers")
                }
                
                // Save the data for the passed in user.
                returnObject!.saveInBackground(block: { (success, error) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        completion(success)
                    })
                })
            })
        }
    }
    
    class func acceptFollowRequest(_ requester:PFUser, completion: @escaping (_ followSuccess: Bool, _ error: String) -> Void) {
        
        // Get the logged in users follower array data.
        var currentUserQuery:PFQuery<PFObject>!
        currentUserQuery = PFQuery(className: "FollowersAndFollowing")
        currentUserQuery.whereKey("userLink", equalTo: PFUser.current()!)
        currentUserQuery.getFirstObjectInBackground { (currentUserObject, error) -> Void in
            
            // Add the requester to the logged in user's followers array.
            currentUserObject!.addUniqueObject(requester.objectId!, forKey: "userFollowers")
            
            // Save the new follower to the data array.
            currentUserObject!.saveInBackground(block: { (success, error) -> Void in
                
                // Get the requesters following array data.
                var requesterQuery:PFQuery<PFObject>!
                requesterQuery = PFQuery(className: "FollowersAndFollowing")
                requesterQuery.whereKey("userLink", equalTo: requester)
                requesterQuery.getFirstObjectInBackground(block: { (requesterObject, requesrtError) -> Void in
                    
                    // Add the logged in user as a user
                    // that the requester is now following.
                    requesterObject!.addUniqueObject(PFUser.current()!.objectId!, forKey: "userFollowing")
                    
                    // Save the new following to the requesters data array.
                    requesterObject!.saveInBackground(block: { (success, error) -> Void in
                        
                        DispatchQueue.main.async(execute: {
                            
                            if (error == nil) {
                                completion(success, "n/a")
                            }
                            
                            else {
                                completion(success, (requesrtError?.localizedDescription)!)
                            }
                        })
                    })
                })
                
            })
        }
    }
    
    // User notification save method.
    
    class func saveUserNotification(_ notifcation:String, fromUser:PFUser, toUser:PFUser, extType:String, extObjectID:String) {
        
        // Only save the notification if the user recieving
        // the notification is NOT the same as the logged in user.
        
        if (fromUser.objectId != toUser.objectId) {
            
            // Get the notifications object for the
            // currently logged in user account.
            var notificationQuery:PFQuery<PFObject>!
            notificationQuery = PFQuery(className: "userNotifications")
            notificationQuery.whereKey("userLink", equalTo: toUser)
            notificationQuery.getFirstObjectInBackground { (object, error) -> Void in
                
                // Check for errors before continuing.
                
                if (error == nil) {
                    
                    // Add the from user object.
                    object?.add(fromUser, forKey: "fromUser")
                    
                    // Add the new notification.
                    object?.add(notifcation, forKey: "notificationStrings")
                    
                    // Add the external object ID - if the
                    // ID is set to "n/a" - it wont be used by
                    // the notifications view conroller.
                    object?.add([extType, extObjectID], forKey: "extLink")
                    
                    // Save the notification data.
                    object?.saveInBackground()
                }
            }
        }
    }
    
    class func getUserNotifications(_ userData:PFUser, completion: @escaping (_ notificationFromUser: NSArray, _ notificationStrings: NSArray, _ extLinks: NSArray) -> Void) {
        
        // Get the notifications for a particular user.
        var notificationQuery:PFQuery<PFObject>!
        notificationQuery = PFQuery(className: "userNotifications")
        notificationQuery.whereKey("userLink", equalTo: userData)
        notificationQuery.limit = 30
        notificationQuery.getFirstObjectInBackground { (object, error) -> Void in
            
            // Check for errors before continuing.
            
            if (error == nil) {
                
                // Pass the data back if correctly loaded.
                DispatchQueue.main.async(execute: {
                    completion((object?.value(forKey: "fromUser"))! as! NSArray, (object?.value(forKey: "notificationStrings"))! as! NSArray, (object?.value(forKey: "extLink"))! as! NSArray)
                })
            }
        }
    }
    
    // User follower/following data.
    
    class func checkFollowRequest(_ toUser:PFUser , completion: @escaping (_ requestCheck: Bool) -> Void) {
        
        // Check if the "toUser" has a follow
        // request from the logged in user.
        var requestCheck:PFQuery<PFObject>!
        requestCheck = PFQuery(className: "FollowRequest")
        requestCheck.whereKey("Requester", equalTo: PFUser.current()!)
        requestCheck.whereKey("desiredfollower", equalTo: toUser)
        requestCheck.getFirstObjectInBackground { (object, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                // If the follow request has been made
                // return true otherwise return false.
                
                if (object == nil) {
                    completion(false)
                }
                
                else {
                    completion(true)
                }
            })
        }
    }
    
    @objc class func getUserFollowersList(_ userData:PFUser , completion: @escaping (_ userFollowers: NSMutableArray) -> Void) {
        
        // Get the user followers data.
        self.downloadFFClassData(userData, includeCurrentUser: false, type: 1) { (userFollowData) -> Void in
            
            DispatchQueue.main.async(execute: {
                completion(userFollowData)
            })
        }
    }
    
    class func getUserFollowingList(_ userData:PFUser, withCurrentUser:Bool , completion: @escaping (_ userFollowing: NSMutableArray) -> Void) {
        
        // Get the user following data.
        self.downloadFFClassData(userData, includeCurrentUser: withCurrentUser, type: 2) { (userFollowData) -> Void in
            
            DispatchQueue.main.async(execute: {
                completion(userFollowData)
            }) 
        }
    }
    
    class func downloadFFClassData(_ userData:PFUser, includeCurrentUser:Bool, type:Int, completion: @escaping (_ userFollowData: NSMutableArray) -> Void) {
        
        // Setup following query.
        var queryFollowData:PFQuery<PFObject>!
        queryFollowData = PFQuery(className: "FollowersAndFollowing")
        queryFollowData.order(byDescending: "createdAt")
        queryFollowData.addDescendingOrder("updatedAt")
        queryFollowData.whereKey("userLink", equalTo: userData)
        
        queryFollowData.getFirstObjectInBackground { (objects, error) in
            
            // Clear the user data array.
            finalData = NSMutableArray()
            
            if (error == nil) {
                
                // Create the following list.
                var followData:Array<String>!
                
                // Get the appropriate data depending
                // on the passed in data type integer.
                
                if (type == 1) {
                    
                    // Get the followers information.
                    followData = objects!.value(forKey: "userFollowers") as! Array<String>!
                }
                    
                else if (type == 2) {
                    
                    // Get the following information.
                    followData = objects!.value(forKey: "userFollowing") as! Array<String>!
                }
                
                // User data download loop count.
                var downloadCount = 0;
                
                // Loop through the Object IDs and
                // convert them to PFUser objects.
                
                for loop in 0..<followData.count {
                    
                    // Convert the object IDs to PFUser objects.
                    var queryUser:PFQuery<PFObject>!
                    queryUser = PFUser.query()
                    queryUser.whereKey("objectId", equalTo: followData[loop] as String)
                    
                    // Perform the object ID request.
                    queryUser.getFirstObjectInBackground(block: { (userObject, error) -> Void in
                        
                        // Pass the data back if correctly loaded.
                        DispatchQueue.main.async(execute: {
                            
                            // Increment the download user count.
                            downloadCount = downloadCount + 1
                            
                            // Add the correct data in.
                            
                            if ((error == nil) && (userObject != nil)) {
                                finalData.add(userObject as! PFUser)
                            }
                            
                            // If the download count matches the user array count
                            // then we have downloaded the user data objects.
                            
                            if (downloadCount == followData.count) {
                                
                                // Add other data if we are retreving
                                // following data instead of followers.
                                
                                if (includeCurrentUser == true) {
                                    
                                    // Add in the logged in user (for the newsfeed).
                                    finalData.add(PFUser.current()!)
                                }
                                
                                // Send back the follow data array.
                                completion(finalData)
                            }
                        })
                    })
                }
            } else {
                
                // Send back the follow data array.
                completion(finalData)
            }
        }
    }
    
    // User object ID methods.
    
    class func getObjectIDForFFClass(_ userData:PFUser, completion: @escaping (_ idNumber: String) -> Void) {
        
        // Get the ObjectID for one of the
        // following/followers rows.
        var queryID:PFQuery<PFObject>!
        queryID = PFQuery(className: "FollowersAndFollowing")
        queryID.whereKey("userLink", equalTo: userData)
        
        // Perform the object ID request.
        queryID.findObjectsInBackground { (objects, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                completion((objects?[0].objectId)!)
            })
        }
    }
    
    // Already following user check method.
    
    class func alreadyFollowingUser(_ userData:PFUser, currentUserCheckMode:Bool, completion: @escaping (_ status: Bool, String) -> Void) {
        
        // Check if the logged in user is already
        // following the passed in user object.
        var queryFollowing:PFQuery<PFObject>!
        queryFollowing = PFQuery(className: "FollowersAndFollowing")
        
        // Set the query keys depending on whether
        // we are checking in the logged in user is
        // following someone OR if someone else is 
        // already following the logged in user.
        
        if (currentUserCheckMode == true) {
            
            queryFollowing.whereKey("userFollowing", containsAllObjectsIn: [userData.objectId!])
            queryFollowing.whereKey("userLink", equalTo: PFUser.current()!)
        }
        
        else {
            
            queryFollowing.whereKey("userFollowing", containsAllObjectsIn: [(PFUser.current()?.objectId)!])
            queryFollowing.whereKey("userLink", equalTo: userData)
        }
    
        queryFollowing.findObjectsInBackground { (objects, error) -> Void in
            
            // Check if an error has occurred.
            
            if (error == nil) {
                
                // If the user is already being followed
                // then set compeltion to true otherwise 
                // set completion bool to false.
                
                if (objects?.count > 0) {
                    
                    DispatchQueue.main.async(execute: {
                        completion(true, (objects?[0].objectId)!)
                    })
                }
                    
                else {
                    
                    self.getObjectIDForFFClass((currentUserCheckMode ? PFUser.current()! : userData), completion: { (idNumber) -> Void in
                        
                        DispatchQueue.main.async(execute: {
                            completion(false, idNumber)
                        })
                    })
                }
            }
        }
    }
    
    // User data count methods.
    
    class func getFollowDataCount(_ userData: PFUser, completion:@escaping (_ countObject: PFObject) -> Void) {
        
        // Get the follower/following count for the user.
        var queryObjectID:PFQuery<PFObject>!
        queryObjectID = PFQuery(className: "FollowersAndFollowing")
        queryObjectID.whereKey("userLink", equalTo: userData)
        queryObjectID.findObjectsInBackground { (objects, error) -> Void in
            
            // Check if an error has occured.
            
            if (error == nil) {
                
                // Get the data object which relates to the 
                // correct user in the FollowersAndFollowing class.
                var dataQuery:PFQuery<PFObject>!
                dataQuery = PFQuery(className: "FollowersAndFollowing")
                dataQuery.getObjectInBackground(withId: (objects?[0].objectId)!, block: { (returnObject, error) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        completion(returnObject!)
                    })
                })
            }
        }
    }
}


// Follow request function.

func FollowRequest(_ userData:PFUser, completion:@escaping (_ requestStatus: Bool) -> Void) {
    
    // Check if the request has already been made.
    var followQuery:PFQuery<PFObject>!
    followQuery = PFQuery(className: "FollowRequest")
    followQuery.whereKey("Requester", equalTo: PFUser.current()!)
    followQuery.whereKey("desiredfollower", equalTo: userData)
    followQuery.getFirstObjectInBackground { (object, error) -> Void in
        
        // Check if the request already exists.
        
        if (object == nil) {
            
            // Setup the expiry date limit (+1 month).
            var dateCommpoents:DateComponents!
            dateCommpoents = DateComponents()
            dateCommpoents.month = 1
            
            // Get the current calendar data.
            var calendar: Calendar!
            calendar = Calendar.current
            
            // Set the expiry date to 30 days from the current date.
            var expireDate:Date!
            expireDate = calendar.date(byAdding: dateCommpoents, to: Date())
            
            // Convert the date into a more reaable form
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.dateFormat = "M/d/yy"
            
            // Create the human readable date string.
            let readableDate = dateFormatter.string(from: expireDate)
            
            // Create user follow request object.
            var followRequest:PFObject!
            followRequest = PFObject(className: "FollowRequest")
            followRequest["Requester"] = PFUser.current()
            followRequest["desiredfollower"] = userData
            followRequest["expiredate"] = readableDate
            
            // Save the follow request on Parse.
            followRequest.saveInBackground(block: { (success, error) -> Void in
                
                // Create the push notification message.
                let pushMessage = "\(PFUser.current()!.username!) would like to follow you."
                
                // Submit the push notification.
                PFCloud.callFunction(inBackground: "FollowersAndFollowing", withParameters: ["message" : pushMessage, "user" : "\(userData.objectId!)"])
                
                // Save the push notification string on the notification class.
                ManageUser.saveUserNotification(pushMessage, fromUser: PFUser.current()!, toUser: userData, extType: "user", extObjectID: "user")
                
                DispatchQueue.main.async(execute: {
                    completion(success)
                })
            })
        }
            
        else {
            
            // The request already exists so lets pass back true
            // so that the user knows their request has been made.
            DispatchQueue.main.async(execute: {
                completion(true)
            })
        }
    }
}
