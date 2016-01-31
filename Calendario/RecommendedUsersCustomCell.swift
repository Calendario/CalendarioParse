//
//  RecommendedUsersCustomCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 30/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class RecommendedUsersCustomCell: UITableViewCell {
    
    // Custom cell objects.
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    
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
