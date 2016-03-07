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
    var passedInObject: PFObject!
    var parentViewController: AnyObject!
    var rsvpArray: [String] = []
    
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
        createTenseAndDateLabel()
        findUserDetails()
        setLocationLabelAndCheckingContents()
        checkForRsvpPrivacy()
        checkForUserPostedImage()
        getLikesData()
        getRsvpData()
        setCreatedAtLabel()
        updateCommentsLabel()
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
        
        //setup User Posted Image
        userPostedImage.clipsToBounds = true
        
        //setup the profile Image
        profileimageview.layer.cornerRadius =  2.0
        profileimageview.clipsToBounds = true
        
        //setup the status labels.
        self.statusTextView.text = passedInObject["updatetext"] as? String
        self.uploaddatelabel.text = passedInObject["dateofevent"] as? String
        
        //setup the cell rsvp button
        self.rsvpButton.translatesAutoresizingMaskIntoConstraints = true
        self.rsvpButton.addTarget(self, action: "rsvpClicked:", forControlEvents: .TouchUpInside)
    }
    
    func getLikesData() {
        let likesData:[String] = passedInObject.objectForKey("likesarray") as! Array
        highlightLikedButton(likesData)
        updateLikeCount(likesData)
    }
    
    func highlightLikedButton(likesArray: [String]) {
        if likesArray.contains(PFUser.currentUser()!.objectId!) {
            self.likebutton.backgroundColor = UIColor.whiteColor()
        }
        else {
            self.likebutton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        }
    }
    
    func updateLikeCount(likesArray: [String]) {
        if (likesArray.count > 0) {
            if (likesArray.count == 1) {
                self.likeslabel.text = "1"
            }
            else
            {
                self.likeslabel.text = "\(likesArray.count)"
            }
        }
        else {
            self.likeslabel.text = "0"
        }
    }
    
    func getRsvpData() {
        if passedInObject.objectForKey("rsvpArray") != nil {
            rsvpArray = passedInObject.objectForKey("rsvpArray") as! Array
        }
        updateRsvpLabel()
    }
    
    func updateRsvpLabel () {
        if (rsvpArray.count > 0) {
            
            if (rsvpArray.count == 1) {
                self.rsvpLabel.text = "1 person attending this event"
            }
            else {
                self.rsvpLabel.text = "\(rsvpArray.count) people attending this event"
            }
            
            // Update the rsvp button.
            
            if rsvpArray.contains(PFUser.currentUser()!.objectId!) {
                self.rsvpButton.select()
                self.attendantContainerView.backgroundColor = UIColor.whiteColor()
            }
            else {
                self.rsvpButton.deselect()
                self.attendantContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
            }
        }
        else {
            self.rsvpLabel.text = "0 people attending this event"
        }
    }
    
    func setCreatedAtLabel() {
        DateManager.createDateDifferenceString(passedInObject.createdAt!) { (difference) -> Void in
            self.createdAtLabel.text = difference
        }
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
        
        let tapGesturePostImage = UITapGestureRecognizer(target: self, action: "imageTapped:")
        self.userPostedImage.addGestureRecognizer(tapGesturePostImage)
        
        let tapGestureProfileImage = UITapGestureRecognizer(target: self, action: "goToProfile:")
        self.profileimageview.addGestureRecognizer(tapGestureProfileImage)
    }
    
    func createTenseAndDateLabel() {
        // Create the tense/date all in one attributed string.
        let attrs2 = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
        let tensestring2 = NSMutableAttributedString(string: passedInObject.objectForKey("tense") as! String, attributes: attrs2)
        let spacestring2 = NSMutableAttributedString(string: " ")
        let onstring = NSAttributedString(string: "on")
        let spacestr3 = NSAttributedString(string: " ")
        tensestring2.appendAttributedString(spacestring2)
        tensestring2.appendAttributedString(onstring)
        tensestring2.appendAttributedString(spacestr3)
        let dateattrstring = NSAttributedString(string: passedInObject.objectForKey("dateofevent") as! String, attributes: attrs2)
        tensestring2.appendAttributedString(dateattrstring)
        
        // Set the date/tense all in one label.
        self.uploaddatelabel.attributedText = tensestring2
        checkForHashtagsAndHighlight()
    }
    
    func setLocationLabelAndCheckingContents() {
        let locationValue: String = passedInObject.objectForKey("location") as! String
        
        if locationValue == "tap to select location..." {
            self.locationLabel.text = ""
        }
            
        else {
            self.locationLabel.text = locationValue
        }
    }
    
    func checkForHashtagsAndHighlight() {
        if ((self.statusTextView.text?.hasPrefix("#")) != nil) {
            
            // Highlight the status hashtags.
            self.statusTextView.hashtagLinkTapHandler = {label, hashtag, range in
                
                // Save the hashtag string.
                var defaults:NSUserDefaults!
                defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(([1, hashtag]) as NSMutableArray, forKey: "HashtagData")
                defaults.synchronize()
                self.presentHashtagsView()
            }
        }
    }
    
    func presentHashtagsView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("HashtagNav") as! UINavigationController
        self.parentViewController.presentViewController(likesView, animated: true, completion: nil)
    }
    
    func checkForMentionsAndHighlight() {
        if ((self.statusTextView.text?.hasPrefix("@")) != nil) {
            
            // Highlight the @username label.
            self.statusTextView.userHandleLinkTapHandler = {label2, mention, range in
                
                // Remove the '@' symbol from the username
                let userMention = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                
                // Setup the user query.
                var query:PFQuery!
                query = PFUser.query()
                query.whereKey("username", equalTo: userMention)
                
                // Get the user data object.
                query.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                    
                    // Check for errors before passing
                    if ((error == nil) && (userObject != nil)) {
                        self.showProfileView(userObject!)
                    }
                })
            }
        }
    }
    
    
    func showProfileView(passedUserObject: PFObject) {
        // Open the selected users profile.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        reportVC.passedUser = passedUserObject as! PFUser
        parentViewController.presentViewController(reportVC, animated: true, completion: nil)
    }
    
    func checkForRsvpPrivacy() {
        if passedInObject.valueForKey("privateRsvp") != nil {
            let rsvpPrivate: Bool = passedInObject.valueForKey("privateRsvp") as! Bool
            if rsvpPrivate == true {
                self.rsvpButton.enabled = false
                self.attendantContainerView.removeGestureRecognizer(attendGestureRecognizer)
                self.attendantContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
                
                let rsvpPrivateImage: UIImage = UIImage(named: "rsvp_private_icon")!
                self.rsvpButton.image = rsvpPrivateImage
            }
            else if rsvpPrivate == false {
                self.rsvpButton.enabled = true
                
                let rsvpImage: UIImage = UIImage(named: "attend_icon")!
                self.rsvpButton.image = rsvpImage
            }
        }
    }
    
    func checkForUserPostedImage() {
        if (passedInObject.objectForKey("image") == nil) {
            self.userPostedImage.alpha = 0.0
            self.imageViewHeightConstraint.constant = 1
            self.updateConstraintsIfNeeded()
        }
        else {
            // Show the Media image view.
            self.userPostedImage.alpha = 1.0
            self.imageViewHeightConstraint.constant = 127
            self.updateConstraintsIfNeeded()
            
            // Setup the user profile image file.
            let statusImage = passedInObject["image"] as! PFFile
            
            // Download the profile image.
            statusImage.getDataInBackgroundWithBlock { (mediaData: NSData?, error: NSError?) -> Void in
                if ((error == nil) && (mediaData != nil)) {
                    self.userPostedImage.image = UIImage(data: mediaData!)
                }
                else {
                    self.userPostedImage.image = UIImage(imageLiteral: "no-image-icon + Rectangle 4")
                }
            }
        }
    }
    
    func updateCommentsLabel() {
        var commentsquery:PFQuery!
        commentsquery = PFQuery(className: "comment")
        commentsquery.orderByDescending("createdAt")
        commentsquery.addDescendingOrder("updatedAt")
        commentsquery.whereKey("statusOBJID", equalTo: passedInObject.objectId!)
        commentsquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                if (objects!.count == 1) {
                    self.commentsLabel.text = "1"
                }
                else {
                    self.commentsLabel.text = "\(String(objects!.count))"
                }
            }
            else {
                self.commentsLabel.text = "0"
            }
        }
        
    }
    
    func findUserDetails() {
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: (passedInObject.objectForKey("user")?.objectId)!)
        
        // Download the user detials.
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                self.UserNameLabel.text = userObject?.username
                
                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                let userImageFile = userObject!["profileImage"] as! PFFile
                
                // Download the profile image.
                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (imageData != nil)) {
                        profileImage = UIImage(data: imageData!)
                    }
                    
                    self.profileimageview.image = profileImage
                }
            }
        }
    }
    
    
    
    
    
}
