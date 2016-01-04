//
//  FollowinglistViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 04/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

class FollowinglistViewController: UIViewController, UITableViewDelegate {

    
    @IBOutlet weak var followingTableView: UITableView!
    
    
    var mObjects = [AnyObject]()
    var userNames = [String]()
    var userFullName = [String]()
    
    override func viewDidLoad() {
        
        //query all following
        
        var queryObjectID:PFQuery!
        queryObjectID = PFQuery(className: "FollowersAndFollowing")
        queryObjectID.whereKey("userLink", containedIn: userData)
        
        if (error == nil) {
            
        
                self.mObjects = objects
                //found
                println(self.mObjects)
                for object in self.mObjects {
                    self.userNames.append(object["username"] as String)
                    self.userFullName.append(object["fullName"] as String)
                    
                    
                    // reload data
                    self.followingTableView.reloadData()
                }
            } else {
                //not found
            }
        }
    
    
   // number of rows
        
        func tableView(tableView: UITableView, numberOfRowsInSection
            section: int) -> Int {
                
                
                return 10
        }
    
    
   // Populating each row
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as UITableViewCell
        
        cell.usernameLabel.text = userNames[indexPath.row]
        cell.fullnameLabel.text = userFullName[indexPath.row]
        
        
        
        
        return cell
        
        
        
        
    }
    
    // on Table row item click
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
        //dipslay profile image
        
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
        
        
    }