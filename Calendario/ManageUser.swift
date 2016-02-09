//
//  ManageUser.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 01/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import Parse

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
    
    // Follow/Unfollow user methods.
    
    class func followOrUnfolowUser(userData:PFUser, completion: (followUnfollowstatus: Bool, String, String) -> Void) {
        
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
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        var messageAlert:String!
                        
                        if (requestStatus == true) {
                            messageAlert = "The follow request has been submitted. You will be able to view the users posts if they accept your request."
                        }
                        
                        else {
                            messageAlert = "The follow request has failed."
                        }
                        
                        // Set the follow request completion.
                        completion(followUnfollowstatus: requestStatus, messageAlert, "Follow")
                    })
                })
            }
                
            else {
                
                // Setup the follow/unfollow.
                var dataQuery:PFQuery!
                dataQuery = PFQuery(className: "FollowersAndFollowing")
                dataQuery.getObjectInBackgroundWithId(objectID, block: { (returnObject, error) -> Void in
                    
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
                        returnObject!.removeObject(userData.objectId!, forKey: "userFollowing")
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
                    returnObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        if (success) {
                            
                            // Update the follow/unfollow data for the other user.
                            self.updateOtherUserData(userData, followType: followStatus, completion: { (updateUserStatus) -> Void in
                                
                                // Send a push notification if the
                                // user follow request has worked.
                                
                                if (followStatus == false) {
                                    
                                    // Create the push notification message.
                                    let pushMessage = "\(PFUser.currentUser()!.username!) has followed you."
                                    
                                    // Submit the push notification.
                                    PFCloud.callFunctionInBackground("FollowersAndFollowing", withParameters: ["message" : pushMessage, "User" : "\(userData.username!)"])
                                    
                                    // Save the push notification string on the notification class.
                                    self.saveUserNotification(pushMessage, fromUser: PFUser.currentUser()!, toUser: userData, extType: "user", extObjectID: "n/a")
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    // The follow/unfollow operation has succeded.
                                    completion(followUnfollowstatus: updateUserStatus, messageAlert, buttonTitle)
                                })
                            })
                        }
                            
                        else {
                            
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                // The follow/unfollow operation has failed.
                                completion(followUnfollowstatus: false, (error?.localizedDescription)!, buttonTitle)
                            })
                        }
                    })
                })
            }
        }
    }
    
    class func updateOtherUserData(userData:PFUser, followType:Bool, completion: (updateUserStatus: Bool) -> Void) {
        
        // Get the passed in users following/followers
        // row objectID and add the new 'followers' data.
        self.alreadyFollowingUser(userData, currentUserCheckMode: false) { (status, objectID) -> Void in
            
            // Setup the follow/unfollow request.
            var dataQuery:PFQuery!
            dataQuery = PFQuery(className: "FollowersAndFollowing")
            dataQuery.getObjectInBackgroundWithId(objectID, block: { (returnObject, error) -> Void in
                
                // Add or remove the new follower depending on
                // the current status of the 'followers' array.
                
                if (followType == true) {
                    
                    // Remove the follower.
                    returnObject!.removeObject(PFUser.currentUser()!.objectId!, forKey: "userFollowers")
                }
                    
                else {
                    
                    // Add the user as a new follower.
                    returnObject!.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "userFollowers")
                }
                
                // Save the data for the passed in user.
                returnObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(updateUserStatus: success)
                    })
                })
            })
        }
    }
    
    class func acceptFollowRequest(requester:PFUser, completion: (followSuccess: Bool, error: String) -> Void) {
        
        // Get the logged in users follower array data.
        var currentUserQuery:PFQuery!
        currentUserQuery = PFQuery(className: "FollowersAndFollowing")
        currentUserQuery.whereKey("userLink", equalTo: PFUser.currentUser()!)
        currentUserQuery.getFirstObjectInBackgroundWithBlock { (currentUserObject, error) -> Void in
            
            // Add the requester to the logged in user's followers array.
            currentUserObject!.addUniqueObject(requester.objectId!, forKey: "userFollowers")
            
            // Save the new follower to the data array.
            currentUserObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                // Get the requesters following array data.
                var requesterQuery:PFQuery!
                requesterQuery = PFQuery(className: "FollowersAndFollowing")
                requesterQuery.whereKey("userLink", equalTo: requester)
                requesterQuery.getFirstObjectInBackgroundWithBlock({ (requesterObject, requesrtError) -> Void in
                    
                    // Add the logged in user as a user
                    // that the requester is now following.
                    requesterObject!.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "userFollowing")
                    
                    // Save the new following to the requesters data array.
                    requesterObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if (error == nil) {
                                completion(followSuccess: success, error: "n/a")
                            }
                            
                            else {
                                completion(followSuccess: success, error: (requesrtError?.localizedDescription)!)
                            }
                        })
                    })
                })
                
            })
        }
    }
    
    // User notification save method.
    
    class func saveUserNotification(notifcation:String, fromUser:PFUser, toUser:PFUser, extType:String, extObjectID:String) {
        
        // Only save the notification if the user recieving
        // the notification is NOT the same as the logged in user.
        
        if (fromUser.objectId != toUser.objectId) {
            
            // Get the notifications object for the
            // currently logged in user account.
            var notificationQuery:PFQuery!
            notificationQuery = PFQuery(className: "userNotifications")
            notificationQuery.whereKey("userLink", equalTo: toUser)
            notificationQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
                
                // Check for errors before continuing.
                
                if (error == nil) {
                    
                    // Add the from user object.
                    object?.addObject(fromUser, forKey: "fromUser")
                    
                    // Add the new notification.
                    object?.addObject(notifcation, forKey: "notificationStrings")
                    
                    // Add the external object ID - if the
                    // ID is set to "n/a" - it wont be used by
                    // the notifications view conroller.
                    object?.addObject([extType, extObjectID], forKey: "extLink")
                    
                    // Save the notification data.
                    object?.saveInBackground()
                }
            }
        }
    }
    
    class func getUserNotifications(userData:PFUser, completion: (notificationFromUser: NSArray, notificationStrings: NSArray, extLinks: NSArray) -> Void) {
        
        // Get the notifications for a particular user.
        var notificationQuery:PFQuery!
        notificationQuery = PFQuery(className: "userNotifications")
        notificationQuery.whereKey("userLink", equalTo: userData)
        notificationQuery.limit = 30
        notificationQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
            
            // Check for errors before continuing.
            
            if (error == nil) {
                
                // Pass the data back if correctly loaded.
                dispatch_async(dispatch_get_main_queue(), {
                    completion(notificationFromUser: (object?.valueForKey("fromUser"))! as! NSArray, notificationStrings: (object?.valueForKey("notificationStrings"))! as! NSArray, extLinks: (object?.valueForKey("extLink"))! as! NSArray)
                })
            }
        }
    }
    
    // User follower/following data.
    
    @objc class func getUserFollowersList(userData:PFUser , completion: (userFollowers: NSMutableArray) -> Void) {
        
        // Get the user followers data.
        self.downloadFFClassData(userData, type: 1) { (userFollowData) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(userFollowers: userFollowData)
            })
        }
    }
    
    class func getUserFollowingList(userData:PFUser , completion: (userFollowing: NSMutableArray) -> Void) {
        
        // Get the user following data.
        self.downloadFFClassData(userData, type: 2) { (userFollowData) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(userFollowing: userFollowData)
            }) 
        }
    }
    
    class func downloadFFClassData(userData:PFUser, type:Int, completion: (userFollowData: NSMutableArray) -> Void) {
        
        // Get the Object ID for passed in user and then use that
        // to get the user's followers or following data array.
        self.getObjectIDForFFClass(userData) { (idNumber) -> Void in
            
            // Setup following query.
            var queryFollowData:PFQuery!
            queryFollowData = PFQuery(className: "FollowersAndFollowing")
            
            // Get the follow list.
            queryFollowData.getObjectInBackgroundWithId(idNumber, block: { (objects, error) -> Void in
                
                // Create the following list.
                var followData:Array<String>!
                
                // Get the appropriate data depending
                // on the passed in data type integer.
                
                if (type == 1) {
                    
                    // Get the followers information.
                    followData = objects!.valueForKey("userFollowers") as! Array<String>!
                }
                
                else if (type == 2) {
                    
                    // Get the following information.
                    followData = objects!.valueForKey("userFollowing") as! Array<String>!
                }
                
                // Clear the user data array.
                finalData = NSMutableArray()
                
                // Loop through the Object IDs and
                // convert them to PFUser objects.
                
                for (var loop = 0; loop < followData.count; loop++) {
                    
                    // Convert the object IDs to PFUser objects.
                    var queryUser:PFQuery!
                    queryUser = PFUser.query()
                    queryUser.whereKey("objectId", equalTo: followData[loop])
                    
                    // Perform the object ID request.
                    queryUser.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                        
                        // Pass the data back if correctly loaded.
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // Add the correct data in.
                            finalData.addObject(userObject as! PFUser)
                            
                            if (finalData.count == followData.count) {
                                
                                // Add other data if we are retreving
                                // following data instead of followers.
                                
                                if (type == 2) {
                                    
                                    // As per Derek's request add the logged
                                    // in user to the following data array.
                                    finalData.addObject(PFUser.currentUser()!)
                                }
                                
                                // Send back the follow data array.
                                completion(userFollowData: finalData) // bug occured here during pull to refresh
                            }
                        })
                    })
                }
            })
        }
    }
    
    // User object ID methods.
    
    class func getObjectIDForFFClass(userData:PFUser, completion: (idNumber: String) -> Void) {
        
        // Get the ObjectID for one of the 
        // following/followers rows.
        var queryID:PFQuery!
        queryID = PFQuery(className: "FollowersAndFollowing")
        queryID.whereKey("userLink", equalTo: userData)
        
        // Perform the object ID request.
        queryID.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(idNumber: (objects?[0].objectId)!) // bug here
            })
        }
    }
    
    // Already following user check method.
    
    class func alreadyFollowingUser(userData:PFUser, currentUserCheckMode:Bool, completion: (status: Bool, String) -> Void) {
        
        // Check if the logged in user is already
        // following the passed in user object.
        var queryFollowing:PFQuery!
        queryFollowing = PFQuery(className: "FollowersAndFollowing")
        
        // Set the query keys depending on whether
        // we are checking in the logged in user is
        // following someone OR if someone else is 
        // already following the logged in user.
        
        if (currentUserCheckMode == true) {
            
            queryFollowing.whereKey("userFollowing", containsAllObjectsInArray: [userData.objectId!])
            queryFollowing.whereKey("userLink", equalTo: PFUser.currentUser()!)
        }
        
        else {
            
            queryFollowing.whereKey("userFollowing", containsAllObjectsInArray: [(PFUser.currentUser()?.objectId)!])
            queryFollowing.whereKey("userLink", equalTo: userData)
        }
    
        queryFollowing.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            // Check if an error has occurred.
            
            if (error == nil) {
                
                // If the user is already being followed
                // then set compeltion to true otherwise 
                // set completion bool to false.
                
                if (objects?.count > 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(status: true, (objects?[0].objectId)!)
                    })
                }
                    
                else {
                    
                    self.getObjectIDForFFClass((currentUserCheckMode ? PFUser.currentUser()! : userData), completion: { (idNumber) -> Void in
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(status: false, idNumber)
                        })
                    })
                }
            }
        }
    }
    
    // User data count methods.
    
    class func getUserPostCount(userData:PFUser, completion: (result: Int) -> Void) {
        
        // Get the user posts number count.
        var queryPosts:PFQuery!
        queryPosts = PFQuery(className: "StatusUpdate")
        queryPosts.whereKey("user", equalTo: userData)
        queryPosts.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            // If an error has occured we will return 0 posts however 
            // if no error is returned we will return the post count.
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if (error == nil) {
                    
                    // Check if any objects matching
                    // the passed in user are present.
                    
                    if let objects = objects as [PFObject]! {
                        
                        // Get the posts count information.
                        completion(result: objects.count)
                    }
                        
                    else {
                        
                        // No posts have been found.
                        completion(result: 0)
                    }
                }
                    
                else {
                    
                    // An error has occured return 0.
                    completion(result: 0)
                }
            })
        }
    }
    
    class func getFollowDataCount(userData: PFUser, completion:(countObject: PFObject) -> Void) {
        
        // Get the follower/following count for the user.
        var queryObjectID:PFQuery!
        queryObjectID = PFQuery(className: "FollowersAndFollowing")
        queryObjectID.whereKey("userLink", equalTo: userData)
        queryObjectID.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            // Check if an error has occured.
            
            if (error == nil) {
                
                // Get the data object which relates to the 
                // correct user in the FollowersAndFollowing class.
                var dataQuery:PFQuery!
                dataQuery = PFQuery(className: "FollowersAndFollowing")
                dataQuery.getObjectInBackgroundWithId((objects?[0].objectId)!, block: { (returnObject, error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(countObject: returnObject!)
                    })
                })
            }
        }
    }
}


