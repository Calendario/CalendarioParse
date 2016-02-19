//
//  ProfileViewCustomCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 09/01/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class ProfileViewCustomCell: UITableViewCell {
    
    // Custom cell objects.
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadDateLabel: UILabel!
    @IBOutlet weak var tenseLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var statusTextView: UILabel!
    
    // View Did Load method.
    
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

