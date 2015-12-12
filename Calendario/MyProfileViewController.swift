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
    
    
    @IBOutlet weak var FollowButton: UIButton!
    
    // Follow method property
    var FollowObject = FollowHelper()
        
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedUser:PFUser!
    var userID:String!
    
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
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        var currentUser:PFUser!
        
        if (passedUser == nil) {
            
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
        }
            
        else {
            
            // Show the user being passed into the view.
            currentUser = passedUser
            
            // Set the back button image and display it.
            backButton.image = UIImage(named: "left_icon.png")
            backButton.enabled = true
            
            // Get the username string.
            userID = currentUser.username! as String
            
            // Set the edit button text.
            self.editButton.setTitle("Follow \(userID)", forState: UIControlState.Normal)
            
            // Hide the settings button.
            settingsButton.enabled = false
            settingsButton.image = nil
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
