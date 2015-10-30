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
    
    // Setup the on screen button actions.
    
    @IBAction func editProfile(sender: UIButton) {
        
        // Restore the size of the edit button.
        self.restoreEditSize()
        
        // Open the edit profile section.
    }
    
    @IBAction func openUserWebsite(sender: UIButton) {
        
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        
        // Check if a user is logged in
        // and then retrieve their data.
        var currentUser = PFUser.currentUser()
        
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
            let userImageFile = currentUser!["profileImage"] as! PFFile
            
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                
                if (error == nil) {
                    
                    if (imageData != nil) {
                        
                        // Set the downloaded profile image.
                        self.profPicture.image = UIImage(data:imageData!)
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
