//
//  CommentsTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/28/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel

class CommentsTableViewCell: UITableViewCell {
    
    
   // @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var commentTextView: KILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