// Follow request function.

func FollowRequest(userData:PFUser, completion:(requestStatus: Bool) -> Void) {
    
    // Check if the request has already been made.
    var followQuery:PFQuery!
    followQuery = PFQuery(className: "FollowRequest")
    followQuery.whereKey("Requester", equalTo: PFUser.currentUser()!)
    followQuery.whereKey("desiredfollower", equalTo: userData)
    followQuery.getFirstObjectInBackgroundWithBlock { (object, error) -> Void in
        
        // Check if the request already exists.
        
        if (object == nil) {
            
            // Setup the expiry date limit (+1 month).
            var dateCommpoents:NSDateComponents!
            dateCommpoents = NSDateComponents()
            dateCommpoents.month = 1
            
            // Get the current calendar data.
            var calendar: NSCalendar!
            calendar = NSCalendar.currentCalendar()
            
            // Set the expiry date to 30 days from the current date.
            var expireDate:NSDate!
            expireDate = calendar.dateByAddingComponents(dateCommpoents, toDate: NSDate(), options: NSCalendarOptions())!
            
            // Convert the date into a more reaable form
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateFormatter.dateFormat = "M/d/yy"
            
            // Create the human readable date string.
            let readableDate = dateFormatter.stringFromDate(expireDate)
            
            // Create user follow request object.
            var followRequest:PFObject!
            followRequest = PFObject(className: "FollowRequest")
            followRequest["Requester"] = PFUser.currentUser()
            followRequest["desiredfollower"] = userData
            followRequest["expiredate"] = readableDate
            
            // Save the follow request on Parse.
            followRequest.saveInBackgroundWithBlock({ (success, error) -> Void in
                
                // Create the push notification message.
                let pushMessage = "\(PFUser.currentUser()!.username!) would like to follow you."
                
                // Submit the push notification.
                PFCloud.callFunctionInBackground("FollowersAndFollowing", withParameters: ["message" : pushMessage, "User" : "\(userData.username!)"])
                
                // Save the push notification string on the notification class.
                ManageUser.saveUserNotification(pushMessage, fromUser: PFUser.currentUser()!, toUser: userData, extType: "user", extObjectID: "user")
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(requestStatus: success)
                })
            })
        }
            
        else {
            
            // The request already exists so lets pass back true
            // so that the user knows their request has been made.
            dispatch_async(dispatch_get_main_queue(), {
                completion(requestStatus: true)
            })
        }
    }
}
