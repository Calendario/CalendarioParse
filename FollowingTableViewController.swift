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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = "Following"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 20)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Load in the user following list.
        LoadData()
    }
    
    // load data from Parse backend
    
    func LoadData()
    {
        // Disallow table view access until 
        // the data has been fully loaded.
        self.tableView.isUserInteractionEnabled = false
        
        followingdata.removeAllObjects()
        
        var query:PFQuery<PFObject>!
        query = PFUser.query()
        query?.whereKey("objectId", equalTo: passedInUser.objectId!)
        query?.findObjectsInBackground(block: { (objects, error) -> Void in
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
                                self.followingdata.add(followers as! PFObject)
                                
                                let array:NSArray = self.followingdata.reverseObjectEnumerator().allObjects as NSArray
                                self.followingdata = NSMutableArray(array: array)
                                self.tableView.isUserInteractionEnabled = true
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        })
    }

    // when the backbutton is tapped
    
    @IBAction func BackButtontapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return followingdata.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowingCell", for: indexPath) as! FollowingTableViewCell
        
        let followData:PFObject = self.followingdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        let nameString = followData.object(forKey: "username") as! String
        let fullNameString = followData.object(forKey: "fullName") as! String

        // setting the labels
        cell.UserNameLabel.text = nameString
        cell.RealNameLabel.text = fullNameString
        
        // make the imageview into a circle
        cell.imageview.layer.cornerRadius = (cell.imageview.frame.size.width / 2)
        cell.imageview.clipsToBounds = true
        
        // query to get images
        
        var getImages:PFQuery<PFObject>!
        getImages = PFUser.query()!
        getImages.whereKey("objectId", equalTo: followData.value(forKey: "objectId")!)
        getImages.findObjectsInBackground { (objects, error) -> Void in
            
            if error == nil {
                self.getImageData(objects!, imageview: cell.imageview)
            } else {
                print("error")
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let followData:PFObject = self.followingdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
        let username = followData.object(forKey: "username") as! String
        
        var query:PFQuery<PFObject>!
        query = PFUser.query()
        query?.includeKey("user")
        query?.whereKey("username", equalTo: username)
        query?.findObjectsInBackground(block: { (objects, error) -> Void in
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
    func GotoProfile(_ user:PFUser)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var profile:MyProfileViewController!
        profile = sb.instantiateViewController(withIdentifier: "My Profile") as! MyProfileViewController
        profile.passedUser = user
        self.present(profile, animated: true, completion: nil)
    }
    
    // get images
    
    func getImageData(_ objects:[PFObject], imageview:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackground(block: { (ImageData, error) -> Void in
                    if error == nil
                    {
                        let image = UIImage(data: ImageData!)
                        imageview.image = image
                    } else {
                        imageview.image = UIImage(named: "default_profile_pic.png")
                    }
                })
            } else {
                imageview.image = UIImage(named: "default_profile_pic.png")
            }
        }
    }
}
