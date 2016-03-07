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
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var statusTextView: KILabel!
    @IBOutlet weak var attendantContainerView: UIView!
    @IBOutlet weak var commentButton: UIView!
    @IBOutlet weak var profileimageview: UIImageView!
    @IBOutlet weak var uploaddatelabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeslabel: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var rsvpButton: DOFavoriteButton!
    @IBOutlet weak var rsvpLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var likebutton: UIView!
    
    var attendGestureRecognizer: UITapGestureRecognizer!

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
        setupUI()
        assignGestureRecognizers()
    }
    
    func setupUI () {
        self.statusTextView.textColor = UIColor.whiteColor()
       
        // Setup the cell likes button.
        likebutton.translatesAutoresizingMaskIntoConstraints = true
        likebutton.layer.cornerRadius = 2.0
        likebutton.clipsToBounds = false
        
        //setup the RSVP button
        rsvpButton.layer.cornerRadius = 2.0
        rsvpButton.clipsToBounds = true
        attendantContainerView.layer.cornerRadius = 2.0
        attendantContainerView.clipsToBounds = true

        //setup the profile Image
        profileimageview.layer.cornerRadius =  2.0  //(cell.profileimageview.frame.size.width / 2)
        profileimageview.clipsToBounds = true

        
    }
    
    func setPostedImage(image : UIImage) {
        //let aspect = image.size.width / image.size.height
        // aspectConstraint = NSLayoutConstraint(item: userPostedImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: userPostedImage, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
        userPostedImage.image = image
    }
    
    func assignGestureRecognizers() {
        let commentGestureRecognizer = UITapGestureRecognizer(target: self, action: "commentClicked")
        commentButton.addGestureRecognizer(commentGestureRecognizer)
        
        let likeGestureRecognizer = UITapGestureRecognizer(target: self, action: "likeClicked:")
        likebutton.addGestureRecognizer(likeGestureRecognizer)
        
        self.attendGestureRecognizer = UITapGestureRecognizer(target: self, action: "rsvpClicked:")
        attendantContainerView.addGestureRecognizer(attendGestureRecognizer)
    }

    
    
    
    
}
