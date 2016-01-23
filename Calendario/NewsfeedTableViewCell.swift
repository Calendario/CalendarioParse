//
//  NewsfeedTableViewCell.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/14/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel
import DOFavoriteButton



class NewsfeedTableViewCell: PFTableViewCell {
    
    
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var userPostedImage: PFImageView!
    
    //@IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var statusTextView: KILabel!
    @IBOutlet var likebutton: DOFavoriteButton!
    
    
    @IBOutlet weak var profileimageview: UIImageView!
    
    @IBOutlet weak var uploaddatelabel: UILabel!
    
    
    
    @IBOutlet weak var locationLabel: UILabel!
    

    @IBOutlet weak var commentsButton: UIButton!
        
    
    
    @IBOutlet weak var likeslabel: UILabel!
   
    
    
   
    
    var counter = 0
    
    
    let filledlikebutton = UIImage(named: "like button filled")
    
    
    var isLiked = false
    let defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    
    //TEST
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                userPostedImage.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                userPostedImage.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
        
    

    
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
