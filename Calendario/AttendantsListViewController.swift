//
//  AttendantsListViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 08/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore

public class AttendantsListViewController: UITableViewController {
    
    // Status likes data array.
    var userData:NSArray = []
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedInEventID:String!
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    // View Did Load method.
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the navigation bar properties.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = "Attendants"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "back_button.png"), forState: UIControlState.Normal)
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
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadAttendantsForEvent()
    }
    
    // Data load methods.
    
    func loadAttendantsForEvent() {
        
        self.menuIndicator.beginRefreshing()
                
        EventManager.getEventAttendants(passedInEventID) { (attendants) -> Void in
            
            self.menuIndicator.endRefreshing()
            
            if (attendants.count > 0)
            {
                self.userData = attendants
                self.tableView.reloadData()
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Setup the alert controller.
                    let alertController = UIAlertController(title: "No attendants", message: "This event does not have any attendants.", preferredStyle: .Alert)
                    
                    // Setup the alert actions.
                    let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    func getUserObject(userID: String , completion: (userDataObject: PFObject) -> Void) {
        
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: userID)
        
        // Download the user detials.
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if (error == nil) {
                
                if let aobject = objects {
                    
                    let userObject = (aobject as NSArray).lastObject
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(userDataObject: userObject! as! PFObject)
                    })
                }
            }
        }
    }
    
    // UITableView methods.
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userData.count
    }
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 52
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.getUserObject(self.userData[indexPath.row] as! String) { (userDataObject) in
            PresentingViews.showProfileView(userDataObject, viewController: self)
        }
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("likesCell", forIndexPath: indexPath) as! LikesCustomCell
        
        // Turn the profile picture into a circle.
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
        cell.profileImageView.clipsToBounds = true
        
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: self.userData.objectAtIndex(indexPath.row))
        
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
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
