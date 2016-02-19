//
//  LikesListViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 18/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore

class LikesListViewController: UITableViewController {
    
    // Status likes data array.
    var likesData:NSArray = []
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        // Set the navigation bar properties.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = "Likes"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        let font = UIFont(name: "Futura-Medium", size: 21)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]

        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "left_icon.png"), forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: "closeView", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        // Link the pull to refresh to the refresh method.
        menuIndicator.addTarget(self, action: "loadLikesData", forControlEvents: .ValueChanged)
        self.menuIndicator.beginRefreshing()
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load in the user likes data.
        self.loadLikesData()
    }
    
    // Data load methods.
    
    func loadLikesData() {
        
        self.menuIndicator.beginRefreshing()
        
        // Load in the recommended view controller state.
        let defaults = NSUserDefaults.standardUserDefaults()
        let statusID = defaults.objectForKey("likesListID") as? String
        
        // Setup the likes query.
        var queryLikes:PFQuery!
        queryLikes = PFQuery(className:"StatusUpdate")
        
        // Get the status likes array.
        queryLikes.getObjectInBackgroundWithId(statusID!) { (object, error) -> Void in
            
            self.menuIndicator.endRefreshing()
            
            // Check if there are any errors
            // and any likes before continuing.
            
            if ((error == nil) && (object != nil)) {
                
                // Save the status likes data.
                self.likesData = object?.valueForKey("likesarray") as! NSArray
                
                // Update the table view.
                self.tableView.reloadData()
            }
                
            else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    var alertString = "The selected status update has not received any likes."
                    
                    if (error != nil) {
                        alertString = (error?.localizedDescription)!
                    }
                    
                    // Setup the alert controller.
                    let alertController = UIAlertController(title: "No Likes", message: alertString, preferredStyle: .Alert)
                    
                    // Setup the alert actions.
                    let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    // UITableView methods.
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likesData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("likesCell", forIndexPath: indexPath) as! LikesCustomCell
        
        // Turn the profile picture into a circle.
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
        cell.profileImageView.clipsToBounds = true
        
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: self.likesData.objectAtIndex(indexPath.row))
        
        // Download the user detials.
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                cell.userNameLabel.text = userObject?.username
                
                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                let userImageFile = userObject!["profileImage"] as! PFFile
                
                // Download the profile image.
                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (imageData != nil)) {
                        profileImage = UIImage(data: imageData!)
                    }
                    
                    cell.profileImageView.image = profileImage
                }
            }
        }
        
        return cell
    }
    
    // Other methods.
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
