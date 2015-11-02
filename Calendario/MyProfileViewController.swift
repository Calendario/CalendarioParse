//
//  MyProfileViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 30/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import Foundation
import Parse
import QuartzCore

class MyProfileViewController : UIViewController {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var profVerified: UIImageView!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var profDesc: UITextView!
    @IBOutlet weak var profWeb: UIButton!
    @IBOutlet weak var profPosts: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileScroll: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedUser:PFUser!
    
    // Setup the on screen button actions.
    
    @IBAction func editProfile(sender: UIButton) {
        
        // Restore the size of the edit button.
        self.restoreEditSize()
        
        // Open the edit profile section.
    }
    
    @IBAction func openUserWebsite(sender: UIButton) {
        
    }
    
    @IBAction func dismissProfile(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        var currentUser:PFUser!
        
        if (passedUser == nil) {
            
            // Show the currently logged in user.
            currentUser = PFUser.currentUser()
            
            // Hide the back button.
            backButton.image = nil
            backButton.enabled = false
        }
        
        else {
            
            // Show the user being passed into the view.
            currentUser = passedUser
            
            // Set the back button image and display it.
            backButton.image = UIImage(named: "left_icon.png")
            backButton.enabled = true
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
            self.profWeb.setTitle(currentUser?.objectForKey("website") as? String, forState: UIControlState.Normal)
            self.profPosts.text = "000"
            self.profFollowers.text = "000"
            self.profFollowing.text = "000"
            
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
}
