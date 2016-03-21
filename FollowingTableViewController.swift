//
//  FollowingTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/6/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowingTableViewController: UITableViewController {
    
    var followingdata:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    

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
        

        
        // get user data from nsuserdefaults 
        LoadData()
       
    }
    
    
    // load data from Parse backend
    
    func LoadData()
    
    {
        
        // Disallow table view access until 
        // the data has been fully loaded.
        self.tableView.userInteractionEnabled = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var userdata = defaults.objectForKey("userdata")
        
        followingdata.removeAllObjects()
        
        var query:PFQuery!
        query = PFUser.query()
        query?.whereKey("username", equalTo: userdata!)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        var user:PFUser = object as! PFUser
                        
                        ManageUser.getUserFollowingList(user, completion: { (userFollowers) -> Void in
                                                        
                            for followers in userFollowers
                            {
                               let user = followers.username!

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
        // setting the labels
        cell.UserNameLabel.text = followData.objectForKey("username") as! String
        cell.RealNameLabel.text = followData.objectForKey("fullName") as! String
        
        
        // make the imageview into a circle 
        
        cell.imageview.layer.cornerRadius = (cell.imageview.frame.size.width / 2)
        cell.imageview.clipsToBounds = true
        
        
        
        // query to get images
        
        var getImages:PFQuery = PFUser.query()!
        getImages.whereKey("objectId", equalTo: followData.valueForKey("objectId")!)
        getImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                self.getImageData(objects!, imageview: cell.imageview)
            }
            else
            {
                print("error")
            }
        }
        
        
        

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let followData:PFObject = self.followingdata.objectAtIndex(indexPath.row) as! PFObject
        
        var username = followData.objectForKey("username") as! String
        
        var query = PFUser.query()
        query?.includeKey("user")
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        var user:PFUser = object as! PFUser
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
        var profile = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
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
                    }
                    else
                    {
                        imageview.image = UIImage(named: "profile_icon")
                    }
                })
            }
            
        }
    }
    

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
