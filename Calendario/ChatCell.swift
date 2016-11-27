//
//  ChatCell.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 26/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    //MARK: UI OBJECTS.
    @IBOutlet weak var messageImage: UIImageView!
    @IBOutlet weak var messageText: UITextView!
    
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
