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

class MyProfileViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var profVerified: UIImageView!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var profUserName: UILabel!
    @IBOutlet weak var profWeb: UIButton!
    @IBOutlet weak var profPosts: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var inboxButton: UIBarButtonItem!
    @IBOutlet weak var blockedBlurView: UIView!
    @IBOutlet weak var blockedViewDesc: UITextView!
    @IBOutlet weak var statusList: UITableView!
    @IBOutlet weak var profDesc: UILabel!
    @IBOutlet weak var topBar: UINavigationBar!
    @IBOutlet weak var topBackground: UIView!
    
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
    var statusLoadCheck:Bool = true
    
    // User status update data.
    // (For the statusList table view).
    var statusObjects:NSMutableArray = NSMutableArray()
    
    // Setup the on screen button actions.
    
    @IBAction func openFollowers(sender: UIButton) {
        self.GotoFollowerView()
    }
    
    @IBAction func openFollowing(sender: UIButton) {
        self.GotoFollowingView()
    }
    
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
            
            // Open the webpage view.
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
                
                alertDesc = "Unblock or report the displayed user account @\(passedUser.username!)."
                buttonOneTitle = "Unblock User"
            }
                
            else {
                
                alertDesc = "Block or report the displayed user account @\(passedUser.username!)."
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
                            let unblockAlert = UIAlertController(title: "Unblock user?", message: "You have previously blocked this user. Would you like to unblock this user?", preferredStyle: .Alert)
                            
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
        
        // Hide the back/settings/inbox button by default.
        self.backButton.image = nil
        self.settingsButton.image = nil
        self.inboxButton.image = nil
        
        // Get the screen dimensions.
        let width = UIScreen.mainScreen().bounds.size.width
        
        // Add the blocked blur view to the view.
        blockedBlurView.frame = CGRectMake(0, 0, width, self.view.bounds.size.height)
        blockedBlurView.alpha = 0.0
        self.view.addSubview(blockedBlurView)
        self.view.bringSubviewToFront(topBar)
        self.view.bringSubviewToFront(topBackground)
        
        // Add the blur to the blocked view.
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
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
        
        // Adding tap gesture reconizers to the following and follower labels.
        let followgesturereconizer = UITapGestureRecognizer(target: self, action: "GotoFollowingView")
        self.profFollowing.userInteractionEnabled = true
        self.profFollowing.addGestureRecognizer(followgesturereconizer)
        
        let followergesturereconizer = UITapGestureRecognizer(target: self, action: "GotoFollowerView")
        self.profFollowers.userInteractionEnabled = true
        self.profFollowers.addGestureRecognizer(followergesturereconizer)
    }
    
    // Gesture methods.
    
    func GotoFollowingView() {
        
        // Open the following view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followingview = sb.instantiateViewControllerWithIdentifier("following") as! FollowingTableViewController
        let NC = UINavigationController(rootViewController: followingview)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func GotoFollowerView() {
        
        // Open the followers view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followingview = sb.instantiateViewControllerWithIdentifier("followers") as! FollowersTableViewController
        let NC = UINavigationController(rootViewController: followingview)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        settingsButton.enabled = false
        inboxButton.enabled = false
        self.blockCheck = 0
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // Allow status updates to be fetched.
            self.statusLoadCheck = true
            
            // Set the edit button text.
            self.editButton.setTitle("Edit Profile", forState: UIControlState.Normal)
            
            // Show the settings button.
            settingsButton.enabled = true
            settingsButton.image = UIImage(named: "SettingsV2.png")
            settingsButton.title = nil
            
            // Show the inbox button.
            inboxButton.enabled = true
            inboxButton.image = UIImage(named: "inbox.png")
            inboxButton.title = nil
            
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
                                }
                            }
                        }
                    }
                }
            }
            
            // Set the back button image and display it.
            backButton.image = UIImage(named: "left_icon.png")
            backButton.enabled = true
            
            // Change the setting button to
            // the more actions button.
            settingsButton.image = nil
            settingsButton.title = "More"
            
            // Hide the inbox button.
            inboxButton.enabled = false
            inboxButton.image = nil
            
            // Check if the user is a private account.
            privateCheck = passedUser?.objectForKey("privateProfile") as? Bool
            
            // Check if the logged in user is following
            // the passed in user object or not.
            ManageUser.alreadyFollowingUser(passedUser, currentUserCheckMode: true, completion: { (status, otherData) -> Void in
                
                if (status == true) {
                    
                    // Allow status updates to be fetched.
                    self.statusLoadCheck = true
                    
                    // Set the edit button text.
                    self.editButton.setTitle("Following \(self.passedUser.username!)", forState: UIControlState.Normal)
                }
                    
                else {
                    
                    // Set the edit button text.
                    self.editButton.setTitle("Follow \(self.passedUser.username!)", forState: UIControlState.Normal)
                    
                    // If the user is private then disallow
                    // the status updates to be fetched.
                    
                    if (self.privateCheck == true) {
                        self.statusLoadCheck = false
                    }
                        
                    else {
                        self.statusLoadCheck = true
                    }
                }
                
                // Update the rest of the profile view.
                self.updateProfileView(self.passedUser)
            })
        }
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
        
        // Set the username label text.
        self.profUserName.text = "@\(userData.username!)"
        
        // Store PFUser Data in NSUserDefaults.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userData.username, forKey: "userdata")
        
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
        
        // Set the posts count label.
        ManageUser.getUserPostCount(userData) { (result) -> Void in
            
            // Set the posts counter label.
            self.profPosts.text = "\(result)"
            
            // Initialise the data array.
            self.statusObjects = NSMutableArray()
            
            // Set the status check.
            
            if (result > 0) {
                
                // Load in the user status updates data.
                self.loadUserStatusUpdate(userData)
            }
                
            else {
                
                // Ensure the table view remains clear.
                self.statusList.reloadData()
            }
        }
    }
    
    // Status updates data methods.
    
    func loadUserStatusUpdate(userData: PFUser) {
        
        // Only show the status updates if the check has passed
        // otherwise show the private user table view cell only.
        
        if (self.statusLoadCheck == true) {
            
            // Setup the user status update query.
            var queryStatusUpdate:PFQuery!
            queryStatusUpdate = PFQuery(className: "StatusUpdate")
            queryStatusUpdate.orderByDescending("createdAt")
            queryStatusUpdate.whereKey("user", equalTo: userData)
            queryStatusUpdate.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (error == nil) {
                        
                        // Set the posts counter label.
                        self.profPosts.text = "\(objects!.count)"
                        
                        // Check if any objects matching
                        // the passed in user are present.
                        
                        if (objects!.count > 0) {
                            
                            // Initialise the data array.
                            self.statusObjects = NSMutableArray()
                            
                            // Save the status update data.
                            
                            for (var loop = 0; loop < objects!.count; loop++) {
                                self.statusObjects.addObject(objects![loop])
                            }
                            
                            // Reload the table view.
                            self.statusList.reloadData()
                        }
                    }
                })
            }
        }
            
        else {
            
            // Reload the table view.
            self.statusList.reloadData()
        }
    }
    
    // UITableView methods.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.statusLoadCheck == true) {
            return statusObjects.count
        }
            
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProfileViewCustomCell
        
        if (self.statusLoadCheck == true) {
            
            // Hide the private cell view.
            cell.privateView.alpha = 0.0
            
            // Get the specific status object for this cell.
            let currentObject:PFObject = statusObjects.objectAtIndex(indexPath.row) as! PFObject
            
            // Set the status labels.
            cell.statusTextView.text = currentObject["updatetext"] as? String
            cell.uploadDateLabel.text = currentObject["dateofevent"] as? String
            
            // NSMutableAttributedString
            
            let attrs = [NSForegroundColorAttributeName:UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)]
            let tensestring = NSMutableAttributedString(string: currentObject.objectForKey("tense") as! String, attributes: attrs)
            let spacestring = NSMutableAttributedString (string: " ")
            let updatestring = NSMutableAttributedString(string: currentObject.objectForKey("location") as! String)
            
            tensestring.appendAttributedString(spacestring)
            tensestring.appendAttributedString(updatestring)
            
            cell.tenseLabel.attributedText = tensestring
            
        
            // Turn the profile picture into a cirlce.
            cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
            cell.profileImageView.clipsToBounds = true
            
            // Get the user object data.
            var findUser:PFQuery!
            findUser = PFUser.query()!
            findUser.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
            
            findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                
                if let aobject = objects {
                    
                    let userObject = (aobject as NSArray).lastObject as? PFUser
                    
                    // Set the user name label.
                    cell.userNameLabel.text = userObject?.username
                    
                    // Setup the user profile image file.
                    let userImageFile = userObject!["profileImage"] as! PFFile
                    
                    // Download the profile image.
                    userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        
                        if (error == nil) {
                            
                            // Check the profile image data first.
                            let profileImage = UIImage(data:imageData!)
                            
                            if ((imageData != nil) && (profileImage != nil)) {
                                
                                // Set the user profile picture.
                                cell.profileImageView.image = profileImage
                            }
                                
                            else {
                                
                                // No profile picture set the standard image.
                                cell.profileImageView.image = UIImage(named: "default_profile_pic.png")
                            }
                        }
                            
                        else {
                            
                            // No profile picture set the standard image.
                            cell.profileImageView.image = UIImage(named: "default_profile_pic.png")
                        }
                    }
                }
            }
        }
            
        else {
            
            // Hide the main cell views.
            cell.statusTextView.alpha = 0.0
            cell.uploadDateLabel.alpha = 0.0
            cell.tenseLabel.alpha = 0.0
            //cell.locationLabel.alpha = 0.0
            cell.profileImageView.alpha = 0.0
            cell.userNameLabel.alpha = 0.0
            
            // Show the private cell view.
            cell.privateView.alpha = 1.0
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 139
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if (self.statusLoadCheck == true) {
            return true
        }
            
        else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    // Dynamic cell height.
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func ReportView() {
        
        // Open the report view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func Seemore() {
        
        // Open the see more view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
        let NC = UINavigationController(rootViewController: SMVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            
            let statusupdate:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(statusupdate.objectId, forKey: "reported")
            
            self.ReportView()
            
            var reportquery:PFQuery!
            reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.objectForKey("updatetext")!)
            reportquery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        
                        var reportedID:String!
                        
                        for object in objects {
                            reportedID = object.objectId
                        }
                        
                        var reportstatus:PFQuery!
                        reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackgroundWithId(reportedID, block: { (status:PFObject?, error:NSError?) -> Void in
                            
                            if (error == nil) {
                                
                                status!["reported"] = true
                                status?.saveInBackground()
                            }
                        })
                    }
                }
            })
        }
        
        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let statusupdate:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
            let updatetext = statusupdate.objectForKey("updatetext") as! String
            let currentobjectID = statusupdate.objectId
            
            defaults.setObject(updatetext, forKey: "updatetext")
            defaults.setObject(currentobjectID, forKey: "objectId")
            
            self.Seemore()
        }
        
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            let statusupdate:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
            
            var query:PFQuery!
            query = PFQuery(className: "StatusUpdate")
            query.includeKey("user")
            query.whereKey("objectId", equalTo: statusupdate.objectId!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if (error == nil) {
                    
                    for object in objects! {
                        
                        let userstr = object["user"]?.username!
                        
                        if (userstr == PFUser.currentUser()?.username) {
                            
                            statusupdate.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                
                                if (success) {
                                    
                                    self.statusObjects.removeObjectAtIndex(indexPath.row)
                                    statusupdate.saveInBackground()
                                    
                                    // Reload the user status update data
                                    // with the correct user account.
                                    
                                    if ((self.passedUser == nil) || ((self.passedUser != nil) && (self.passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
                                        
                                        // Reload current user data.
                                        self.loadUserStatusUpdate(PFUser.currentUser()!)
                                    }
                                        
                                    else {
                                        
                                        // Reload other user account data.
                                        self.loadUserStatusUpdate(self.passedUser)
                                    }
                                }
                            })
                        }
                            
                        else {
                            
                            let alert = UIAlertController(title: "Sorry", message: "You can only delete your own posts.", preferredStyle: .Alert)
                            alert.view.tintColor = UIColor.flatGreenColor()
                            let next = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(next)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
        
        // Set the button backgrond colours.
        seemore.backgroundColor = UIColor.flatGrayColor()
        report.backgroundColor = UIColor.blackColor()
        deletestatus.backgroundColor = UIColor.redColor()
        
        // Only show the delete button if the currently
        // logged in user's profile is being shown as we don't
        // want other users to be able to delete your posts.
        
        if ((self.passedUser == nil) || ((self.passedUser != nil) && (self.passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // For V1.0 we will not be adding access to
            // the "See More" section as it is not needed.
            // return [report, seemore, deletestatus]
            return [report, deletestatus]
        }
            
        else {
            
            if (self.statusLoadCheck == true) {
                return [report]
            }
                
            else {
                return nil
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
                    self.displayAlert("Success", alertMessage: message)
                }
                    
                else {
                    
                    // Display the error alert.
                    self.displayAlert("Error", alertMessage: message)
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
