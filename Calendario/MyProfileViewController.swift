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
    @IBOutlet weak var blockedBlurView: UIView!
    @IBOutlet weak var blockedViewDesc: UITextView!
    @IBOutlet weak var statusList: UITableView!
    @IBOutlet weak var profDesc: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    
    // Follow method property
    var FollowObject = FollowHelper()
    
    // Passed in user object.
    internal var passedUser:PFUser!
    
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
    
    @IBAction func followUserTapped(sender: UIButton) {
        
        // Only follow the user if the user
        // is not viewing their own profile.
        
        if ((passedUser != nil) && (passedUser.username! != "\(PFUser.currentUser()!.username!)")) {
            
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
        self.closeProfileView()
    }
    
    @IBAction func openSettingsOrMoreSection(sender: UIButton) {
        self.viewMoreAlert()
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addTapGestures()
    }
    
    func setupUI() {
        // Get the screen dimensions.
        let width = UIScreen.mainScreen().bounds.size.width
        
        blockedBlurView.frame = CGRectMake(0, 0, width, self.view.bounds.size.height)
        blockedBlurView.alpha = 0.0
        self.view.addSubview(blockedBlurView)
        
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = self.blockedBlurView.bounds
        
        blockedBlurView.insertSubview(visualEffectView, atIndex: 0)
        
        let blockButtonLeft = UIButton()
        let blockButtonRight = UIButton()
        blockButtonLeft.setImage(UIImage(named: "back_button.png"), forState: .Normal)
        blockButtonLeft.setTitleColor(UIColor.blueColor(), forState: .Normal)
        blockButtonLeft.frame = CGRectMake(15, 44, 22, 22)
        blockButtonRight.setImage(UIImage(named: "more_button.png"), forState: .Normal)
        blockButtonRight.setTitleColor(UIColor.blueColor(), forState: .Normal)
        blockButtonRight.frame = CGRectMake(self.view.bounds.size.width - 62, 44, 62, 22)
        blockButtonLeft.addTarget(self, action: #selector(MyProfileViewController.closeProfileView), forControlEvents: .TouchUpInside)
        blockButtonRight.addTarget(self, action: #selector(MyProfileViewController.viewMoreAlert), forControlEvents: .TouchUpInside)
        
        self.blockedBlurView.addSubview(blockButtonLeft)
        self.blockedBlurView.addSubview(blockButtonRight)
        
        self.profPicture.layer.cornerRadius = (self.profPicture.frame.size.width / 2)
        self.profPicture.clipsToBounds = true
        
        self.statusList.separatorColor = UIColor.clearColor()
    }
    
    func addTapGestures() {
        // Adding tap gesture reconizers to the following and follower labels.
        let followgesturereconizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.GotoFollowingView))
        self.profFollowing.userInteractionEnabled = true
        self.profFollowing.addGestureRecognizer(followgesturereconizer)
        
        let followergesturereconizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.GotoFollowerView))
        self.profFollowers.userInteractionEnabled = true
        self.profFollowers.addGestureRecognizer(followergesturereconizer)
    }
    
    // Back/More section alert methods.
    
    func closeProfileView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewMoreAlert() {
        
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
    
    // Gesture methods.
    
    func GotoFollowingView() {
        
        // Open the following view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followingview = sb.instantiateViewControllerWithIdentifier("following") as! FollowingTableViewController
        
        if (passedUser == nil) {
            followingview.passedInUser = PFUser.currentUser()
        }
            
        else {
            followingview.passedInUser = passedUser
        }
        
        let NC = UINavigationController(rootViewController: followingview)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func GotoFollowerView() {
        
        // Open the followers view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followerview = sb.instantiateViewControllerWithIdentifier("followers") as! FollowersTableViewController
        
        if (passedUser == nil) {
            followerview.passedInUser = PFUser.currentUser()
        }
            
        else {
            followerview.passedInUser = passedUser
        }
        
        let NC = UINavigationController(rootViewController: followerview)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Allow tableview cell resizing based on content.
        self.statusList.rowHeight = UITableViewAutomaticDimension;
        self.statusList.estimatedRowHeight = 292;
        self.statusList.separatorInset = UIEdgeInsetsZero
        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        self.blockCheck = 0
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // Allow status updates to be fetched.
            self.statusLoadCheck = true
            
            // Hide the back button if no
            // user has been passed in.
            
            if (passedUser == nil) {
                backButton.enabled = false
                backButton.userInteractionEnabled = false
                backButton.alpha = 0.0
            }
                
            else {
                backButton.enabled = true
                backButton.userInteractionEnabled = true
                backButton.alpha = 1.0
            }
            
            // Disable the follow user button.
            self.followButton.userInteractionEnabled = false
            self.followButton.enabled = false
            
            // Update the rest of the profile view.
            self.updateProfileView(PFUser.currentUser()!)
        }
            
        else {
            
            // Enable the follow user button.
            self.followButton.userInteractionEnabled = true
            self.followButton.enabled = true
            
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
                    
                    // Allow status updates to be fetched.
                    self.statusLoadCheck = true
                    
                    // Set the follow user button image - following.
                    self.followButton.setImage(UIImage(named: "Following_icon.png"), forState: .Normal)
                }
                    
                else {
                    
                    // Set the follow user button image - not following.
                    self.followButton.setImage(UIImage(named: "Follow_icon.png"), forState: .Normal)
                    
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
        
        // Only enable scrolling if we are
        // going to load the users posts.
        self.statusList.scrollEnabled = self.statusLoadCheck
        
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
                            
                            for loop in 0..<objects!.count {
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
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Check to see if we should show the users posts
        // or show one cell saying the user is private.
        
        if (self.statusLoadCheck == true) {
            
            // Get the specific status object for this cell and call all needed methods.
            cell.passedInObject = self.statusObjects[indexPath.row] as! PFObject
            
            ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.statusObjects[indexPath.row] as! PFObject, cell: cell)
            
            ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.statusObjects[indexPath.row] as! PFObject)
            
            ParseCalls.findUserDetails(self.statusObjects[indexPath.row] as! PFObject
                , usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
                
                // Background Thread
                DateManager.createDateDifferenceString((self.statusObjects[indexPath.row] as! PFObject).createdAt!) { (difference) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        
                        // Run UI Updates
                        cell.createdAtLabel.text = difference
                    })
                }
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        return 292.0
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
        
        // Setup the report status button.
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(statusupdate.objectId, forKey: "reported")
            
            PresentingViews.ReportView(self)
            
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
        
        // Setup the delete status button.
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
            
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
                                    
                                    // Remove the status update from the array.
                                    self.statusObjects.removeObjectAtIndex(indexPath.row)
                                    
                                    // Remove the cell from the table view.
                                    self.statusList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                                }
                            })
                        }
                            
                        else {
                            
                            let alert = UIAlertController(title: "Error", message: "You can only delete your own posts.", preferredStyle: .Alert)
                            alert.view.tintColor = UIColor.flatGreenColor()
                            let next = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                            alert.addAction(next)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
        
        // Set the button backgrond colours.
        //   seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        report.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)
        
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
    
    // Follow methods.
    
    func followOrUnfolowUser(userData: PFUser) {
        
        // Send the user object to the ManageUser
        // class to follor ow unfollow the user.
        ManageUser.followOrUnfolowUser(userData) { (followUnfollowstatus: Bool, message, buttonTitle) -> Void in
            
            // Update the followers labels.
            self.setFollowDataCount(userData)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Update the follow button image.
                
                if (buttonTitle == "Follow") {
                    
                    // Set the follow user button image - not following.
                    self.followButton.setImage(UIImage(named: "Follow_icon.png"), forState: .Normal)
                }
                    
                else {
                    
                    // Set the follow user button image - following.
                    self.followButton.setImage(UIImage(named: "Following_icon.png"), forState: .Normal)
                }
                
                // Check to see if the follow/unfollow
                // operation succeded or failed.
                
                if (followUnfollowstatus == true) {
                    
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
            self.profFollowers.text = "\((countObject.valueForKey("userFollowers") as! NSArray).count) people"
            self.profFollowing.text = "\((countObject.valueForKey("userFollowing") as! NSArray).count) people"
        }
    }
}
