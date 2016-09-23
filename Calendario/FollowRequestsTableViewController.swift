//
//  FollowRequestsTableViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 17/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowRequestsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var requestList: UITableView!
    
    // Show user requests or the 
    // no requests table view cell.
    var requestsCheck:Bool = true
    
    // User requests data.
    var requestObjects:NSMutableArray = NSMutableArray()
    
    // Setup the button methods.
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the data requests.
        self.getUserRequests()
    }
    
    // Request data methods.
    
    func getUserRequests() {
        
        // Get the various follow requests for the user.
        var followQuery:PFQuery<PFObject>!
        followQuery = PFQuery(className: "FollowRequest")
        followQuery.whereKey("desiredfollower", equalTo: PFUser.current()!)
        followQuery.findObjectsInBackground { (object, error) -> Void in
            
            // Check if the user has any requests.
            
            if (object!.count > 0) {
                
                // Initialise the data array.
                self.requestObjects = NSMutableArray()
                
                // Save the user request data.
                
                for loop in 0..<object!.count {
                    self.requestObjects.add(object![loop])
                }
                
                // Set the requests check.
                self.requestsCheck = true
            }
            
            else {
                self.requestsCheck = false
            }
            
            // Enable table view access.
            self.requestList.isUserInteractionEnabled = true
            
            // Update the table view.
            self.requestList.reloadData()
        }
    }
    
    // Accept/decline request methods.
    
    func acceptRequest(_ sender:UIButton) {
        
        // Disable access to the table view
        // while the request data is processed.
        self.requestList.isUserInteractionEnabled = false
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = requestObjects.object(at: sender.tag) as! PFObject
        
        // Accept the follow request.
        ManageUser.acceptFollowRequest((currentObject.value(forKey: "Requester") as? PFUser!)!) { (followSuccess, error) -> Void in
            
            if (followSuccess == true) {
                
                // Delete the follow request as it
                // has now been accepted by the user.
                currentObject.deleteInBackground(block: { (success, deleteError) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        
                        // Delete the data from the data array.
                        self.requestObjects.removeObject(at: sender.tag)
                        
                        // Reload the table view.
                        self.getUserRequests()
                    })
                })
            }
            
            else {
                
                DispatchQueue.main.async(execute: {
                    
                    // Enable table view access.
                    self.requestList.isUserInteractionEnabled = true
                    
                    // Display the delete error alert.
                    self.displayAlert("Error", alertMessage: "The follow request has not been accepted (Error: \(error)).")
                })
            }
        }
    }
    
    func declineRequest(_ sender:UIButton) {
        
        // Disable access to the table view
        // while the request data is processed.
        self.requestList.isUserInteractionEnabled = false
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = requestObjects.object(at: sender.tag) as! PFObject
        
        // Delete the follow request.
        currentObject.deleteInBackground(block: { (success, error) -> Void in
            
            DispatchQueue.main.async(execute: {
                
                if (error == nil) {
                    
                    // Delete the data from the data array.
                    self.requestObjects.removeObject(at: sender.tag)
                    
                    // Reload the table view.
                    self.getUserRequests()
                }
                    
                else {
                    
                    // Enable table view access.
                    self.requestList.isUserInteractionEnabled = true
                    
                    // Display the delete error alert.
                    self.displayAlert("Error", alertMessage: "The follow request has not been deleted (Error: \(error?.localizedDescription)).")
                }
            })
        })
    }
    
    // UITableView methods.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (self.requestsCheck == true) {
            return requestObjects.count
        }
            
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowRequestCustomCell
        
        if (self.requestsCheck == true) {
            
            // Hide the no data cell label.
            cell.noDataLabel.alpha = 0.0
            
            // Enable access to the accept/decline buttons.
            cell.acceptButton.isEnabled = true
            cell.declineButton.isEnabled = true
            
            // Connect the accept and decline buttons
            // to the appropriate user request method.
            cell.acceptButton.addTarget(self, action: #selector(FollowRequestsTableViewController.acceptRequest(_:)), for: UIControlEvents.touchUpInside)
            cell.declineButton.addTarget(self, action: #selector(FollowRequestsTableViewController.declineRequest(_:)), for: UIControlEvents.touchUpInside)
            
            // Get the specific status object for this cell.
            let currentObject:PFObject = requestObjects.object(at: (indexPath as NSIndexPath).row) as! PFObject
    
            // Turn the profile picture into a circle.
            cell.userProfilePicture.layer.cornerRadius = (cell.userProfilePicture.frame.size.width / 2)
            cell.userProfilePicture.clipsToBounds = true
            
            // Get the user object data.
            var findUser:PFQuery<PFObject>!
            findUser = PFUser.query()!
            findUser.whereKey("objectId", equalTo: ((currentObject.object(forKey: "Requester") as AnyObject).objectId)!)
            
            findUser.findObjectsInBackground(block: { (objects:[PFObject]?, error: Error?) in
                
                if let aobject = objects {
                    
                    // Get the user data object.
                    let userObject = (aobject as NSArray).lastObject as? PFUser
                    
                    // Set the user labels.
                    cell.usernameLabel.text = "@\(userObject!.username!)"
                    cell.userFullNameLabel.text = userObject!["fullName"] as? String
                    
                    // Setup the user profile image file.
                    if let userImageFile = userObject!["profileImage"] {
                        
                        // Download the profile image.
                        (userImageFile as AnyObject).getDataInBackground(block: { (imageData: Data?, error: Error?) in
                            
                            if (error == nil) {
                                
                                // Check the profile image data first.
                                let profileImage = UIImage(data:imageData!)
                                
                                if ((imageData != nil) && (profileImage != nil)) {
                                    
                                    // Set the user profile picture.
                                    cell.userProfilePicture.image = profileImage
                                }
                                    
                                else {
                                    
                                    // No profile picture set the standard image.
                                    cell.userProfilePicture.image = UIImage(named: "default_profile_pic.png")
                                }
                            }
                                
                            else {
                                
                                // No profile picture set the standard image.
                                cell.userProfilePicture.image = UIImage(named: "default_profile_pic.png")
                            }
                        })
                    } else {
                        cell.userProfilePicture.image = UIImage(named: "default_profile_pic.png")
                    }
                }
            })
        }
            
        else {
            
            // Disable access to the accept/decline buttons.
            cell.acceptButton.isEnabled = false
            cell.declineButton.isEnabled = false
            
            // Hide the main cell views.
            cell.usernameLabel.alpha = 0.0
            cell.userFullNameLabel.alpha = 0.0
            cell.userProfilePicture.alpha = 0.0
            cell.acceptButton.alpha = 0.0
            cell.declineButton.alpha = 0.0
            
            // Show the no data cell label.
            cell.noDataLabel.alpha = 1.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (self.requestsCheck == true) {
            return 74
        }
            
        else {
            return self.requestList.bounds.height
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
   
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
