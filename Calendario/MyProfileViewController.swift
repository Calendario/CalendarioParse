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
    
    @IBOutlet weak var FollowButton: UIButton!
    
    // Follow method property
    var FollowObject = FollowHelper()
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedUser:PFUser!
    var userID:String!
    
    // User block check.
    // 1 = You blocked the user.
    // 2 = User has blocked you.
    var blockCheck:Int = 0
    
    // User website link.
    var userWebsiteLink:String!
    
    // Setup the on screen button actions.
    
    @IBAction func editProfile(sender: UIButton) {
        
        // Restore the size of the edit button.
        self.restoreEditSize()
        
        // Open the appropriate section depending
        // on whether a user object has been passed in.
        
        if (passedUser == nil) {
            
            // No user passed in - edit current user button.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("EditView") as! EditProfileViewController
            self.presentViewController(viewC, animated: true, completion: nil)
        }
            
        else {
            
            if (userID != nil) {
                
                // User passed in - follow/unfollow user button.
                }
            
            else {
                self.displayAlert("Error", alertMessage: "The user follow request has failed.")
            }
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
        
        if (passedUser == nil) {
            
            // No user passed in - show the settings menu.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsViewController
            self.presentViewController(viewC, animated: true, completion: nil)
        }
            
        else {
            
            if (userID != nil) {
                
                var alertDesc:String!
                var buttonOneTitle:String!
                
                if (blockCheck == 1) {
                    
                    alertDesc = "Unblock or report the user dislayed user account."
                    buttonOneTitle = "Unblock User"
                }
                    
                else {
                    
                    alertDesc = "Block or report the user dislayed user account."
                    buttonOneTitle = "Block User"
                }
                
                // User passed in - show the more menu.
                let moreMenu = UIAlertController(title: "Options", message: alertDesc, preferredStyle: .ActionSheet)
                
                // Setup the alert actions.
                let blockUser = { (action:UIAlertAction!) -> Void in
                    
                    // Check if the user has already been blocked
                    // and then show the appropriate actions.
                    var query = PFQuery(className: "blockUser")
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
                                var blockUserData = PFObject(className:"blockUser")
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
                
            else {
                self.displayAlert("Error", alertMessage: "You cannot view the more options menu as no user ID has been detected.")
            }
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
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        settingsButton.enabled = false
        self.blockCheck = 0
        
        // Disable scrolling access.
        self.profileScroll.userInteractionEnabled = false
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        var currentUser:PFUser!
        
        if (passedUser == nil) {
            
            // Allow scrolling access.
            self.profileScroll.userInteractionEnabled = true
            
            // Show the currently logged in user.
            currentUser = PFUser.currentUser()
            
            // Hide the back button.
            backButton.image = nil
            backButton.enabled = false
            
            // Set the edit button text.
            self.editButton.setTitle("Edit Profile", forState: UIControlState.Normal)
            
            // Show the settings button.
            settingsButton.enabled = true
            settingsButton.image = UIImage(named: "SettingsV2.png")
            settingsButton.title = nil
        }
            
        else {
            
            // Check if the user has already been blocked
            // or if the user has blocked you and take
            // the appropriate actions.
            var query = PFQuery(className: "blockUser")
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
                        
                        var queryTwo = PFQuery(className: "blockUser")
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
                                }
                            }
                        }
                    }
                }
            }
            
            // Show the user being passed into the view.
            currentUser = passedUser
            
            // Set the back button image and display it.
            backButton.image = UIImage(named: "left_icon.png")
            backButton.enabled = true
            
            // Get the username string.
            userID = currentUser.username! as String
            
            // Set the edit button text.
            self.editButton.setTitle("Follow \(userID)", forState: UIControlState.Normal)
            
            // Change the setting button to
            // the more actions button.
            settingsButton.image = nil
            settingsButton.title = "More"
        }
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
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
        
        if (currentUser != nil) {
            
            // User is logged in - get thier details and populate the UI.
            self.profName.text = currentUser?.objectForKey("fullName") as? String
            self.profDesc.text = currentUser?.objectForKey("userBio") as? String
            
            // Get and set the follower label.
            qureyfollwersbycurrentUser(currentUser)
            
            // Set the count labels.
            self.profPosts.text = "000"
            self.profFollowing.text = "000"
            
            // Set the posts count label.
            self.setUserPostCount(currentUser)
            
            // Set the username label text.
            let userString = "@\(currentUser.username!)"
            self.profUserName.text = userString as String
            
            // Store current username is NSUserDefults so it can be used later to follow a user.
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(currentUser.username, forKey: "username")
            defaults.synchronize()
            
            // Check the website URL link.
            userWebsiteLink = currentUser?.objectForKey("website") as? String
            
            if (userWebsiteLink != nil) {
                self.profWeb.setTitle(userWebsiteLink, forState: UIControlState.Normal)
            }
                
            else {
                self.profWeb.setTitle("No website set.", forState: UIControlState.Normal)
                self.profWeb.userInteractionEnabled = false
            }
            
            // Check if the user is verified.
            let verify = currentUser?.objectForKey("verifiedUser")
            
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
            
            if (currentUser.objectForKey("profileImage") == nil) {
                self.profPicture.image = UIImage(named: "default_profile_pic.png")
            }
                
            else {
                
                let userImageFile = currentUser!["profileImage"] as! PFFile
                
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
            
        else {
            
            // There is currently no logged in user.
            self.displayAlert("Error", alertMessage: "You must login before using this section of the app.")
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
    
    // Set the user post label counter.
    
    func setUserPostCount(currentuser:PFUser) {
        
        // Get the user posts number and set
        // the label appropriately.
        
        var query = PFQuery(className: "StatusUpdate")
        query.whereKey("user", equalTo: currentuser)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                if let objects = objects as [PFObject]! {
                    
                    // Get the posts count information.
                    let posts = "\(objects.count)"
                    
                    // Set the posts label.
                    self.profPosts.text = posts
                }
            }
        }
    }
    
    // Label count set methods.
    
    func setFollowers(count: Int) {
        
        // Get the count information.
        let followers = "\(count)"
        
        // Set the follower label.
        self.profFollowers.text = followers
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
        UIView.animateWithDuration(0.3){
            self.editButton.transform = CGAffineTransformIdentity
        }
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Follow methods.
       @IBAction func followTapped(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
      var usertobefollowed = defaults.objectForKey("username") as! String
        FollowObject.addFollowingRelationshipFromUser((PFUser.currentUser()?.username)!, toUser: usertobefollowed)
      
        
                print("followed")
        
    }
    
    // query followes class by user method may not be used
    
    func qureyfollwersbycurrentUser(currentuser:PFUser)
    {
        
        var query = PFQuery(className: "Followers")
        query.whereKey("fromUser", equalTo: currentuser)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                print("this user has followers")
                
                if let objects = objects as [PFObject]!
                {
                    for object in objects
                    {
                        print(object.objectForKey("toUser"))
                    }
                    
                    // Set the user followers label.
                    self.setFollowers(objects.count)
                }
            }
        }
    }
}
