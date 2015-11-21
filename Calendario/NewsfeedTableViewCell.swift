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
    
    @IBOutlet weak var profileimageview: UIImageView!

    
    
    let filledlikebutton = UIImage(named: "like button filled")
    var counter:Int = 0
    
    var isLiked = false
    let defaults = NSUserDefaults.standardUserDefaults()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
    // like button method
    
    @IBAction func LikeButtonTapped(sender: AnyObject) {
        LikeButton.setImage(filledlikebutton, forState: .Normal)
        
        var objid = defaults.stringForKey("objectid")
        print(objid!)
        
        var query = PFQuery(className: "StatusUpdate")
        query.getObjectInBackgroundWithId(objid!) { (statusupdate:PFObject?, error:NSError?) -> Void in
            if error == nil
            {
                statusupdate!["likes"] = statusupdate?.objectForKey("likes") as! Int + 1
                print("like button tapped")
                
                statusupdate?.saveInBackground()
                print(self.counter++)
            }
        }
  
        

    }
    
  
    

    
    
    
   
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
