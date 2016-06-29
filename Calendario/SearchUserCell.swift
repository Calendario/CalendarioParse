//
//  SearchUserCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 28/06/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class SearchUserCell: UICollectionViewCell {
    
    // Cell UI objects.
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    
    // Passed in user object.
    var passedInUser: PFUser!
    
    //MARK: LIFECYCLE METHODS.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userProfilePicture.image = nil;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.setupUI()
        self.setUserDetails()
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Set the cell background colour.
        self.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 1.0)
        
        // Turn the profile picture into a circle.
        self.userProfilePicture.layer.cornerRadius = (self.userProfilePicture.frame.size.width / 2)
        self.userProfilePicture.clipsToBounds = true
        self.userProfilePicture.layer.borderWidth = 1.0
        self.userProfilePicture.layer.borderColor = UIColor.clearColor().CGColor
        
        // Set the name label font.
        self.nameLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        self.nameLabel.textColor = UIColor.blackColor()
    }
    
    func setUserDetails() {
        
        // Check the profile image data first.
        var profileImage = UIImage(named: "default_profile_pic.png")
        
        if (self.passedInUser != nil) {
            
            // Set the user full name.
            self.nameLabel.text = self.passedInUser.username!
                        
            // Setup the user profile image file.
            if let userImageFile = self.passedInUser!["profileImage"] {
                
                // Download the profile image.
                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (imageData != nil)) {
                        profileImage = UIImage(data: imageData!)
                    }
                    self.userProfilePicture.image = profileImage
                }
            } else {
                self.userProfilePicture.image = profileImage
            }
        } else {
            self.userProfilePicture.image = profileImage
        }
    }
}
