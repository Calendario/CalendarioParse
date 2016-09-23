//
//  LikesCustomCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 18/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class LikesCustomCell: UITableViewCell {
    
    // Custom cell objects.
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // View Did Load method.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // Other methods.
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

