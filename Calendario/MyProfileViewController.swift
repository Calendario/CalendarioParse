//
//  MyProfileViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 30/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore

class MyProfileViewController : UIViewController {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var profVerified: UIImageView!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var profUserName: UILabel!
    @IBOutlet weak var profDesc: UITextView!
    @IBOutlet weak var profWeb: UIButton!
    @IBOutlet weak var profPosts: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileScroll: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var blockedBlurView: UIView!
    @IBOutlet weak var blockedViewDesc: UITextView!
    @IBOutlet weak var privateView: UIView!
    
    // Follow method property
    var FollowObject = FollowHelper()
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedUser:PFUser!
    
    // User block check.
    // 1 = You blocked the user.
    // 2 = User has blocked you.
    var blockCheck:Int = 0
    
    // User website link.
    var userWebsiteLink:String!
    
    // Private profile check.
    var privateCheck:Bool!
    
    // Setup the on screen button actions.
    
    @IBAction func editProfile(sender: UIButton) {
        
        // Restore the size of the edit button.
        self.restoreEditSize()
        
        // Open the appropriate section depending
        // on whether a user object has been passed in.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // No user passed in - edit current user button.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("EditView") as! EditProfileViewController
            self.presentViewController(viewC, animated: true, completion: nil)
        }
            
