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
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        // Go back to the login page.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func followUser(_ sender: UIButton) {
        
        // Follow or unfollow the user account.
        ManageUser.followOrUnfolowUser((randomData.object(at: sender.tag) as! PFUser)) { (followUnfollowstatus, test, hello) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                // Update the cell follow button.
                self.userTableView.beginUpdates()
                self.userTableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the user data.
        self.loadRandomUsers()
    }
    
    // Data methods.
    
    func loadRandomUsers() {
        
        // Setup the user query.
        var findUser:PFQuery<PFObject>!
        findUser = PFUser.query()!
        
        // Get the user objects from Parse.
        findUser.findObjectsInBackground { (objects, error) -> Void in
            
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
                                
                                if (((self.randomData[loopTwo] as! PFUser).objectId! == (self.userData[Int(number)] as! PFUser).objectId!) || ((self.userData[Int(number)] as! PFUser).objectId! == PFUser.current()!.objectId!)) {
                                    
                                    // Set the data check to 'already added'.
                                    dataCheck = false
                                    break
                                }
                            }
                            
                            if (dataCheck == true) {
                                self.randomData.add(self.userData[Int(number)])
                            }
                        }
                            
                        else {
                            self.randomData.add(self.userData[Int(number)])
                        }
                    }
                    
                    // Update the table view.
                    self.userTableView.reloadData()
                }
            }
        }
    }
    
    // UITableView methods.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.randomData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecommendedUsersCustomCell
        
        // Turn the profile picture into a cirlce.
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
        cell.profileImageView.clipsToBounds = true
        
        // Get the specific user object for this cell.
        let currentObject:PFUser = randomData.object(at: (indexPath as NSIndexPath).row) as! PFUser
        
        // Set the cell labels.
        cell.usernameLabel.text = currentObject.username
        cell.userFullNameLabel.text = currentObject["fullName"] as? String
        
        // Set the follow button tag needed
        // for the follow function method call.
        cell.followButton.tag = (indexPath as NSIndexPath).row
        
        // Set the follow user button state.
        ManageUser.alreadyFollowingUser(currentObject, currentUserCheckMode: true) { (followCheck, info) -> Void in
            
            // Set the alpha and interaction proerties to the
            // default (ma change depending on other states).
            cell.followButton.alpha = 1.0
            cell.followButton.isUserInteractionEnabled = true
            
            if (followCheck == true) {
                cell.followButton.setImage(UIImage(imageLiteralResourceName: "checkedUserV2"), for: UIControlState())
                
            }
            
            else {
                
                // If the user is private then check if
                // a follow request has been made otherwise
                // show the 'addUser' follow button image.
                
                if ((currentObject.object(forKey: "privateProfile") as? Bool) == true) {
                    
                    ManageUser.checkFollowRequest(currentObject, completion: { (requestCheck) -> Void in
                        
                        if (requestCheck == true) {
                            
                            // A follow request has been made so lower
                            // the button alpha and do not allow the user
                            // to select the follow button for that user.
                            cell.followButton.alpha = 0.6
                            cell.followButton.isUserInteractionEnabled = false
                            cell.followButton.setImage(UIImage(imageLiteralResourceName: "waitingApproval"), for: UIControlState())
                        }
                        
                        else {
                            
                            // No follow request has been made.
                            cell.followButton.setImage(UIImage(imageLiteralResourceName: "addUserV2"), for: UIControlState())
                        }
                    })
                }
                    
                else {
                    
                    // The logged in user is not follow the cell user.
                    cell.followButton.setImage(UIImage(imageLiteralResourceName: "addUserV2"), for: UIControlState())
                }
            }
        }
        
        // Setup the user profile image file.
        if let userImageFile = currentObject["profileImage"] {
            
            // Download the profile image.
            (userImageFile as AnyObject).getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        cell.profileImageView.image = profileImage
                    } else {
                        cell.profileImageView.image = UIImage(named: "default_profile_pic.png")
                    }
                    
                } else {
                    cell.profileImageView.image = UIImage(named: "default_profile_pic.png")
                }
            })
        } else {
            cell.profileImageView.image = UIImage(named: "default_profile_pic.png")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
