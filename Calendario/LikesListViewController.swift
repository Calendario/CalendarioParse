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
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = "Likes"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]

        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "back_button.png"), for: UIControlState())
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(LikesListViewController.closeView), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        // Link the pull to refresh to the refresh method.
        menuIndicator.addTarget(self, action: #selector(LikesListViewController.loadLikesData), for: .valueChanged)
        self.menuIndicator.beginRefreshing()
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load in the user likes data.
        self.loadLikesData()
    }
    
    // Data load methods.
    
    func loadLikesData() {
        
        self.menuIndicator.beginRefreshing()
        
        // Load in the recommended view controller state.
        let defaults = UserDefaults.standard
        let statusID = defaults.object(forKey: "likesListID") as? String
        
        // Setup the likes query.
        var queryLikes:PFQuery<PFObject>!
        queryLikes = PFQuery(className:"StatusUpdate")
        
        // Get the status likes array.
        queryLikes.getObjectInBackground(withId: statusID!) { (object, error) -> Void in
            
            self.menuIndicator.endRefreshing()
            
            // Check if there are any errors
            // and any likes before continuing.
            
            if ((error == nil) && (object != nil)) {
                
                // Save the status likes data.
                self.likesData = object?.value(forKey: "likesarray") as! NSArray
                
                // Update the table view.
                self.tableView.reloadData()
            }
                
            else {
                
                DispatchQueue.main.async(execute: {
                    
                    var alertString = "The selected status update has not received any likes."
                    
                    if (error != nil) {
                        alertString = (error?.localizedDescription)!
                    }
                    
                    // Setup the alert controller.
                    let alertController = UIAlertController(title: "No Likes", message: alertString, preferredStyle: .alert)
                    
                    // Setup the alert actions.
                    let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    // UITableView methods.
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likesData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "likesCell", for: indexPath) as! LikesCustomCell
        
        // Turn the profile picture into a circle.
        cell.profileImageView.layer.cornerRadius = (cell.profileImageView.frame.size.width / 2)
        cell.profileImageView.clipsToBounds = true
        
        // Setup the user details query.
        var findUser:PFQuery<PFObject>!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: self.likesData.object(at: (indexPath as NSIndexPath).row))
        
        // Download the user detials.
        findUser.findObjectsInBackground { (objects:[PFObject]?, error: Error?) in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                cell.userNameLabel.text = userObject?.username
                
                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                if let userImageFile = userObject!["profileImage"] {
                    
                    // Download the profile image.
                    (userImageFile as AnyObject).getDataInBackground(block: { (imageData: Data?, error: Error?) in
                        
                        if ((error == nil) && (imageData != nil)) {
                            profileImage = UIImage(data: imageData!)
                        }
                        
                        cell.profileImageView.image = profileImage
                    })
                } else {
                    cell.profileImageView.image = profileImage
                }
            }
        }
        
        return cell
    }
    
    // Other methods.
    
    func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
