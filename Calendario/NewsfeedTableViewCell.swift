//
//  NewsfeedTableView swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/14/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel

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
    @IBOutlet weak var privateViewText: UITextView!
    @IBOutlet weak var rsvpButton: UIButton!
    @IBOutlet weak var rsvpLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var likebutton: UIView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var Likebuttoncontainerbutton: UIButton!
    @IBOutlet weak var userImageViewContainerHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageContainer: UIView!
    
    var attendGestureRecognizer: UITapGestureRecognizer!
    var passedInObject: PFObject!
    var parentViewController: AnyObject!
    var rsvpArray: [String] = []
    
    //MARK: LIFECYCLE METHODS
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        // Get the specific status object for this cell and call all needed methods.
        setupUI()
        createTenseAndDateLabel()
        setLocationLabelAndCheckingContents()
        checkForRsvpPrivacy()
        getLikesData()
        getRsvpData()
    }
    
    func setupUI () {
        self.statusTextView.textColor = UIColor.darkGrayColor()
        
        // Setup the cell likes button.
        likebutton.layer.cornerRadius = 2.0
        likebutton.clipsToBounds = true
        
        // Setup the RSVP button
        rsvpButton.layer.cornerRadius = 4.0
        rsvpButton.layer.borderWidth = 1.0
        rsvpButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        rsvpButton.clipsToBounds = true
        rsvpButton.backgroundColor = UIColor.whiteColor()
        attendantContainerView.layer.cornerRadius = 2.0
        attendantContainerView.clipsToBounds = true
        
        // Setup User Posted Image
        userPostedImage.layer.cornerRadius = 2.0
        userPostedImage.clipsToBounds = true
        
        // Setup the profile Image
        profileimageview.layer.cornerRadius = profileimageview.frame.height / 2
        profileimageview.layer.borderColor = UIColor.whiteColor().CGColor
        profileimageview.layer.borderWidth = 2.0
        profileimageview.clipsToBounds = true
        
        // Setup the status labels.
        
        if (passedInObject != nil) {
            self.statusTextView.text = passedInObject["updatetext"] as? String
            self.uploaddatelabel.text = passedInObject["dateofevent"] as? String
            self.eventTitle.text = passedInObject["eventTitle"] as? String
        }
            
        else {
            
            // Only show the private view as we are
            // looking at a profile which is private.
            self.privateView.alpha = 1.0
            
            // Set the private view lavel font.
            let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
            self.privateViewText.font = font
        }
        
    }
    
    func setPostedImage(image : UIImage) {
        userPostedImage.image = image
        
    }
    
    func createTenseAndDateLabel() {
        
        if (passedInObject != nil) {
            
            // Create the tense/date all in one attributed string.
            let attrs2 = [NSForegroundColorAttributeName:UIColor.lightGrayColor(), NSFontAttributeName : UIFont.systemFontOfSize(14)]
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
            checkForMentionsAndHighlight()
        }
    }
    
    func setLocationLabelAndCheckingContents() {
        
        if (passedInObject != nil) {
            
            let locationValue: String = passedInObject.objectForKey("location") as! String
            
            if locationValue == "tap to select location..." {
                self.locationLabel.text = ""
            }
                
            else {
                self.locationLabel.text = locationValue
            }
        }
    }
    
    //MARK: STATUS CHECK METHODS
    func checkForHashtagsAndHighlight() {
        
        if ((self.statusTextView.text?.hasPrefix("#")) != nil) {
            
            // Set the #hashtag green colour.
            self.statusTextView.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
            
            // Highlight the status hashtags.
            self.statusTextView.hashtagLinkTapHandler = {label, hashtag, range in
                
                // Save the hashtag string.
                var defaults:NSUserDefaults!
                defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(([1, hashtag]) as NSMutableArray, forKey: "HashtagData")
                defaults.synchronize()
                PresentingViews.presentHashtagsView(self)
            }
        }
    }
    
    func checkForMentionsAndHighlight() {
        
        if ((self.statusTextView.text?.hasPrefix("@")) != nil) {
            
            // Set the @mention green colour.
            self.statusTextView.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
            
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
                        PresentingViews.showProfileView(userObject!, viewController: self)
                    }
                })
            }
        }
    }
    
    func checkForRsvpPrivacy() {
        
        if (passedInObject != nil) {
            
            if passedInObject.valueForKey("privateRsvp") != nil {
                let rsvpPrivate: Bool = passedInObject.valueForKey("privateRsvp") as! Bool
                if rsvpPrivate == true {
                    self.rsvpButton.enabled = false
                    //self.attendantContainerView.removeGestureRecognizer(attendGestureRecognizer)
                    self.attendantContainerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
                    self.rsvpButton.alpha = 0.6
                }
                else if rsvpPrivate == false {
                    self.rsvpButton.enabled = true
                }
            }
        }
    }
    
    //MARK: UPDATE UI METHODS
    func updateLikesLabel(object: PFObject) {
        // Get the post likes data.
        let likesArray:[String] = object.objectForKey("likesarray") as! Array
        
        // Update the likes label.
        
        if (likesArray.count > 0) {
            
            // Update the status likes label.
            
            if (likesArray.count == 1) {
                self.likeslabel.text = "1"
            }
            else {
                self.likeslabel.text = "\(likesArray.count)"
            }
        }
        else {
            self.likeslabel.text = "0"
        }
    }
    
    func updateLikesButton(likePost: Bool, objectId: String) {
        
        if (likePost == true) {
            
            self.likebutton.backgroundColor = UIColor.whiteColor()
            
            // Submit and save the like notification.
            let likeString = "\(PFUser.currentUser()!.username!) has liked your post"
            self.SavingNotifacations(likeString, objectID: objectId, notificationType:"like")
        }
        else {
            self.likebutton.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        }
    }
    
    func updateRsvpLabel(object: PFObject) {
        
        // Get the post rsvp (attendants) data.
        let rsvpArray:[String] = object.objectForKey("rsvpArray") as! Array
        
        if (rsvpArray.count > 0) {
            if (rsvpArray.count == 1) {
                self.rsvpLabel.text = "1"
            }
            else {
                self.rsvpLabel.text = "\(rsvpArray.count)"
            }
        }
        else {
            self.rsvpLabel.text = "0"
        }
    }
    
    func updateRsvpButton(rsvpPost: Bool, objectId: String) {
        if (rsvpPost == true) {
            self.rsvpButton.selected = true
            
            // Submit and save the rsvp notification.
            let rsvpString = "\(PFUser.currentUser()!.username!) is attending your event"
            self.SavingNotifacations(rsvpString, objectID: objectId, notificationType:"rsvp")
        }
        else {
            self.rsvpButton.selected = false
        }
        
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
    
    //MARK: TAP GESTURE METHODS
    func commentsLabelClicked(sender: UITapGestureRecognizer) {
        let currentObject:PFObject = self.passedInObject
        // Open the comments view.
        PresentingViews.openComments(currentObject.objectId!, viewController: self)
    }
    
    func goToLikesList(sender: UITapGestureRecognizer) {
        
        let currentObject:PFObject = self.passedInObject
        // Save the status object ID.
        var defaults:NSUserDefaults!
        defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(currentObject.objectId!, forKey: "likesListID")
        defaults.synchronize()
        
        PresentingViews.showLikesView(self)
    }
    
    func likeClicked() {
        
        // Get the specific status object for this
        let currentObject:PFObject = passedInObject
        
        // Get the post likes data.
        let likesArray:[String] = currentObject.objectForKey("likesarray") as! Array
        
        // Check if the logged in user has
        // already like the selected status.
        if (likesArray.count > 0) {
            
            if likesArray.contains(PFUser.currentUser()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveLikeForPost(currentObject, likePost: false)
            }
            else {
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveLikeForPost(currentObject, likePost: true)
            }
        }
        else {
            // This status has zero likes so the logged
            // in user hasn't liked the post either so we
            // can go ahead and save the like for the user.
            self.saveLikeForPost(currentObject, likePost: true)
        }
    }
    
    func rsvpClicked() {
        // Get the specific status object for this
        let currentObject:PFObject = self.passedInObject
        
        // Get the post rsvp data.
        var rsvpArray: [String] = []
        if currentObject.objectForKey("rsvpArray") != nil {
            rsvpArray = currentObject.objectForKey("rsvpArray") as! Array
        }
        
        // Check if the logged in user has
        // already rsvp'd the selected status.
        if (rsvpArray.count > 0) {
            
            if rsvpArray.contains(PFUser.currentUser()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveRsvpForPost(currentObject, rsvpPost: false)
            }
            else {
                
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveRsvpForPost(currentObject, rsvpPost: true)
            }
        }
        else {
            
            // This status has zero likes so the logged
            // in user hasn't liked the post either so we
            // can go ahead and save the like for the user.
            self.saveRsvpForPost(currentObject, rsvpPost: true)
        }
    }
    
    func commentClicked(sender: UIButton) {
        PresentingViews.openComments(self.passedInObject.objectId!, viewController: self)
    }
    
    func goToProfile() {
        
        let currentObject:PFObject = self.passedInObject
        
        // Setup the user query.
        var userQuery:PFQuery!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
        
        // Download the user object.
        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                PresentingViews.showProfileView(((aobject as NSArray).lastObject as? PFUser)!, viewController: self)
            }
        }
    }
    
    
    //MARK: SAVE DATA METHODS
    
    func saveLikeForPost(statusObject: PFObject, likePost: Bool) {
        
        // Setup the likes query.
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackgroundWithId(statusObject.objectId!) { (object, error) -> Void in
            
            // Check for errors before saving the like/dislike.
            if ((error == nil) && (object != nil)) {
                
                if (likePost == true) {
                    
                    // Add the user to the post likes array.
                    object?.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "likesarray")
                }
                else {
                    
                    // Remove the user from the post likes array.
                    object?.removeObject(PFUser.currentUser()!.objectId!, forKey: "likesarray")
                }
                
                // Save the like/dislike data.
                object?.saveInBackgroundWithBlock({ (success, likeError) -> Void in
                    
                    // Only update the like button if the
                    // background data save was successful.
                    
                    if ((success) && (likeError == nil)) {
                        
                        // Make sure the local array data if
                        // up to date otherwise the like button
                        // will be un-checked when the user scrolls.
                        self.passedInObject = object!
                        
                        self.updateLikesLabel(object!)
                        self.updateLikesButton(likePost, objectId: statusObject.objectId!)
                    }
                })
            }
        }
    }
    
    func SavingNotifacations(notifcation:String, objectID:String, notificationType:String) {
        
        // Setup the notificatios query.
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackgroundWithId(objectID) { (object, error) -> Void in
            
            // Only post the notification if no
            // errors have been returned.
            
            if (error == nil) {
                
                // Only post the notification if the user who
                // performed the action is NOT the logged in user.
                
                if (PFUser.currentUser()!.objectId! != (object?.objectForKey("user") as! PFUser).objectId!) {
                    
                    // Submit the push notification.
                    PFCloud.callFunctionInBackground("StatusUpdate", withParameters: ["message" : notifcation, "user" : "\(PFUser.currentUser()?.username!)"])
                    
                    // Save the notification data.
                    ManageUser.saveUserNotification(notifcation, fromUser: PFUser.currentUser()!, toUser: object?.objectForKey("user") as! PFUser, extType: notificationType, extObjectID: objectID)
                }
            }
        }
    }
    
    func saveRsvpForPost(statusObject: PFObject, rsvpPost: Bool) {
        
        // Setup the likes query.
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackgroundWithId(statusObject.objectId!) { (object, error) -> Void in
            
            // Check for errors before saving the like/dislike.
            
            if ((error == nil) && (object != nil)) {
                
                if (rsvpPost == true) {
                    
                    // Add the user to the post rsvp array.
                    object?.addUniqueObject(PFUser.currentUser()!.objectId!, forKey: "rsvpArray")
                }
                else {
                    // Remove the user from the post likes array.
                    object?.removeObject(PFUser.currentUser()!.objectId!, forKey: "rsvpArray")
                }
                
                // Save the like/dislike data.
                object?.saveInBackgroundWithBlock({ (success, rsvpError) -> Void in
                    
                    // Only update the rsvp button if the
                    // background data save was successful.
                    
                    if ((success) && (rsvpError == nil)) {
                        
                        // Make sure the local array data if
                        // up to date otherwise the rsvp button
                        // will be un-checked when the user scrolls.
                        self.passedInObject = object!
                        self.updateRsvpLabel(object!)
                        self.updateRsvpButton(rsvpPost, objectId: statusObject.objectId!)
                    }
                })
            }
        }
    }
    
    func getLikesData() {
        
        if (passedInObject != nil) {
            
            let likesData:[String] = passedInObject.objectForKey("likesarray") as! Array
            highlightLikedButton(likesData)
            updateLikeCount(likesData)
        }
    }
    
    func getRsvpData() {
        
        if (passedInObject != nil) {
            
            if passedInObject.objectForKey("rsvpArray") != nil {
                rsvpArray = passedInObject.objectForKey("rsvpArray") as! Array
            }
            self.updateRsvpLabel(passedInObject)
        }
    }
    
    // Profile view image button
    
    @IBAction func openProfileTapped(sender: AnyObject) {
        self.goToProfile()
    }
    
    // Main news item image method
    
    @IBAction func feedImageTapped(sender: AnyObject) {
        PresentingViews.showPhotoViewer(self, userPostedImage: self.userPostedImage)
    }
    
    // like button container button action method
    
    @IBAction func Likebuttoncontaineraction(sender: AnyObject) {
        likeClicked()
    }
    
    // Attendants button container: button action method
    
    @IBAction func AttendantsListContainerInteraction(sender: AnyObject) {
        PresentingViews.ViewAttendantsListView(parentViewController, eventID: passedInObject.objectId!)
    }
    
    // RSVP button container: button action method
    
    @IBAction func RSVPbuttontapped(sender: AnyObject) {
        self.rsvpClicked()
    }
    
    // Comment button container: button action method
    
    @IBAction func CommentButtonTapped(sender: AnyObject) {
        self.commentClicked(sender as! UIButton)
    }
}
