//
//  FollowersViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 04/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

class FollowersViewController: UIViewController, UITableViewDelegate {
   
    @IBOutlet weak var followersTableView: UITableView!
    
    // This array can be used when populating your
    // table view - it MUST be set to var (not let).
    var userData:NSMutableArray = []
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadFollowerListData()
    }
    
    func loadFollowerListData() {
        
        // The below method returns an array
        // of the users followers.
        
        // Replace "PFUser.currentUser()!" with the PFUser
        // object of the account you are interested in.
        
        ManageUser.getUserFollowersList(PFUser.currentUser()!) { (userFollowers) -> Void in
            print("User followers: \(userFollowers)")
            
            // EXAMPLE OF DATA USAGE:
            let test = userFollowers[0] as! PFUser
            print(test.username)
        }
        
        /////
        
        // The below method returns an array
        // of who the user is following.
        
        // Replace "PFUser.currentUser()!" with the PFUser
        // object of the account you are interested in.
        
        ManageUser.getUserFollowingList(PFUser.currentUser()!) { (userFollowing) -> Void in
            print("User following: \(userFollowing)")
        }
    }
}
