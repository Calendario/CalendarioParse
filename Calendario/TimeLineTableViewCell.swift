//
//  TimeLineTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/18/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var profileimageview: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var tenseLabel: UILabel!
    @IBOutlet weak var updateTextView: UILabel!

    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var colorStrip: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.updateTextView.textColor = UIColor.darkGrayColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
