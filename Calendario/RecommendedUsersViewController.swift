//
//  RecommendedUsersViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 30/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import QuartzCore

class RecommendedUsersViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Setup the on screen views.
    @IBOutlet weak var userTableView: UITableView!
    
    // User data arrays.
    var userData:NSMutableArray = NSMutableArray()
    var randomData:NSMutableArray = NSMutableArray()
    
    // Setup the on screen button actions.
    
    @IBAction func done(sender: UIBarButtonItem) {
        // Go back to the login page.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func followUser(sender: UIButton) {
        
        // Follow or unfollow the user account.
        ManageUser.followOrUnfolowUser((randomData.objectAtIndex(sender.tag) as! PFUser)) { (followUnfollowstatus, test, hello) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                // Update the cell follow button.
                self.userTableView.beginUpdates()
                self.userTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: sender.tag, inSection: 0)], withRowAnimation: .None)
                self.userTableView.endUpdates()
            })
        }
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userTableView.delegate = self
        self.userTableView.dataSource = self
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the user data.
        self.loadRandomUsers()
    }
    
    // Data methods.
    
    func loadRandomUsers() {
        
        // Setup the user query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        
        // Get the user objects from Parse.
        findUser.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                // Set the data in the mutable array.
                self.userData = NSMutableArray(array: objects!)
        
                // Check if user data exists.
                
                if (self.userData.count > 0) {
                    
                    // Add some random users to the random data array.
                    
                    for _ in 0..<100 {
                        
                        // Select a random user object.
                        let number = arc4random_uniform(UInt32(self.userData.count))
                        
                        if (self.randomData.count > 0) {
                            
                            // Add random data check.
                            var dataCheck = true
                            
                            for loopTwo in 0..<self.randomData.count {
                                
                                // If the user is the logged in user or has already
                                // been added then do NOT allow it to be added.
                                
                                if (((self.randomData[loopTwo] as! PFUser).objectId! == (self.userData[Int(number)] as! PFUser).objectId!) || ((self.userData[Int(number)] as! PFUser).objectId! == PFUser.currentUser()!.objectId!)) {
                                    
                                    // Set the data check to 'already added'.
                                    dataCheck = false
                                    break
                                }
                            }
                            
                            if (dataCheck == true) {
                                self.randomData.addObject(self.userData[Int(number)])
                            }
                        }
                            
                        else {
                            self.randomData.addObject(self.userData[Int(number)])
                        }
                    }
                    
                    // Update the table view.
                    self.userTableView.reloadData()
                }
            }
        }
    }
    
    // UITableView methods.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.randomData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RecommendedUsersCustomCell
        
        // Turn the profile picture into a cirlce.
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
        cell.profileImageView.clipsToBounds = true
        
        // Get the specific user object for this cell.
        let currentObject:PFUser = randomData.objectAtIndex(indexPath.row) as! PFUser
        
        // Set the cell labels.
        cell.usernameLabel.text = currentObject.username
        cell.userFullNameLabel.text = currentObject["fullName"] as? String
        
        // Set the follow button tag needed
        // for the follow function method call.
        cell.followButton.tag = indexPath.row
        
        // Set the follow user button state.
        ManageUser.alreadyFollowingUser(currentObject, currentUserCheckMode: true) { (followCheck, info) -> Void in
            
            // Set the alpha and interaction proerties to the
            // default (ma change depending on other states).
            cell.followButton.alpha = 1.0
            cell.followButton.userInteractionEnabled = true
            
            if (followCheck == true) {
                cell.followButton.setImage(UIImage(imageLiteral: "checkedUserV2"), forState: UIControlState.Normal)
            }
            
            else {
                
                // If the user is private then check if
                // a follow request has been made otherwise
                // show the 'addUser' follow button image.
                
                if ((currentObject.objectForKey("privateProfile") as? Bool) == true) {
                    
                    ManageUser.checkFollowRequest(currentObject, completion: { (requestCheck) -> Void in
                        
                        if (requestCheck == true) {
                            
                            // A follow request has been made so lower
                            // the button alpha and do not allow the user
                            // to select the follow button for that user.
                            cell.followButton.alpha = 0.6
                            cell.followButton.userInteractionEnabled = false
                            cell.followButton.setImage(UIImage(imageLiteral: "waitingApproval"), forState: UIControlState.Normal)
                        }
                        
                        else {
                            
                            // No follow request has been made.
                            cell.followButton.setImage(UIImage(imageLiteral: "addUserV2"), forState: UIControlState.Normal)
                        }
                    })
                }
                    
                else {
                    
                    // The logged in user is not follow the cell user.
                    cell.followButton.setImage(UIImage(imageLiteral: "addUserV2"), forState: UIControlState.Normal)
                }
            }
        }
        
        // Setup the user profile image file.
        let userImageFile = currentObject["profileImage"] as! PFFile
        
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 74
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
