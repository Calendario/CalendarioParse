//
//  FollowersTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/7/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowersTableViewController: UITableViewController {
    
    // Followers data array.
    var followersdata:NSMutableArray = NSMutableArray()

    // Cancel/back button.
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    // Passed in user object data.
    internal var passedInUser:PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setLeftBarButton(backButton, animated: true)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = "Followers"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 20)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Load in the user follower list.
        self.LoadData()
    }
    
    // load data from parse
    
    func LoadData() {
        
        // Disallow table view access until
        // the data has been fully loaded.
        self.tableView.isUserInteractionEnabled = false
                
        followersdata.removeAllObjects()
        
        var query:PFQuery<PFObject>!
        query = PFUser.query()
        query.whereKey("objectId", equalTo: passedInUser.objectId!)
        query.findObjectsInBackground(block: { (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        let user:PFUser = object as! PFUser
                        
                        ManageUser.getUserFollowersList(user, completion: { (userFollowers) -> Void in
                            
                            for followers in userFollowers
                            {                                
                                self.followersdata.add(followers as! PFObject)
                                
                                let array:NSArray = self.followersdata.reverseObjectEnumerator().allObjects as NSArray
                                self.followersdata = NSMutableArray(array: array)
                                self.tableView.isUserInteractionEnabled = true
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
            }
        })
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
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
        return followersdata.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersCell", for: indexPath) as! FollowersTableViewCell
        
        let followdata:PFObject = self.followersdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        let nameString = followdata.object(forKey: "username") as! String
        let fullNameString = followdata.object(forKey: "fullName") as! String
        
        cell.usernameLabel.text = nameString
        cell.realNameLabel.text = fullNameString
        
        // make imageview into circle
        cell.imageview.layer.cornerRadius = (cell.imageview.frame.size.width / 2)
        cell.imageview.clipsToBounds = true
        
        var getImages:PFQuery<PFObject>!
        getImages = PFUser.query()!
        getImages.whereKey("objectId", equalTo: followdata.value(forKey: "objectId")!)
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
        let followData:PFObject = self.followersdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
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
                    }
                    else
                    {
                        imageview.image = UIImage(named: "default_profile_pic.png")
                    }
                })
            } else {
                imageview.image = UIImage(named: "default_profile_pic.png")
            }
        }
    }
}
