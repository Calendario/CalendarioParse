//
//  FollowingTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/6/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var UserNameLabel: UILabel!

    @IBOutlet weak var RealNameLabel: UILabel!
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
