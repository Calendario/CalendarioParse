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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class MyProfileViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var blockedBlurView: UIView!
    @IBOutlet weak var blockedViewDesc: UITextView!
    @IBOutlet weak var statusList: UITableView!
    
    // Follow method property
    var FollowObject = FollowHelper()
    
    // Passed in user object.
    internal var passedUser:PFUser!
    
    // Profile subview controller.
    var profileSubview:ProfileSubController!
    
    // User block check.
    // 1 = You blocked the user.
    // 2 = User has blocked you.
    var blockCheck:Int = 0
    
    // User website link.
    var userWebsiteLink:String!
    
    // Private profile check.
    var privateCheck:Bool!
    var statusLoadCheck:Bool = true
    
    // Header view set check.
    var headerSetCheck = false
    
    // User status update data.
    // (For the statusList table view).
    var statusObjects:NSMutableArray = NSMutableArray()
    
    // Setup the on screen button actions.
    
    @IBAction func viewPrivateMessages(_ sender: MIBadgeButton) {
        
        // Only show the private messages if the
        // user is viewing his/her own profile.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.current()!.username!)"))) {
            PresentingViews.openUserPrivateMessages(self)
        }
    }
    
    @IBAction func openFollowers(_ sender: UIButton) {
        self.GotoFollowerView()
    }
    
    @IBAction func openFollowing(_ sender: UIButton) {
        self.GotoFollowingView()
    }
    
    @IBAction func followUserTapped(_ sender: UIButton) {
        
        // Only follow the user if the user
        // is not viewing their own profile.
        
        if ((passedUser != nil) && (passedUser.username! != "\(PFUser.current()!.username!)")) {
            
            // Follow/unfollow the passed in user.
            self.followOrUnfolowUser(passedUser)
        }
    }
    
    @IBAction func openUserWebsite(_ sender: UIButton) {
        
        // Check the website URL before
        // opening the web page view.
        
        if (self.userWebsiteLink != nil) {
            
            // Open the webpage view.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewController(withIdentifier: "WebPage") as! WebPageViewController
            viewC.passedURL = userWebsiteLink
            self.present(viewC, animated: true, completion: nil)
        }
            
        else {
            self.displayAlert("Error", alertMessage: "This user does not have a website URL.")
        }
    }
    
    @IBAction func dismissProfile(_ sender: UIButton) {
        self.closeProfileView()
    }
    
    @IBAction func openSettingsOrMoreSection(_ sender: UIButton) {
        self.viewMoreAlert()
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view reset notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetEntireView), name: NSNotification.Name(rawValue: "RESET_TAB_4"), object: nil)
        
        // Setup the variosu UI objects.
        self.setupUI()
    }
    
    func setupUI() {
        
        // Set the status bar to white.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Get the screen dimensions.
        let width = UIScreen.main.bounds.size.width
        
        blockedBlurView.frame = CGRect(x: 0, y: 0, width: width, height: self.view.bounds.size.height)
        blockedBlurView.alpha = 0.0
        self.view.addSubview(blockedBlurView)
        
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)) as UIVisualEffectView
        visualEffectView.frame = self.blockedBlurView.bounds
        
        blockedBlurView.insertSubview(visualEffectView, at: 0)
        
        let blockButtonLeft = UIButton()
        let blockButtonRight = UIButton()
        blockButtonLeft.setImage(UIImage(named: "back_button.png"), for: UIControlState())
        blockButtonLeft.setTitleColor(UIColor.blue, for: UIControlState())
        blockButtonLeft.frame = CGRect(x: 15, y: 44, width: 22, height: 22)
        blockButtonRight.setImage(UIImage(named: "more_button.png"), for: UIControlState())
        blockButtonRight.setTitleColor(UIColor.blue, for: UIControlState())
        blockButtonRight.frame = CGRect(x: self.view.bounds.size.width - 62, y: 44, width: 62, height: 22)
        blockButtonLeft.addTarget(self, action: #selector(MyProfileViewController.closeProfileView), for: .touchUpInside)
        blockButtonRight.addTarget(self, action: #selector(MyProfileViewController.viewMoreAlert), for: .touchUpInside)
        
        self.blockedBlurView.addSubview(blockButtonLeft)
        self.blockedBlurView.addSubview(blockButtonRight)
        
        self.statusList.separatorColor = UIColor.clear
    }
    
    func addTapGestures() {
        // Adding tap gesture reconizers to the following and follower labels.
        let followgesturereconizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.GotoFollowingView))
        self.profileSubview.profFollowing.isUserInteractionEnabled = true
        self.profileSubview.profFollowing.addGestureRecognizer(followgesturereconizer)
        
        let followergesturereconizer = UITapGestureRecognizer(target: self, action: #selector(MyProfileViewController.GotoFollowerView))
        self.profileSubview.profFollowers.isUserInteractionEnabled = true
        self.profileSubview.profFollowers.addGestureRecognizer(followergesturereconizer)
    }
    
    // Back/More section alert methods.
    
    func closeProfileView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewMoreAlert() {
        
        // If the current user is being displayed then show the user
        // settings menu otherwise display the more action sheet.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.current()!.username!)"))) {
            
            // No user passed in - show the settings menu.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewC = storyboard.instantiateViewController(withIdentifier: "SettingsView") as! SettingsViewController
            self.present(viewC, animated: true, completion: nil)
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
            let moreMenu = UIAlertController(title: "Options", message: alertDesc, preferredStyle: .actionSheet)
            
            // Setup the alert actions.
            let blockUser = { (action:UIAlertAction!) -> Void in
                
                // Check if the user has already been blocked
                // and then show the appropriate actions.
                var query:PFQuery<PFObject>!
                query = PFQuery(className: "blockUser")
                query.whereKey("userBlock", equalTo: self.passedUser)
                query.whereKey("userBlocking", equalTo: PFUser.current()!)
                query.findObjectsInBackground { (objects, error) -> Void in
                    
                    if (error == nil) {
                        
                        if (objects?.count > 0) {
                            
                            // The user has already been blocked.
                            let unblockAlert = UIAlertController(title: "Unblock user?", message: "You have previously blocked this user. Would you like to unblock this user?", preferredStyle: .alert)
                            
                            // Setup the alert actions.
                            let unblockUser = { (action:UIAlertAction!) -> Void in
                                
                                // As all users are unique and there is only a 1-1
                                // relationship in each user block request we only
                                // ever need to delete the first object from the array.
                                let objects = objects as [PFObject]!
                                
                                // Submit the unblock request.
                                objects?[0].deleteInBackground(block: { (success: Bool, error: Error?) in
                                    
                                    if (success) {
                                        
                                        // Set to check to the default.
                                        self.blockCheck = 0
                                        
                                        // The user has been unblocked.
                                        self.blockedBlurView.alpha = 0.0
                                    }
                                        
                                    else {
                                        
                                        // An error has occured.
                                        self.displayAlert("Error", alertMessage: "\(error?.localizedDescription)")
                                    }
                                })
                            }
                            
                            // Setup the alert buttons.
                            let yes = UIAlertAction(title: "Yes", style: .default, handler: unblockUser)
                            let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
                            
                            // Add the actions to the alert.
                            unblockAlert.addAction(yes)
                            unblockAlert.addAction(cancel)
                            
                            // Present the alert on screen.
                            self.present(unblockAlert, animated: true, completion: nil)
                        }
                            
                        else {
                            
                            // The user isn't currently blocked
                            // therefore proceed with blocking.
                            
                            // Set the user to block and the
                            // user which is blocking that user.
                            var blockUserData:PFObject!
                            blockUserData = PFObject(className:"blockUser")
                            blockUserData["userBlock"] = self.passedUser
                            blockUserData["userBlocking"] = PFUser.current()
                            
                            // Submit the block request.
                            blockUserData.saveInBackground(block: { (success: Bool, error: Error?) in
                                
                                // Check if the user block data
                                // request was succesful or not.
                                
                                if (success) {
                                    
                                    // The user has been blocked.
                                    let blockUpdate = UIAlertController(title: "Success", message: "The user has been blocked.", preferredStyle: .alert)
                                    
                                    // Setup the alert actions.
                                    let close = { (action:UIAlertAction!) -> Void in
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                    // Setup the alert buttons.
                                    let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: close)
                                    
                                    // Add the actions to the alert.
                                    blockUpdate.addAction(dismiss)
                                    
                                    // Present the alert on screen.
                                    self.present(blockUpdate, animated: true, completion: nil)
                                }
                                    
                                else {
                                    
                                    // There was a problem, check error.description.
                                    self.displayAlert("Error", alertMessage: "\(error?.localizedDescription)")
                                }
                            })
                        }
                    }
                }
            }
            
            let reportUser = { (action:UIAlertAction!) -> Void in
                
                // Open the report user view controller.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewC = storyboard.instantiateViewController(withIdentifier: "reportUser") as! ReportUserViewController
                viewC.passedUser = self.passedUser
                self.present(viewC, animated: true, completion: nil)
            }
            
            // Setuo the alert buttons.
            let buttonOne = UIAlertAction(title: buttonOneTitle, style: .default, handler: blockUser)
            let buttonTwo = UIAlertAction(title: "Report User", style: .default, handler: reportUser)
            let cancel = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            
            // Add the actions to the alert.
            moreMenu.addAction(buttonOne)
            moreMenu.addAction(buttonTwo)
            moreMenu.addAction(cancel)
            
            // Present the alert on screen.
            present(moreMenu, animated: true, completion: nil)
        }
    }
    
    // Gesture methods.
    
    func GotoFollowingView() {
        
        // Open the following view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followingview = sb.instantiateViewController(withIdentifier: "following") as! FollowingTableViewController
        
        if (passedUser == nil) {
            followingview.passedInUser = PFUser.current()
        }
            
        else {
            followingview.passedInUser = passedUser
        }
        
        let NC = UINavigationController(rootViewController: followingview)
        self.present(NC, animated: true, completion: nil)
    }
    
    func GotoFollowerView() {
        
        // Open the followers view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let followerview = sb.instantiateViewController(withIdentifier: "followers") as! FollowersTableViewController
        
        if (passedUser == nil) {
            followerview.passedInUser = PFUser.current()
        }
            
        else {
            followerview.passedInUser = passedUser
        }
        
        let NC = UINavigationController(rootViewController: followerview)
        self.present(NC, animated: true, completion: nil)
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the user that the app is loading.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Allow tableview cell resizing based on content.
        self.statusList.rowHeight = UITableViewAutomaticDimension;
        self.statusList.estimatedRowHeight = 292;
        self.statusList.separatorInset = UIEdgeInsets.zero
        
        // Check if the header view has been set.
        
        if (self.headerSetCheck == false) {
            
            // Insert the user profile subview as the table header view.
            let story_file = UIStoryboard(name: "ProfileUI", bundle: nil)
            self.profileSubview = story_file.instantiateViewController(withIdentifier: "ProfileUI") as! ProfileSubController
            self.addChildViewController(self.profileSubview)
            self.profileSubview.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 341)
            self.statusList.tableHeaderView = self.profileSubview.view
            self.addTapGestures()
            
            // Connect the profile subview buttons to actions.
            self.profileSubview.profWeb.addTarget(self, action: #selector(MyProfileViewController.openUserWebsite(_:)), for: .touchUpInside)
            self.profileSubview.moreButton.addTarget(self, action: #selector(MyProfileViewController.openSettingsOrMoreSection(_:)), for: .touchUpInside)
            self.profileSubview.backButton.addTarget(self, action: #selector(MyProfileViewController.dismissProfile(_:)), for: .touchUpInside)
            self.profileSubview.followButton.addTarget(self, action: #selector(MyProfileViewController.followUserTapped(_:)), for: .touchUpInside)
            self.profileSubview.privateMessagesButton.addTarget(self, action: #selector(MyProfileViewController.viewPrivateMessages(_:)), for: .touchUpInside)
            
            // The header view has been set.
            self.headerSetCheck = true
        }
        
        // By default the more button is diabled until
        // we have downloaded the appropriate user data.
        self.blockCheck = 0
        
        // Check to see if a user is being passed into the
        // view controller and run the appropriate actions.
        
        if ((passedUser == nil) || ((passedUser != nil) && (passedUser.username! == "\(PFUser.current()!.username!)"))) {
            
            // Allow status updates to be fetched.
            self.statusLoadCheck = true
            
            // Hide the back button if no
            // user has been passed in.
            
            if (passedUser == nil) {
                self.profileSubview.backButton.isEnabled = false
                self.profileSubview.backButton.isUserInteractionEnabled = false
                self.profileSubview.backButton.alpha = 0.0
            }
                
            else {
                self.profileSubview.backButton.isEnabled = true
                self.profileSubview.backButton.isUserInteractionEnabled = true
                self.profileSubview.backButton.alpha = 1.0
            }
            
            // Enable the private message button.
            self.profileSubview.privateMessagesButton.isEnabled = true
            self.profileSubview.privateMessagesButton.isUserInteractionEnabled = true
            self.profileSubview.privateMessagesButton.alpha = 1.0
        
            // Set the private message button badge.
            self.getUserUnreadPrivateMessageCount()
            
            // Disable the follow user button.
            self.profileSubview.followButton.isUserInteractionEnabled = false
            self.profileSubview.followButton.isEnabled = false
            
            // Update the rest of the profile view.
            self.updateProfileView(PFUser.current()!)
        }
            
        else {
            
            // Disable the private message button.
            self.profileSubview.privateMessagesButton.isEnabled = false
            self.profileSubview.privateMessagesButton.isUserInteractionEnabled = false
            self.profileSubview.privateMessagesButton.alpha = 0.0
            
            // Enable the follow user button.
            self.profileSubview.followButton.isUserInteractionEnabled = true
            self.profileSubview.followButton.isEnabled = true
            
            // Check if the user has already been blocked
            // or if the user has blocked you and take the
            // appropriate actions.
            var query:PFQuery<PFObject>!
            query = PFQuery(className: "blockUser")
            query.whereKey("userBlock", equalTo: self.passedUser)
            query.whereKey("userBlocking", equalTo: PFUser.current()!)
            query.findObjectsInBackground { (objects, error) -> Void in
                
                if (error == nil) {
                    
                    if (objects?.count > 0) {
                        
                        // User has been blocked so
                        // display blocked blur view.
                        self.blockedBlurView.alpha = 1.0;
                        self.blockedViewDesc.text = "You have blocked this user. Tap the button in the top right hand corner to unblock."
                        self.blockCheck = 1
                    }
                        
                    else {
                        
                        var queryTwo:PFQuery<PFObject>!
                        queryTwo = PFQuery(className: "blockUser")
                        queryTwo.whereKey("userBlock", equalTo: PFUser.current()!)
                        queryTwo.whereKey("userBlocking", equalTo: self.passedUser)
                        queryTwo.findObjectsInBackground { (objects, error) -> Void in
                            
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
            privateCheck = passedUser?.object(forKey: "privateProfile") as? Bool
            
            // Check if the logged in user is following
            // the passed in user object or not.
            ManageUser.alreadyFollowingUser(passedUser, currentUserCheckMode: true, completion: { (status, otherData) -> Void in
                
                if (status == true) {
                    
                    // Allow status updates to be fetched.
                    self.statusLoadCheck = true
                    
                    // Set the follow user button image - following.
                    self.profileSubview.followButton.setImage(UIImage(named: "FollowingIcon.png"), for: UIControlState())
                }
                    
                else {
                    
                    // Set the follow user button image - not following.
                    self.profileSubview.followButton.setImage(UIImage(named: "FollowIcon.png"), for: UIControlState())
                    
                    // If the user is private then disallow
                    // the status updates to be fetched.
                    
                    if (self.privateCheck == true) {
                        self.statusLoadCheck = false
                    } else {
                        self.statusLoadCheck = true
                    }
                }
                
                // Update the rest of the profile view.
                self.updateProfileView(self.passedUser)
            })
        }
    }
    
    // Profile data load method.
    
    func updateProfileView(_ userData: PFUser) {
        
        // User is logged in - get thier details and populate the UI.
        self.profileSubview.profName.text = userData.object(forKey: "fullName") as? String
        self.profileSubview.profDesc.text = userData.object(forKey: "userBio") as? String
        
        // Get and set the followers/following label.
        self.setFollowDataCount(userData)
        
        // Set the post count label default.
        self.profileSubview.setPostsLabel(number: "0 POSTS")
        
        // Set the username label text.
        self.profileSubview.profUserName.text = "@\(userData.username!)"
        
        // Store PFUser Data in NSUserDefaults.
        let defaults = UserDefaults.standard
        defaults.set(userData.username, forKey: "userdata")
        
        // Check the website URL link.
        userWebsiteLink = userData.object(forKey: "website") as? String
        
        if (userWebsiteLink != nil) {
            self.profileSubview.profWeb.setTitle(userWebsiteLink, for: UIControlState())
        } else {
            self.profileSubview.profWeb.setTitle("No website set.", for: UIControlState())
            self.profileSubview.profWeb.isUserInteractionEnabled = false
        }
        
        // Check if the user has a background picture.
        
        if (userData.object(forKey: "backgroundImage") != nil) {
            
            let userImageFile = userData["backgroundImage"] as! PFFile
            userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileBackgroundImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileBackgroundImage != nil)) {
                        self.profileSubview.backgroundImage.image = profileBackgroundImage
                    }
                } else {
                    self.profileSubview.backgroundImage.image = nil
                }
            })
        }
        
        else {
            self.profileSubview.backgroundImage.image = nil
        }
        
        // Check if the user is verified.
        let verify = userData.object(forKey: "verifiedUser")
        
        if (verify == nil) {
            self.profileSubview.profVerified.alpha = 0.0
        }
            
        else {
            
            if (verify as! Bool == true) {
                self.profileSubview.profVerified.alpha = 1.0
            } else {
                self.profileSubview.profVerified.alpha = 0.0
            }
        }
        
        // Check if the user has a profile image.
        
        if (userData.object(forKey: "profileImage") == nil) {
            self.profileSubview.profPicture.image = UIImage(named: "default_profile_pic.png")
        }
            
        else {
            
            let userImageFile = userData["profileImage"] as! PFFile
            userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        self.profileSubview.profPicture.image = profileImage
                    } else {
                        self.profileSubview.profPicture.image = UIImage(named: "default_profile_pic.png")
                    }
                    
                } else {
                    self.profileSubview.profPicture.image = UIImage(named: "default_profile_pic.png")
                }
                
                // Notify the user that the app has stopped loading.
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
        
        // Load in the user status updates data.
        self.loadUserStatusUpdate(userData)
    }
    
    // Status updates data methods.
    
    func loadUserStatusUpdate(_ userData: PFUser) {
        
        // Only enable scrolling if we are
        // going to load the users posts.
        self.statusList.isScrollEnabled = self.statusLoadCheck
        
        // Only show the status updates if the check has passed
        // otherwise show the private user table view cell only.
        
        if (self.statusLoadCheck == true) {
            
            // Call the profile feed cloud code method.
            PFCloud.callFunction(inBackground: "getUserProfileFeed", withParameters: ["user" : "\(userData.objectId!)"], block: { (response: Any?, error: Error?) in
                
                // Check for request errors first.
                
                if (error == nil) {
                    
                    // Save the sorted data to the mutable array.
                    self.statusObjects = NSMutableArray(array: (response as! NSArray))
                    
                    // Set the posts counter label.
                    self.profileSubview.setPostsLabel(number: "\(self.statusObjects.count) POSTS")
                    
                    // Reload the table view.
                    self.statusList.reloadData()
                    
                } else {
                    self.displayAlert("Error", alertMessage: (error?.localizedDescription)!)
                }
            })
        } else {
            
            // Reload the table view.
            self.statusList.reloadData()
        }
    }
    
    // UITableView methods.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.statusLoadCheck == true) {
            return statusObjects.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Check to see if we should show the users posts
        // or show one cell saying the user is private.
        
        if (self.statusLoadCheck == true) {
            
            // Get the specific status object for this cell and call all needed methods.
            cell.passedInObject = self.statusObjects[(indexPath as NSIndexPath).row] as! PFObject
            
            ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.statusObjects[(indexPath as NSIndexPath).row] as! PFObject, cell: cell, autolayoutCheck: true)
            
            ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.statusObjects[(indexPath as NSIndexPath).row] as! PFObject)
            
            ParseCalls.findUserDetails(self.statusObjects[(indexPath as NSIndexPath).row] as! PFObject
                , usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
            
            DispatchQueue.global(qos: .background).async {
                
                // Background Thread
                DateManager.createDateDifferenceString((self.statusObjects[(indexPath as NSIndexPath).row] as! PFObject).createdAt!, false) { (difference) -> Void in
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        
                        // Run UI Updates
                        cell.createdAtLabel.text = difference
                    })
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if (self.statusLoadCheck == true) {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    // Dynamic cell height.
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 292.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.statusObjects.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
        // Setup the report status button.
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .normal, title: "Report") { (action, index) -> Void in
            
            let defaults = UserDefaults.standard
            defaults.set(statusupdate.objectId, forKey: "reported")
            
            PresentingViews.ReportView(self)
            
            var reportquery:PFQuery<PFObject>!
            reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.object(forKey: "updatetext")!)
            
            reportquery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        
                        var reportedID:String!
                        
                        for object in objects {
                            reportedID = object.objectId
                        }
                        
                        var reportstatus:PFQuery<PFObject>!
                        reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackground(withId: reportedID, block: { (status: PFObject?, error: Error?) in
                            
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
        let deletestatus = UITableViewRowAction(style: .normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            // Delete the selected status update.
            ManageUser.deleteStatusUpdate(statusupdate, self, completion: { (deletionSuccess) in
                
                if (deletionSuccess == true) {
                    
                    // Remove the status update from the array.
                    self.statusObjects.removeObject(at: (indexPath as NSIndexPath).row)
                    
                    // Remove the cell from the table view.
                    self.statusList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            })
        }
        
        // Set the button backgrond colours.
        report.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)
        
        // Only show the delete button if the currently
        // logged in user's profile is being shown as we don't
        // want other users to be able to delete your posts.
        
        if ((self.passedUser == nil) || ((self.passedUser != nil) && (self.passedUser.username! == "\(PFUser.current()!.username!)"))) {
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
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    // Follow methods.
    
    func followOrUnfolowUser(_ userData: PFUser) {
        
        // Send the user object to the ManageUser
        // class to follor ow unfollow the user.
        ManageUser.followOrUnfolowUser(userData) { (followUnfollowstatus: Bool, message, buttonTitle) -> Void in
            
            // Update the followers labels.
            self.setFollowDataCount(userData)
            
            DispatchQueue.main.async(execute: {
                
                // Update the follow button image.
                
                if (buttonTitle == "Follow") {
                    
                    // Set the follow user button image - not following.
                    self.profileSubview.followButton.setImage(UIImage(named: "FollowIcon.png"), for: UIControlState())
                }
                    
                else {
                    
                    // Set the follow user button image - following.
                    self.profileSubview.followButton.setImage(UIImage(named: "FollowingIcon.png"), for: UIControlState())
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
    
    func setFollowDataCount(_ userData: PFUser) {
        
        // Get the user follow data.
        ManageUser.getFollowDataCount(userData) { (countObject) -> Void in
            
            // Set the followers and following labels.
            self.profileSubview.profFollowers.text = "\((countObject.value(forKey: "userFollowers") as! NSArray).count) people"
            self.profileSubview.profFollowing.text = "\((countObject.value(forKey: "userFollowing") as! NSArray).count) people"
        }
    }
    
    //MARK: COMPLETE RESET METHODS.
    
    func resetEntireView() {
        
        // This method is called when the user taps
        // the 'Sign Out' button in the settings view.
        self.statusLoadCheck = false
        self.statusObjects.removeAllObjects()
        self.statusList.reloadData()
        self.profileSubview.resetUIObjects()
    }
    
    //MARK: PRIVATE MESSAGE METHODS.
    
    func getUserUnreadPrivateMessageCount() {
        
        // Create the custom helper class object.
        var messageHelper:PrivateMessagesHelper!
        messageHelper = PrivateMessagesHelper()
        
        // Get the total number of unread messages.
        messageHelper.getTotalNumber { (unreadMessages) in
            
            if (unreadMessages?.intValue > 0) {
                self.profileSubview.privateMessagesButton.badgeString = "\(unreadMessages!.intValue)"
            } else {
                self.profileSubview.privateMessagesButton.badgeString = nil
            }
        }
    }
}
