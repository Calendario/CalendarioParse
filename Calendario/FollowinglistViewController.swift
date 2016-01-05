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
        
        
        
    }
        }
    
    
   // number of rows
        
        func tableView(tableView: UITableView, numberOfRowsInSection
            section: Int) -> Int {
                
                
                return 10
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
        
        
    