//
//  CommentsTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/28/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel

class CommentsTableViewCell: PFTableViewCell {
    
   // @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var UserLabel: UILabel!
    @IBOutlet weak var commentTextView: KILabel!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    //MARK: LIFECYCLE METHODS
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hide the previous cell image.
        self.userProfileImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
