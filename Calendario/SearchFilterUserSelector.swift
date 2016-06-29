//
//  SearchFilterUserSelector.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 29/06/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore

class SearchFilterUserSelector : UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // Setup the various UI objects.
    @IBOutlet weak var userList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Status update data array.
    var userData:NSMutableArray = []
    
    //MARK: BUTTONS.
    
    @IBAction func back(sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        self.userList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.userList.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 1.0)
        self.searchBar.tintColor = UIColor.whiteColor()
        
        for subView in self.searchBar.subviews {
            
            for subsubView in subView.subviews {
                
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("User Search", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
                    textField.textColor = UIColor.whiteColor()
                }
            }
        }
        
        self.searchBar.becomeFirstResponder()
    }
    
    //MARK: DATA METHODS.
    
    func getUserData(inputData: String) {
        
        var findUsers:PFQuery!
        findUsers = PFUser.query()!
        findUsers.whereKey("username", containsString: inputData.lowercaseString)
        
        findUsers.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            self.userData.removeAllObjects()
            
            if ((error == nil) && (objects != nil)) {
                self.userData = NSMutableArray(array: (objects! as NSArray))
            }
            
            self.userList.reloadData()
        }
    }
    
    //MARK: OTHER METHODS.
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Check the search text.
        let searchCheck = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (searchCheck.characters.count > 0) {
            self.getUserData(searchText)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: TABLEVIEW METHODS.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 65.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.searchBar.resignFirstResponder()
        self.dismissViewControllerAnimated(true) {
            NSNotificationCenter.defaultCenter().postNotificationName("userSelected", object: self.userData[indexPath.row] as! PFUser)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchUsersCell", forIndexPath: indexPath)
        
        // Get the current user object.
        let userObject:PFUser = self.userData[indexPath.row] as! PFUser
        
        // Get the cell UI objects.
        let userImageView:UIImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let usernameLabel:UILabel = cell.contentView.viewWithTag(2) as! UILabel
        
        // Set the username label.
        usernameLabel.text = userObject.username!
        
        // Set the user profile image.
        var profileImage = UIImage(named: "default_profile_pic.png")
        
        // Setup the user profile image file.
        if let userImageFile = userObject["profileImage"] {
            
            // Download the profile image.
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                
                if ((error == nil) && (imageData != nil)) {
                    profileImage = UIImage(data: imageData!)
                }
                userImageView.image = profileImage
            }
        } else {
            userImageView.image = profileImage
        }
        
        // Turn the profile picture into a circle.
        userImageView.layer.cornerRadius = (userImageView.frame.size.width / 2)
        userImageView.clipsToBounds = true
        userImageView.layer.borderWidth = 1.0
        userImageView.layer.borderColor = UIColor.clearColor().CGColor
        
        // Set the name label font.
        usernameLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        
        return cell
    }
}
