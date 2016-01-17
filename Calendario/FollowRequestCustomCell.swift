//
//  FollowRequestCustomCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 17/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowRequestCustomCell: UITableViewCell {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    
    // Awake From Nib method.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    // Other methods.
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