        else {
            
            // Follow/unfollow the passed in user.
            self.followOrUnfolowUser(passedUser)
        }
    }
    
    @IBAction func openUserWebsite(sender: UIButton) {
        
        // Check the website URL before
        // opening the web page view.
        
        if (userWebsiteLink != nil) {
            
            // Open the register view.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("WebPage") as! WebPageViewController
            viewC.passedURL = userWebsiteLink
            self.presentViewController(viewC, animated: true, completion: nil)
        }
            
        else {
            self.displayAlert("Error", alertMessage: "This user does not have a website URL.")
        }
    }
    
    @IBAction func dismissProfile(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func openSettingsOrMoreSection(sender: UIButton) {
        
        // If the current user is being displayed then show the user 
        // settings menu otherwise display the more action sheet.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // No user passed in - show the settings menu.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsViewController
            self.presentViewController(viewC, animated: true, completion: nil)
        }
            
        else {
            
            var alertDesc:String!
            var buttonOneTitle:String!
            
            if (blockCheck == 1) {
                
                alertDesc = "Unblock or report the displayed user account @(\(passedUser.username!))."
                buttonOneTitle = "Unblock User"
            }
                
            else {
                
                alertDesc = "Block or report the displayed user account @(\(passedUser.username!))."
                buttonOneTitle = "Block User"
            }
            
            // User passed in - show the more menu.
            let moreMenu = UIAlertController(title: "Options", message: alertDesc, preferredStyle: .ActionSheet)
            
            // Setup the alert actions.
            let blockUser = { (action:UIAlertAction!) -> Void in
                
                // Check if the user has already been blocked
                // and then show the appropriate actions.
                var query:PFQuery!
                query = PFQuery(className: "blockUser")
                query.whereKey("userBlock", equalTo: self.passedUser)
                query.whereKey("userBlocking", equalTo: PFUser.currentUser()!)
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    
                    if (error == nil) {
                        
                        if (objects?.count > 0) {
                            
                            // The user has already been blocked.
                            let unblockAlert = UIAlertController(title: "Unblock user?", message: "You have already blocked this user. Would you like to unblock this user?", preferredStyle: .Alert)
                            
                            // Setup the alert actions.
                            let unblockUser = { (action:UIAlertAction!) -> Void in
                                
                                // As all users are unique and there is only a 1-1
                                // relationship in each user block request we only
                                // ever need to delete the first object from the array.
                                let objects = objects as [PFObject]!
                                
                                // Submit the unblock request.
                                objects[0].deleteInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                    
                                    if (success) {
                                        
                                        // Set to check to the default.
                                        self.blockCheck = 0
                                        
                                        // The user has been unblocked.
                                        self.blockedBlurView.alpha = 0.0
                                    }
                                        
                                    else {
                                        
                                        // An error has occured.
                                        self.displayAlert("Error", alertMessage: "\(error?.description)")
                                    }
                                })
                            }
                            
                            // Setup the alert buttons.
                            let yes = UIAlertAction(title: "Yes", style: .Default, handler: unblockUser)
                            let cancel = UIAlertAction(title: "No", style: .Default, handler: nil)
                            
                            // Add the actions to the alert.
                            unblockAlert.addAction(yes)
                            unblockAlert.addAction(cancel)
                            
                            // Present the alert on screen.
                            self.presentViewController(unblockAlert, animated: true, completion: nil)
                        }
                            
                        else {
                            
                            // The user isn't currently blocked
                            // therefore proceed with blocking.
                            
                            // Set the user to block and the
                            // user which is blocking that user.
                            var blockUserData:PFObject!
                            blockUserData = PFObject(className:"blockUser")
                            blockUserData["userBlock"] = self.passedUser
                            blockUserData["userBlocking"] = PFUser.currentUser()
                            
                            // Submit the block request.
                            blockUserData.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                
                                // Check if the user block data
                                // request was succesful or not.
                                
                                if (success) {
                                    
                                    // The user has been blocked.
                                    let blockUpdate = UIAlertController(title: "Success", message: "The user has been blocked.", preferredStyle: .Alert)
                                    
                                    // Setup the alert actions.
                                    let close = { (action:UIAlertAction!) -> Void in
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                    
                                    // Setup the alert buttons.
                                    let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: close)
                                    
                                    // Add the actions to the alert.
                                    blockUpdate.addAction(dismiss)
                                    
                                    // Present the alert on screen.
                                    self.presentViewController(blockUpdate, animated: true, completion: nil)
                                }
                                    
                                else {
                                    
                                    // There was a problem, check error.description.
                                    self.displayAlert("Error", alertMessage: "\(error?.description)")
                                }
                            }
                        }
                    }
                }
            }
            
            let reportUser = { (action:UIAlertAction!) -> Void in
                
                // Open the report user view controller.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewC = storyboard.instantiateViewControllerWithIdentifier("reportUser") as! ReportUserViewController
                viewC.passedUser = self.passedUser
                self.presentViewController(viewC, animated: true, completion: nil)
            }
            
            // Setuo the alert buttons.
            let buttonOne = UIAlertAction(title: buttonOneTitle, style: .Default, handler: blockUser)
            let buttonTwo = UIAlertAction(title: "Report User", style: .Default, handler: reportUser)
            let cancel = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
            
            // Add the actions to the alert.
            moreMenu.addAction(buttonOne)
            moreMenu.addAction(buttonTwo)
            moreMenu.addAction(cancel)
            
            // Present the alert on screen.
            presentViewController(moreMenu, animated: true, completion: nil)
        }
    }

    // View Did Load method.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get the screen dimensions.
        let width = UIScreen.mainScreen().bounds.size.width
        
        // Add the blocked blur view to the view.
        blockedBlurView.frame = CGRectMake(0, 0, width, self.profileScroll.bounds.size.height)
        blockedBlurView.alpha = 0.0
        self.profileScroll.addSubview(blockedBlurView)
        
        // Add the blur to the blocked view.
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = self.blockedBlurView.bounds
        blockedBlurView.insertSubview(visualEffectView, atIndex: 0)
        
        // Add the edit button animation methods.
        self.editButton.addTarget(self, action: "makeEditSmaller", forControlEvents: .TouchDown)
        self.editButton.addTarget(self, action: "restoreEditSize", forControlEvents: .TouchCancel)
        self.editButton.addTarget(self, action: "restoreEditSize", forControlEvents: .TouchDragExit)
        
        // Turn the profile picture into a cirlce.
        self.profPicture.layer.cornerRadius = (self.profPicture.frame.size.width / 2)
        self.profPicture.clipsToBounds = true
        
        // Curve the edges of the edit button.
        self.editButton.layer.cornerRadius = 6
        self.editButton.clipsToBounds = true
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        settingsButton.enabled = false
        self.blockCheck = 0
        
        // Disable scrolling access.
        self.profileScroll.userInteractionEnabled = false
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // Allow scrolling access.
            self.profileScroll.userInteractionEnabled = true
            
            // Set the edit button text.
            self.editButton.setTitle("Edit Profile", forState: UIControlState.Normal)
            
            // Show the settings button.
            settingsButton.enabled = true
            settingsButton.image = UIImage(named: "SettingsV2.png")
            settingsButton.title = nil
            
            // Hide the back button if no
            // user has been passed in.
            
            if (passedUser == nil) {
                
                backButton.image = nil
                backButton.enabled = false
            }
                
            else {
                
                backButton.image = UIImage(named: "left_icon.png")
                backButton.enabled = true
            }
            
            // Update the rest of the profile view.
            self.updateProfileView(PFUser.currentUser()!)
        }
            
        else {
            
            // Check if the user has already been blocked
            // or if the user has blocked you and take the
            // appropriate actions.
            var query:PFQuery!
            query = PFQuery(className: "blockUser")
            query.whereKey("userBlock", equalTo: self.passedUser)
            query.whereKey("userBlocking", equalTo: PFUser.currentUser()!)
            query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if (error == nil) {
                    
                    if (objects?.count > 0) {
                        
                        // User has been blocked so
                        // display blocked blur view.
                        self.blockedBlurView.alpha = 1.0;
                        self.blockedViewDesc.text = "You have blocked this user. Tap the button in the top right hand corner to unblock."
                        self.settingsButton.enabled = true
                        self.blockCheck = 1
                    }
                    
                    else {
                        
                        var queryTwo:PFQuery!
                        queryTwo = PFQuery(className: "blockUser")
                        queryTwo.whereKey("userBlock", equalTo: PFUser.currentUser()!)
                        queryTwo.whereKey("userBlocking", equalTo: self.passedUser)
                        queryTwo.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                            
                            if (error == nil) {
                                
                                if (objects?.count > 0) {
                                    
                                    // The user has blocked you.
                                    self.blockedBlurView.alpha = 1.0
                                    self.blockedViewDesc.text = "This user has blocked you."
                                    self.blockCheck = 2
                                }
                                
                                else {
                                    
                                    // Allow access to the more button.
                                    self.settingsButton.enabled = true
                                    
                                    // Allow scrolling access.
                                    self.profileScroll.userInteractionEnabled = true
                                }
                            }
                        }
                    }
                }
            }
            
            // Check if the user is a private account.
            privateCheck = passedUser?.objectForKey("privateProfile") as? Bool
            
            // Check if the logged in user is following
            // the passed in user object or not.
            ManageUser.alreadyFollowingUser(passedUser, currentUserCheckMode: true, completion: { (status, otherData) -> Void in
                
                if (status == true) {
                    
                    // Set the edit button text.
                    self.editButton.setTitle("Following \(self.passedUser.username!)", forState: UIControlState.Normal)
                }
                
                else {
                    
                    // Set the edit button text.
                    self.editButton.setTitle("Follow \(self.passedUser.username!)", forState: UIControlState.Normal)
                    
                    // If the user is private then show
                    // the private view lock image/text.
                    
                    if (self.privateCheck == true) {
                        self.privateView.alpha = 1.0
                    }
                        
                    else {
                        self.privateView.alpha = 0.0
                    }
                }
            })
            
            // Set the back button image and display it.
            backButton.image = UIImage(named: "left_icon.png")
            backButton.enabled = true
            
            // Change the setting button to
            // the more actions button.
            settingsButton.image = nil
            settingsButton.title = "More"
            
            // Update the rest of the profile view.
            self.updateProfileView(passedUser)
        }
    }
    
    // View Did Layout Subviews method.
    
    override func viewDidLayoutSubviews() {
        
        // Calculate the appropriate scroll height.
        var scrollHeight: CGFloat = 0.0
        
        if (self.profileScroll.bounds.height > 780) {
            scrollHeight = self.profileScroll.bounds.height
        }
            
        else {
            scrollHeight = 780
        }
        
        // Setup the profile scroll view.
        self.profileScroll.scrollEnabled = true
        self.profileScroll.contentSize = CGSizeMake(self.view.bounds.width, scrollHeight)
    }
    
    // Profile data load method.
    
    func updateProfileView(userData: PFUser) {
        
        // User is logged in - get thier details and populate the UI.
        self.profName.text = userData.objectForKey("fullName") as? String
        self.profDesc.text = userData.objectForKey("userBio") as? String
        
        // Get and set the followers/following label.
        self.setFollowDataCount(userData)
        
        // Set the post count label default.
        self.profPosts.text = "0"
        
        // Set the posts count label.
        ManageUser.getUserPostCount(userData) { (result) -> Void in
            self.profPosts.text = "\(result)"
        }
        
        // Set the username label text.
        self.profUserName.text = "\(userData.username!)"
        
        // Check the website URL link.
        userWebsiteLink = userData.objectForKey("website") as? String
        
        if (userWebsiteLink != nil) {
            self.profWeb.setTitle(userWebsiteLink, forState: UIControlState.Normal)
        }
            
        else {
            self.profWeb.setTitle("No website set.", forState: UIControlState.Normal)
            self.profWeb.userInteractionEnabled = false
        }
        
        // Check if the user is verified.
        let verify = userData.objectForKey("verifiedUser")
        
        if (verify == nil) {
            self.profVerified.alpha = 0.0
        }
            
        else {
            
            if (verify as! Bool == true) {
                self.profVerified.alpha = 1.0
            }
                
            else {
                self.profVerified.alpha = 0.0
            }
        }
        
        // Check if the user has a profile image.
        
        if (userData.objectForKey("profileImage") == nil) {
            self.profPicture.image = UIImage(named: "default_profile_pic.png")
        }
            
        else {
            
            let userImageFile = userData["profileImage"] as! PFFile
            
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        
                        // Set the downloaded profile image.
                        self.profPicture.image = profileImage
                    }
                        
                    else {
                        
                        // No profile picture set the standard image.
                        self.profPicture.image = UIImage(named: "default_profile_pic.png")
                    }
                }
                    
                else {
                    
                    // No profile picture set the standard image.
                    self.profPicture.image = UIImage(named: "default_profile_pic.png")
                }
                
                // Notify the user that the app has stopped loading.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    // Alert methods.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Animation methods.
    
    func makeEditSmaller() {
        
        // Run the 'small' animation.
        UIView.animateWithDuration(0.3 , animations: {
            self.editButton.transform = CGAffineTransformMakeScale(0.75, 0.75)
        }, completion: nil)
    }
    
    func restoreEditSize() {
        
        // Make the button bigger again.
        UIView.animateWithDuration(0.3) {
            self.editButton.transform = CGAffineTransformIdentity
        }
    }
    
    // Follow methods.
    
    func followOrUnfolowUser(userData: PFUser) {
        
        // Send the user object to the ManageUser
        // class to follor ow unfollow the user.
        ManageUser.followOrUnfolowUser(userData) { (followUnfollowstatus: Bool, message, buttonTitle) -> Void in
            
            // Update the followers labels.
            self.setFollowDataCount(userData)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Check to see if the follow/unfollow
                // operation succeded or failed.
                
                if (followUnfollowstatus == true) {
                    
                    // Set the edit button text.
                    self.editButton.setTitle("\(buttonTitle) \(self.passedUser.username!)", forState: UIControlState.Normal)
                    
                    // Display the success alert.
                    self.displayAlert("Success", alertMessage: "The user @\(userData.username!) has been \(message).")
                }
                    
                else {
                    
                    // Display the error alert.
                    self.displayAlert("Error", alertMessage:"The user @\(userData.username!) has not been \(message).")
                }
            })
        }
    }
    
    func setFollowDataCount(userData: PFUser) {
        
        // Get the user follow data.
        ManageUser.getFollowDataCount(userData) { (countObject) -> Void in
            
            // Set the followers and following labels.
            self.profFollowers.text = "\(countObject.valueForKey("userFollowers")!.count)"
            self.profFollowing.text = "\(countObject.valueForKey("userFollowing")!.count)"
        }
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
