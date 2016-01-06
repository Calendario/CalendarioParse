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

@objc class ManageUser : NSObject {
    
    // Follow/Unfollow user methods.
    
    class func followOrUnfolowUser(userData:PFUser, completion: (followUnfollowstatus: Bool, String, String) -> Void) {
        
        // Check if the logged in user is
        // already following the passed in user.
        self.alreadyFollowingUser(userData, currentUserCheckMode: true) { (status, objectID) -> Void in
            
            // Setup the follow/unfollow request.
            var dataQuery:PFQuery!
            dataQuery = PFQuery(className: "FollowersAndFollowing")
            dataQuery.getObjectInBackgroundWithId(objectID, block: { (returnObject, error) -> Void in
                
                // Follow/unfollow alert/button string.
                var messageAlert:String!
                var buttonTitle:String!
                
                // Follow or unfollow the user depending
                // on the current user following status.
                
                if (status == true) {
                    
                    // Set the message string.
                    messageAlert = "unfollowed"
                    
                    // Set the button title.
                    buttonTitle = "Follow"
                    
                    // Unfollow the user account.
                    returnObject!.removeObject(userData.objectId!, forKey: "userFollowing")
                }
                
                else {
                    
                    // Set the message string.
                    messageAlert = "followed"
                    
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
                        self.updateOtherUserData(userData, completion: { (updateUserStatus) -> Void in
                            
                            // Send a push notification if the
                            // user follow request has worked.
                            
                            if (status == false) {
                                
                                // Create the push notification message.s
                                let pushMessage = "\(userData.username!) has followed you."
                                
                                // Submit the push notification.
                                PFCloud.callFunctionInBackground("FollowersAndFollowing", withParameters: ["message" : pushMessage, "User" : "\(userData.username!)"])
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
                            completion(followUnfollowstatus: false, messageAlert, buttonTitle)
                        })
                    }
                })
            })
        }
    }
    
    class func updateOtherUserData(userData:PFUser, completion: (updateUserStatus: Bool) -> Void) {
        
        // Get the passed in users following/followers
        // row objectID and add the new 'followers' data.
        self.alreadyFollowingUser(userData, currentUserCheckMode: false) { (status, objectID) -> Void in
            
            // Setup the follow/unfollow request.
            var dataQuery:PFQuery!
            dataQuery = PFQuery(className: "FollowersAndFollowing")
            dataQuery.getObjectInBackgroundWithId(objectID, block: { (returnObject, error) -> Void in
                
                // Add or remove the new follower depending on
                // the current status of the 'followers' array.
                
                if (status == true) {
                    
                    // Remove the follower.
                    returnObject!.removeObject(userData.objectId!, forKey: "userFollowers")
                }
                    
                else {
                    
                    // Add the user as a new follower.
                    returnObject!.addUniqueObject(userData.objectId!, forKey: "userFollowers")
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
    
    // User follower/following data.
    
    class func getUserFollowersList(userData:PFUser , completion: (userFollowers: NSMutableArray) -> Void) {
        
        // Get the Object ID for passed in user and then
        // use that to get the user's followers data array.
        self.getObjectIDForFFClass(userData) { (idNumber) -> Void in
            
            // Setup followers query.
            var queryFollowers:PFQuery!
            queryFollowers = PFQuery(className: "FollowersAndFollowing")
            
            // Get the followers list.
            queryFollowers.getObjectInBackgroundWithId(idNumber, block: { (objects, error) -> Void in
                
                // Create the followers list.
                var followersData:Array<String>!
                
                // Get the followers information.
                followersData = objects!.valueForKey("userFollowers") as! Array<String>!
                
                // Setup the user data array.
                var finalData:NSMutableArray = []
                
                // Loop through the Object IDs and 
                // convert them to PFUser objects.
                
                for (var loop = 0; loop < followersData.count; loop++) {
                    
                    // Convert the object IDs to PFUser objects.
                    var queryUser:PFQuery!
                    queryUser = PFUser.query()
                    queryUser.whereKey("objectId", equalTo: followersData[loop])
                    
                    // Perform the object ID request.
                    queryUser.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                        
                        // Pass the data back if correctly loaded.
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // Add the correct data in.
                            finalData.addObject(userObject as! PFUser)
                            
                            if (finalData.count == followersData.count) {
                                completion(userFollowers: finalData)
                            }
                        })
                    })
                }
            })
        }
    }
    
    class func getUserFollowingList(userData:PFUser , completion: (userFollowing: NSMutableArray) -> Void) {
        
        // Get the Object ID for passed in user and then
        // use that to get the user's following data array.
        self.getObjectIDForFFClass(userData) { (idNumber) -> Void in
            
            // Setup following query.
            var queryFollowing:PFQuery!
            queryFollowing = PFQuery(className: "FollowersAndFollowing")
            
            // Get the following list.
            queryFollowing.getObjectInBackgroundWithId(idNumber, block: { (objects, error) -> Void in
                
                // Create the following list.
                var followingData:Array<String>!
                
                // Get the following information.
                followingData = objects!.valueForKey("userFollowing") as! Array<String>!
                
                // Setup the user data array.
                var finalData:NSMutableArray = []
                
                // Loop through the Object IDs and
                // convert them to PFUser objects.
                
                for (var loop = 0; loop < followingData.count; loop++) {

                    // Convert the object IDs to PFUser objects.
                    var queryUser:PFQuery!
                    queryUser = PFUser.query()
                    queryUser.whereKey("objectId", equalTo: followingData[loop])
                    
                    // Perform the object ID request.
                    queryUser.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                        
                        // Pass the data back if correctly loaded.
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            // Add the correct data in.
                            finalData.addObject(userObject as! PFUser)
                            
                            if (finalData.count == followingData.count) {
                                completion(userFollowing: finalData)
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
                completion(idNumber: (objects?[0].objectId)!)
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
