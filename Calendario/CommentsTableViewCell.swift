//
//  CommentsTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/28/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel
import Parse

class CommentsTableViewCell: PFTableViewCell {
    
    // @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var commentTextView: KILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    // Passed in data objects.
    var parentViewController: AnyObject!
    var passedInObject: PFObject!

    //MARK: DATA METHODS.
    
    func goToProfile() {
        
        // Setup the user query.
        var userQuery:PFQuery<PFObject>!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: (self.passedInObject.value(forKey: "postedby") as! PFUser).objectId!)
        
        // Download the user object.
        userQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let aobject = objects {
                PresentingViews.showProfileView(((aobject as NSArray).lastObject as? PFUser)!, viewController: self.parentViewController)
            }
        }
    }
    
    func loadUserData() {
        
        var usernamequery:PFQuery<PFObject>!
        usernamequery = PFUser.query()
        usernamequery?.getObjectInBackground(withId: ((self.passedInObject.value(forKey: "postedby") as? PFObject)!.objectId!), block: { (object, error) -> Void in
            
            if error == nil {
                
                let nameString = object?.value(forKey: "username") as! String
                self.UserLabel.text = nameString
                
                if let image = object!["profileImage"] as! PFFile? {
                    
                    image.getDataInBackground(block: { (ImageData, error) -> Void in
                        
                        OperationQueue.main.addOperation {() -> Void in
                            
                            if error == nil {
                                
                                let image = UIImage(data: ImageData!)
                                self.userProfileImage.image = image
                                self.layoutIfNeeded()
                            }
                                
                            else {
                                self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                                self.layoutIfNeeded()
                            }
                            
                            // Set the profile picture to a circle.
                            self.userProfileImage.layer.cornerRadius = (self.userProfileImage.frame.size.width / 2)
                            self.userProfileImage.clipsToBounds = true
                        }
                    })
                } else {
                    
                    OperationQueue.main.addOperation {() -> Void in
                        self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                        self.layoutIfNeeded()
                    }
                }
            }
                
            else {
                
                OperationQueue.main.addOperation {() -> Void in
                    self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                    self.layoutIfNeeded()
                }
            }
        })
    }
    
    //MARK: LIFECYCLE METHODS
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hide the previous cell image.
        self.userProfileImage.image = nil
        
        // Enable the profile image.
        self.userProfileImage.isUserInteractionEnabled = true
        
        // Set the user tapped gesture recognizer.
        let profileGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(CommentsTableViewCell.goToProfile))
        self.userProfileImage.addGestureRecognizer(profileGestureReconizer)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
