//
//  NewsfeedTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/14/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class NewsfeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var UserNameLabel: UILabel!
    
    @IBOutlet weak var statusTextView: UITextView!

    @IBOutlet weak var LikeButton: UIButton!
    
    let nf = NewsfeedViewController()
    
    
    let filledlikebutton = UIImage(named: "like button filled")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    // like button method
    
    @IBAction func LikeButtonTapped(sender: AnyObject) {
        LikeButton.setImage(filledlikebutton, forState: .Normal)
    
            }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
