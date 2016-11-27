//
//  ThreadCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 18/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class ThreadCell: UITableViewCell {

    //MARK: UI OBJECTS.
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var latestMessage: UITextView!
    
    //MARK: LIFECYCLE METHODS.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
