//
//  FollowersTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/7/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowersTableViewController: UITableViewController {
    
      var followersdata:NSMutableArray = NSMutableArray()

    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setLeftBarButtonItem(backButton, animated: true)
        self.navigationItem.title = "Followers"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.30, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadData()
    }
    
    
    // load data from parse
    
    func LoadData()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var userdata = defaults.objectForKey("userdata")
        print(userdata)
        
        followersdata.removeAllObjects()
        
        var query = PFUser.query()
        query?.whereKey("username", equalTo: userdata!)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                print(objects!.count)
                if let objects = objects
                {
                    for object in objects
                    {
                        var user:PFUser = object as! PFUser
                        print(user)
                        
                        ManageUser.getUserFollowersList(user, completion: { (userFollowers) -> Void in
                            print(userFollowers)
                            
                            for followers in userFollowers
                            {
                                let user = followers.username!
                                print(user)
                                
                                
                                self.followersdata.addObject(followers as! PFObject)
                                
                                let array:NSArray = self.followersdata.reverseObjectEnumerator().allObjects
                                self.followersdata = NSMutableArray(array: array)
                                self.tableView.reloadData()
                                
                                print(self.followersdata.count)
                            }
                            
                            
                        })
                    }
                }
            }
        })
        

    }
    
    
    
    @IBAction func backButtonTapped(sender: AnyObject) {
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
        return followersdata.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowersCell", forIndexPath: indexPath) as! FollowersTableViewCell
        
        let followdata:PFObject = self.followersdata.objectAtIndex(indexPath.row) as! PFObject
        cell.usernameLabel.text = followdata.objectForKey("username") as! String
        cell.realNameLabel.text = followdata.objectForKey("fullName") as! String
        
        // make imageview into circle
        cell.imageview.layer.cornerRadius = (cell.imageview.frame.size.width / 2)
        cell.imageview.clipsToBounds = true
        
        
        var getImages:PFQuery = PFUser.query()!
        getImages.whereKey("objectId", equalTo: followdata.valueForKey("objectId")!)
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
        let followData:PFObject = self.followersdata.objectAtIndex(indexPath.row) as! PFObject
        
        var username = followData.objectForKey("username") as! String
        print(username)
        
        var query = PFUser.query()
        query?.includeKey("user")
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                print(objects!.count)
                if let objects = objects
                {
                    for object in objects
                    {
                        var user:PFUser = object as! PFUser
                        print(user)
                        self.GotoProfile(user)
                    }
                }
            }
        })
    }

    

    
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
