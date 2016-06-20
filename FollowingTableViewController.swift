//
//  FollowingTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/6/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowingTableViewController: UITableViewController {
    
    // Following user data array.
    var followingdata:NSMutableArray = NSMutableArray()
    
    // Cancel/back button.
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // Passed in user object.
    internal var passedInUser:PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = "Following"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 21)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Load in the user following list.
        LoadData()
    }
    
    // load data from Parse backend
    
    func LoadData()
    {
        // Disallow table view access until 
        // the data has been fully loaded.
        self.tableView.userInteractionEnabled = false
        
        followingdata.removeAllObjects()
        
        var query:PFQuery!
        query = PFUser.query()
        query?.whereKey("objectId", equalTo: passedInUser.objectId!)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        let user:PFUser = object as! PFUser
                        
                        ManageUser.getUserFollowingList(user, withCurrentUser: false, completion: { (userFollowers) -> Void in
                                                        
                            for followers in userFollowers
                            {
                                self.followingdata.addObject(followers as! PFObject)
                                
                                let array:NSArray = self.followingdata.reverseObjectEnumerator().allObjects
                                self.followingdata = NSMutableArray(array: array)
                                self.tableView.userInteractionEnabled = true
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        })
    }

    // when the backbutton is tapped
    
    @IBAction func BackButtontapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followingdata.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell", forIndexPath: indexPath) as! FollowingTableViewCell
        
        let followData:PFObject = self.followingdata.objectAtIndex(indexPath.row) as! PFObject
        let nameString = followData.objectForKey("username") as! String
        let fullNameString = followData.objectForKey("fullName") as! String

        // setting the labels
        cell.UserNameLabel.text = nameString
        cell.RealNameLabel.text = fullNameString
        
        // make the imageview into a circle
        cell.imageview.layer.cornerRadius = (cell.imageview.frame.size.width / 2)
        cell.imageview.clipsToBounds = true
        
        // query to get images
        
        var getImages:PFQuery!
        getImages = PFUser.query()!
        getImages.whereKey("objectId", equalTo: followData.valueForKey("objectId")!)
        getImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                self.getImageData(objects!, imageview: cell.imageview)
            } else {
                print("error")
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let followData:PFObject = self.followingdata.objectAtIndex(indexPath.row) as! PFObject
        
        let username = followData.objectForKey("username") as! String
        
        var query:PFQuery!
        query = PFUser.query()
        query?.includeKey("user")
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        let user:PFUser = object as! PFUser
                        self.GotoProfile(user)
                    }
                }
            }
        })
    }
    
    // go to user profile
    func GotoProfile(user:PFUser)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var profile:MyProfileViewController!
        profile = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        profile.passedUser = user
        self.presentViewController(profile, animated: true, completion: nil)
    }
    
    // get images
    
    func getImageData(objects:[PFObject], imageview:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackgroundWithBlock({ (ImageData, error) -> Void in
                    if error == nil
                    {
                        let image = UIImage(data: ImageData!)
                        imageview.image = image
                    } else {
                        imageview.image = UIImage(named: "profile_icon")
                    }
                })
            }
            
        }
    }
}
