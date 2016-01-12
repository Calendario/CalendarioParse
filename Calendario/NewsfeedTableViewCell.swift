//
//  NewsfeedTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/14/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import  KILabel
import DOFavoriteButton



class NewsfeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var UserNameLabel: UILabel!
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet var likebutton: DOFavoriteButton!
    
    
    @IBOutlet weak var profileimageview: UIImageView!
    
    @IBOutlet weak var uploaddatelabel: UILabel!
    
    
    @IBOutlet weak var tenselabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    
   
        
    
    
    @IBOutlet weak var likeslabel: UILabel!
   
    
    
   
    
    var counter = 0
    
    
    let filledlikebutton = UIImage(named: "like button filled")
    
    
    var isLiked = false
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
       
    }
    
    
    
    // like button method
    
    


    
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
