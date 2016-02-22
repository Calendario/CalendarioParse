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
import DOFavoriteButton

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
    @IBOutlet weak var inboxButton: MIBadgeButton!
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
    
    @IBAction func openFollowRequestsSection(sender: UIButton) {
        
        // Only open the follow requests view
        // if the current user profile is being viewed.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.currentUser()!.username!)"))) {
            
            // Open the users follow requests.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewControllerWithIdentifier("RequestsView") as! FollowRequestsTableViewController
            self.presentViewController(viewC, animated: true, completion: nil)
        }
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
        self.inboxButton.setImage(nil, forState: .Normal)
        self.inboxButton.alpha = 0.0
        
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
        
        // Allow tableview cell resizing based on content.
        self.statusList.rowHeight = UITableViewAutomaticDimension;
        self.statusList.estimatedRowHeight = 292;
        self.statusList.separatorInset = UIEdgeInsetsZero

        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        settingsButton.enabled = false
        inboxButton.enabled = false
        inboxButton.alpha = 0.0
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
            inboxButton.setImage(UIImage(named: "inbox.png"), forState: .Normal)
            inboxButton.setTitle(nil, forState: .Normal)
            
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
            
            // Update the follow requests badge.
            var followQuery:PFQuery!
            followQuery = PFQuery(className: "FollowRequest")
            followQuery.whereKey("desiredfollower", equalTo: PFUser.currentUser()!)
            followQuery.findObjectsInBackgroundWithBlock { (object, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if (object!.count > 0) {
                        
                        // Set the inbox button badge properties.
                        self.inboxButton.badgeTextColor = UIColor.whiteColor()
                        self.inboxButton.badgeEdgeInsets = UIEdgeInsetsMake(13, 0, 0, 29)
                        self.inboxButton.badgeString = "\(object!.count)"
                    }
                        
                    else {
                        self.inboxButton.badgeString = nil
                    }
                    
                    // Show the inbox button after the
                    // properties have been set.
                    self.inboxButton.alpha = 1.0
                })
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
            inboxButton.setImage(nil, forState: .Normal)
            
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
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Check if we can load the status updates.
        
        if (self.statusLoadCheck == true) {
            
            // Get the specific status object for this cell.
            let currentObject:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
            
            // Setup the user details query.
            var findUser:PFQuery!
            findUser = PFUser.query()!
            findUser.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
            
            // Download the user detials.
            findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
                
                if let aobject = objects {
                    
                    let userObject = (aobject as NSArray).lastObject as? PFUser
                    
                    // Set the user name label.
                    cell.UserNameLabel.text = userObject?.username
                    
                    // Check the profile image data first.
                    var profileImage = UIImage(named: "default_profile_pic.png")
                    
                    // Setup the user profile image file.
                    let userImageFile = userObject!["profileImage"] as! PFFile
                    
                    // Download the profile image.
                    userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        
                        if ((error == nil) && (imageData != nil)) {
                            profileImage = UIImage(data: imageData!)
                        }
                        
                        cell.profileimageview.image = profileImage
                    }
                }
            }
            
            // Set the various label/button tag attributes
            // this will be needed to perform tasks such as:
            // like post, comment on post, view likes, etc...
            cell.profileimageview.tag = indexPath.row
            cell.likebutton.tag = indexPath.row
            cell.commentButton.tag = indexPath.row
            cell.likeslabel.tag = indexPath.row
            cell.commentsLabel.tag = indexPath.row
            cell.userPostedImage.tag = indexPath.row
            
            // Setup the tag gesture recognizers, so we can open
            // the various different views, ie: comments view.
            let tapGesturePostImage = UITapGestureRecognizer(target: self, action: "imageTapped:")
            let tapGestureProfileImage = UITapGestureRecognizer(target: self, action: "goToProfile:")
            let tapGestureLikesLabel = UITapGestureRecognizer(target: self, action: "goToLikesList:")
            let tapGestureCommentLabel = UITapGestureRecognizer(target: self, action: "commentsLabelClicked:")
            cell.userPostedImage.addGestureRecognizer(tapGesturePostImage)
            cell.profileimageview.addGestureRecognizer(tapGestureProfileImage)
            cell.likeslabel.addGestureRecognizer(tapGestureLikesLabel)
            cell.commentsLabel.addGestureRecognizer(tapGestureCommentLabel)
            
            // Link the comment button to the comment method.
            cell.commentButton.addTarget(self, action: "commentClicked:", forControlEvents: .TouchUpInside)
            
            // Set the status labels.
            cell.statusTextView.text = currentObject["updatetext"] as? String
            cell.uploaddatelabel.text = currentObject["dateofevent"] as? String
            
            // If the status contains hashtags then highlight them.
            
            if ((cell.statusTextView.text?.hasPrefix("#")) != nil) {
                
                // Highlight the status hashtags.
                cell.statusTextView.hashtagLinkTapHandler = {label, hashtag, range in
                    
                    // Save the hashtag string.
                    var defaults:NSUserDefaults!
                    defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(([1, hashtag]) as NSMutableArray, forKey: "HashtagData")
                    defaults.synchronize()
                    
                    // Open the hashtag view with status
                    // posts containing the selected #hashtag.
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let likesView = sb.instantiateViewControllerWithIdentifier("HashtagNav") as! UINavigationController
                    self.presentViewController(likesView, animated: true, completion: nil)
                }
            }
            
            // If the status contains @mentions then highligh
            // and link them to the open profile view action.
            
            if ((cell.statusTextView.text?.hasPrefix("@")) != nil) {
                
                // Highlight the @username label.
                cell.statusTextView.userHandleLinkTapHandler = {label2, mention, range in
                    
                    // Remove the '@' symbol from the username
                    let userMention = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                    
                    // Setup the user query.
                    var query:PFQuery!
                    query = PFUser.query()
                    query.whereKey("username", equalTo: userMention)
                    
                    // Get the user data object.
                    query.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                        
                        // Check for errors before passing
                        // the user object to the profile view.
                        
                        if ((error == nil) && (userObject != nil)) {
                            
                            // Open the selected users profile.
                            let sb = UIStoryboard(name: "Main", bundle: nil)
                            let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
                            reportVC.passedUser = userObject as? PFUser
                            self.presentViewController(reportVC, animated: true, completion: nil)
                        }
                    })
                }
            }
            
            // Create the tense/date all in one attributed string.
            let attrs2 = [NSForegroundColorAttributeName:UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
            let tensestring2 = NSMutableAttributedString(string: currentObject.objectForKey("tense") as! String, attributes: attrs2)
            let spacestring2 = NSMutableAttributedString(string: " ")
            let onstring = NSAttributedString(string: "on")
            let spacestr3 = NSAttributedString(string: " ")
            tensestring2.appendAttributedString(spacestring2)
            tensestring2.appendAttributedString(onstring)
            tensestring2.appendAttributedString(spacestr3)
            let dateattrstring = NSAttributedString(string: currentObject.objectForKey("dateofevent") as! String, attributes: attrs2)
            tensestring2.appendAttributedString(dateattrstring)
            
            // Set the date/tense all in one label.
            cell.uploaddatelabel.attributedText = tensestring2
            
            // Set location label and checking contents.
            let locationValue: String = currentObject.objectForKey("location") as! String
            
            if locationValue == "tap to select location..." {
                cell.locationLabel.text = ""
            }
                
            else {
                cell.locationLabel.text = locationValue
            }
            
            // Turn the profile picture into a circle.
            cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
            cell.profileimageview.clipsToBounds = true
            
            //set radius of imageview on status
            cell.userPostedImage.layer.cornerRadius = 4.0
            cell.userPostedImage.clipsToBounds = true
            
            // Show or hide the media image view
            // depending on the cell data type.
            cell.userPostedImage.clipsToBounds = true
            
            if (currentObject.objectForKey("image") == nil) {
                cell.userPostedImage.alpha = 0.0
                cell.imageViewHeightConstraint.constant = 1
                cell.updateConstraintsIfNeeded()
            }
                
            else {
                
                // Show the edia image view.
                cell.userPostedImage.alpha = 1.0
                cell.imageViewHeightConstraint.constant = 127
                cell.updateConstraintsIfNeeded()
                
                // Setup the user profile image file.
                let statusImage = currentObject["image"] as! PFFile
                
                // Download the profile image.
                statusImage.getDataInBackgroundWithBlock { (mediaData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (mediaData != nil)) {
                        cell.userPostedImage.image = UIImage(data: mediaData!)
                    }
                        
                    else {
                        cell.userPostedImage.image = UIImage(imageLiteral: "no-image-icon + Rectangle 4")
                    }
                }
            }
            
            // Setup the cell likes button.
            cell.likebutton.translatesAutoresizingMaskIntoConstraints = true
            cell.likebutton.clipsToBounds = false
            cell.likebutton.addTarget(self, action: "likeClicked:", forControlEvents: .TouchUpInside)
            
            // Get the post likes data.
            let likesArray:[String] = currentObject.objectForKey("likesarray") as! Array
            
            // Highlight the like button if the
            // logged in user has liked the post.
            
            if (likesArray.count > 0) {
                
                // Update the status likes label.
                
                if (likesArray.count == 1) {
                    cell.likeslabel.text = "1 Like"
                }
                    
                else {
                    cell.likeslabel.text = "\(likesArray.count) Likes"
                }
                
                // Update the like button.
                
                if likesArray.contains(PFUser.currentUser()!.objectId!) {
                    cell.likebutton.select()
                }
                    
                else {
                    cell.likebutton.deselect()
                }
            }
                
            else {
                cell.likeslabel.text = "0 Likes"
            }
            
            // Set the createdAt date label.
            DateManager.createDateDifferenceString(currentObject.createdAt!) { (difference) -> Void in
                cell.createdAtLabel.text = difference
            }
            
            // Update the comments label.
            var commentsquery:PFQuery!
            commentsquery = PFQuery(className: "comment")
            commentsquery.orderByDescending("createdAt")
            commentsquery.addDescendingOrder("updatedAt")
            commentsquery.whereKey("statusOBJID", equalTo: currentObject.objectId!)
            commentsquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                
                if (error == nil) {
                    
                    if (objects!.count == 1) {
                        cell.commentsLabel.text = "1 Comment"
                    }
                        
                    else {
                        cell.commentsLabel.text = "\(String(objects!.count) ) Comments"
                    }
                }
                    
                else {
                    cell.commentsLabel.text = "0 Comments"
                }
            }
        }
        
        else {
   
            // Hide all cell views.
            cell.UserNameLabel.alpha = 0.0
            cell.commentsLabel.alpha = 0.0
            cell.userPostedImage.alpha = 0.0
            cell.createdAtLabel.alpha = 0.0
            cell.statusTextView.alpha = 0.0
            cell.likebutton.alpha = 0.0
            cell.commentButton.alpha = 0.0
            cell.profileimageview.alpha = 0.0
            cell.uploaddatelabel.alpha = 0.0
            cell.locationLabel.alpha = 0.0
            cell.likeslabel.alpha = 0.0
            
            // Show the private view.
            cell.privateView.alpha = 1.0
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
        
        // Setup the see more button.
        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let updatetext = statusupdate.objectForKey("updatetext") as! String
            let currentobjectID = statusupdate.objectId
            
            defaults.setObject(updatetext, forKey: "updatetext")
            defaults.setObject(currentobjectID, forKey: "objectId")
            
            self.Seemore()
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
        seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)

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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "timelineComments" {
            //let vc = segue.destinationViewController as! CommentsViewController
            //vc.savedobjectID = currentObjectid
        }
    }
    
    func commentClicked(sender: UIButton) {
        
        // Get the status array index.
        let index = sender.tag
        
        // Open the comments view.
        self.openComments((self.statusObjects.objectAtIndex(index) as! PFObject).objectId!)
    }
    
    func commentsLabelClicked(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
        
        // Open the comments view.
        self.openComments(currentObject.objectId!)
    }
    
    func openComments(commentsID: String) {
        
        // Open the comments view for the selected post.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let commentvc = sb.instantiateViewControllerWithIdentifier("comments") as! CommentsViewController
        commentvc.savedobjectID = commentsID
        let NC = UINavigationController(rootViewController: commentvc)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let cell = self.statusList.cellForRowAtIndexPath(indexPath) as! NewsfeedTableViewCell
        
        // Open the photo view controller.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("PhotoV2") as! PhotoViewV2
        PVC.passedImage = cell.userPostedImage.image!
        let NC = UINavigationController(rootViewController: PVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func likeClicked(sender: DOFavoriteButton) {
        
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.tag), inSection: 0)
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
        
        // Get the post likes data.
        let likesArray:[String] = currentObject.objectForKey("likesarray") as! Array
        
        // Check if the logged in user has
        // already like the selected status.
        
        if (likesArray.count > 0) {
            
            if likesArray.contains(PFUser.currentUser()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveLikeForPost(currentObject, likePost: false, likeButton: sender)
            }
                
            else {
                
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveLikeForPost(currentObject, likePost: true, likeButton: sender)
            }
        }
            
        else {
            
            // This status has zero likes so the logged
            // in user hasn't liked the post either so we
            // can go ahead and save the like for the user.
            self.saveLikeForPost(currentObject, likePost: true, likeButton: sender)
        }
    }
    
    func saveLikeForPost(statusObject: PFObject, likePost: Bool, likeButton: DOFavoriteButton) {
        
        // Setup the likes query.
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackgroundWithId(statusObject.objectId!) { (object, error) -> Void in
            
            // Check for errors before saving the like/dislike.
            
            if ((error == nil) && (object != nil)) {
                
                if (likePost == true) {
                    
                    // Add the user to the post likes array.
                    object?.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "likesarray")
                }
                    
                else {
                    
                    // Remove the user from the post likes array.
                    object?.removeObject(PFUser.currentUser()!.objectId!, forKey: "likesarray")
                }
                
                // Save the like/dislike data.
                object?.saveInBackgroundWithBlock({ (success, likeError) -> Void in
                    
                    // Only update the like button if the
                    // background data save was successful.
                    
                    if ((success) && (likeError == nil)) {
                        
                        // Make sure the local array data if
                        // up to date otherwise the like button
                        // will be un-checked when the user scrolls.
                        self.statusObjects.replaceObjectAtIndex(likeButton.tag, withObject: object!)
                        
                        // Get access to the cell.
                        let indexPath = NSIndexPath(forRow: (likeButton.tag), inSection: 0)
                        let cell = self.statusList.cellForRowAtIndexPath(indexPath) as! NewsfeedTableViewCell
                        
                        // Get the post likes data.
                        let likesArray:[String] = object!.objectForKey("likesarray") as! Array
                        
                        // Update the likes label.
                        
                        if (likesArray.count > 0) {
                            
                            // Update the status likes label.
                            
                            if (likesArray.count == 1) {
                                cell.likeslabel.text = "1 Like"
                            }
                                
                            else {
                                cell.likeslabel.text = "\(likesArray.count) Likes"
                            }
                        }
                            
                        else {
                            cell.likeslabel.text = "0 Likes"
                        }
                        
                        // Update the like button.
                        
                        if (likePost == true) {
                            
                            likeButton.select()
                            
                            // Submit and save the like notification.
                            let likeString = "\(PFUser.currentUser()!.username!) has liked your post"
                            self.SavingNotifacations(likeString, objectID: statusObject.objectId!, notificationType:"like")
                        }
                            
                        else {
                            likeButton.deselect()
                        }
                    }
                })
            }
        }
    }
    
    func SavingNotifacations(notifcation:String, objectID:String, notificationType:String) {
        
        // Setup the notificatios query.
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackgroundWithId(objectID) { (object, error) -> Void in
            
            // Only post the notification if no
            // errors have been returned.
            
            if (error == nil) {
                
                // Only post the notification if the user who
                // performed the action is NOT the logged in user.
                
                if (PFUser.currentUser()!.objectId! != (object?.objectForKey("user") as! PFUser).objectId!) {
                    
                    // Submit the push notification.
                    PFCloud.callFunctionInBackground("StatusUpdate", withParameters: ["message" : notifcation, "user" : "\(PFUser.currentUser()?.username!)"])
                    
                    // Save the notification data.
                    ManageUser.saveUserNotification(notifcation, fromUser: PFUser.currentUser()!, toUser: object?.objectForKey("user") as! PFUser, extType: notificationType, extObjectID: objectID)
                }
            }
        }
    }
    
    func goToProfile(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
        
        // Setup the user query.
        var userQuery:PFQuery!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
        
        // Download the user object.
        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                // Open the selected users profile.
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
                reportVC.passedUser = (aobject as NSArray).lastObject as? PFUser
                self.presentViewController(reportVC, animated: true, completion: nil)
            }
        }
    }
    
    func goToLikesList(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.statusObjects.objectAtIndex(indexPath.row) as! PFObject
        
        // Save the status object ID.
        var defaults:NSUserDefaults!
        defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(currentObject.objectId!, forKey: "likesListID")
        defaults.synchronize()
        
        // Open the likes list view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("likesNav") as! UINavigationController
        self.presentViewController(likesView, animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
