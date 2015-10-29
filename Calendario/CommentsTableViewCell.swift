//
//  CommentsTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/28/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var UserLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
