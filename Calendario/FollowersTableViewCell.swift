//
//  FollowersTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/7/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var realNameLabel: UILabel!
    
    @IBOutlet weak var imageview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
