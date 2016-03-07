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

    
    func setupUI () {
        self.statusTextView.textColor = UIColor.whiteColor()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setPostedImage(image : UIImage) {
        //let aspect = image.size.width / image.size.height
       // aspectConstraint = NSLayoutConstraint(item: userPostedImage, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: userPostedImage, attribute: NSLayoutAttribute.Height, multiplier: aspect, constant: 0.0)
        userPostedImage.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
        setupUI()
        assignGestureRecognizers()
    }
    
    // like button method

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
