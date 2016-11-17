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
    @IBOutlet weak var userPostedImage: UIImageView!
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
    @IBOutlet weak var likeButtonImage: UIImageView!
    
    var attendGestureRecognizer: UITapGestureRecognizer!
    var passedInObject: PFObject!
    var parentViewController: AnyObject!
    var rsvpArray: [String] = []
    
    //MARK: LIFECYCLE METHODS
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Hide the previous cell image.
        self.profileimageview.image = nil
        self.userPostedImage.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        // Get the specific status object for this cell and call all needed methods.
        self.setupUI()
        self.createTenseAndDateLabel()
        self.setLocationLabelAndCheckingContents()
        self.checkForRsvpPrivacy()
        self.getLikesData()
        self.getRsvpData()
    }
    
    func setupUI () {
        self.statusTextView.textColor = UIColor.darkGray
        
        // Setup the cell likes button.
        self.likebutton.layer.cornerRadius = 2.0
        self.likebutton.clipsToBounds = true
        
        // Setup the RSVP button
        self.rsvpButton.layer.cornerRadius = 4.0
        self.rsvpButton.layer.borderWidth = 1.0
        self.rsvpButton.layer.borderColor = UIColor.lightGray.cgColor
        self.rsvpButton.clipsToBounds = true
        self.rsvpButton.backgroundColor = UIColor.white
        self.attendantContainerView.layer.cornerRadius = 2.0
        self.attendantContainerView.clipsToBounds = true
        
        // Set the date label text font.
        self.uploaddatelabel.font = UIFont.systemFont(ofSize: 14)
        self.uploaddatelabel.textColor = UIColor.lightGray
        
        // Setup User Posted Image
        self.userPostedImage.layer.cornerRadius = 2.0
        self.userPostedImage.clipsToBounds = true
        
        // Setup the profile Image
        self.profileimageview.layer.cornerRadius = self.profileimageview.frame.height / 2
        self.profileimageview.layer.borderColor = UIColor.white.cgColor
        self.profileimageview.layer.borderWidth = 2.0
        self.profileimageview.clipsToBounds = true
        
        // Setup the status labels.
        
        if (self.passedInObject != nil) {
            self.statusTextView.text = self.passedInObject["updatetext"] as? String
            self.uploaddatelabel.text = self.passedInObject["dateofevent"] as? String
            self.eventTitle.text = self.passedInObject["eventTitle"] as? String
            
            if (passedInObject.object(forKey: "image") == nil) {
                self.userPostedImage.image = nil
                self.userImageViewContainerHeightContstraint.constant = 0
            } else {
                self.userImageViewContainerHeightContstraint.constant = 205
            }
            
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
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
    
    func setPostedImage(_ image : UIImage) {
        self.userPostedImage.image = image
    }
    
    func createTenseAndDateLabel() {
        
        if (self.passedInObject != nil) {
            
            // Create the tense/date all in one string.
            let dateOfPassedInEvent = self.passedInObject.object(forKey: "dateofevent") as! String
            let fullDateTitle = "\(self.tenseChanged(dateOfPassedInEvent)) on \(dateOfPassedInEvent)"
            
            // Set the date/tense all in one label.
            self.uploaddatelabel.text = fullDateTitle
            
            // Highlight the hashtags and @mentions.
            self.checkForHashtagsAndHighlight()
            self.checkForMentionsAndHighlight()
        }
    }
    
    func tenseChanged(_ passedInEventDate: String) -> String {
        
        // Get the cureent date.
        let currentDate:Date = Date()
        
        // Create a date formatter to turn the date into a readable string.
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        
        // The current date is passed in the date formatter method.
        let datefromstring = dateformatter.date(from: passedInEventDate)
        
        // Set the tense label depending on the comparison result.
        
        if currentDate.compare(datefromstring!) == ComparisonResult.orderedAscending {
            
            // Current date is earlier than date of event.
            return "Going"
            
        } else if currentDate.compare(datefromstring!) == ComparisonResult.orderedDescending {
            
            // Current date is later than date of event.
            return "Went"
            
        } else if currentDate.compare(datefromstring!) == ComparisonResult.orderedSame {
            
            // Current date is same than date of event.
            return "Currently"
            
        } else {
            return "Currently"
        }
    }
    
    func setLocationLabelAndCheckingContents() {
        
        if (self.passedInObject != nil) {
            
            let locationValue: String = self.passedInObject.object(forKey: "location") as! String
            
            if locationValue == "tap to select location..." {
                self.locationLabel.text = ""
            } else {
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
                var defaults:UserDefaults!
                defaults = UserDefaults.standard
                defaults.set(([1, hashtag]) as NSMutableArray, forKey: "HashtagData")
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
                let userMention = mention.replacingOccurrences(of: "@", with: "")
                
                // Setup the user query.
                var query:PFQuery<PFObject>!
                query = PFUser.query()
                query.whereKey("username", equalTo: userMention)
                
                // Get the user data object.
                query.getFirstObjectInBackground(block: { (userObject, error) -> Void in
                    
                    // Check for errors before passing
                    if ((error == nil) && (userObject != nil)) {
                        PresentingViews.showProfileView(userObject!, viewController: self)
                    }
                })
            }
        }
    }
    
    func checkForRsvpPrivacy() {
        
        if (self.passedInObject != nil) {
            
            if passedInObject.value(forKey: "privateRsvp") != nil {
                let rsvpPrivate: Bool = passedInObject.value(forKey: "privateRsvp") as! Bool
                if rsvpPrivate == true {
                    self.rsvpButton.isEnabled = false
                    //self.attendantContainerView.removeGestureRecognizer(attendGestureRecognizer)
                    self.attendantContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                    self.rsvpButton.alpha = 0.6
                }
                else if rsvpPrivate == false {
                    self.rsvpButton.isEnabled = true
                }
            }
        }
    }
    
    //MARK: UPDATE UI METHODS
    func updateLikesLabel(_ object: PFObject) {
        // Get the post likes data.
        let likesArray:[String] = object.object(forKey: "likesarray") as! Array
        
        // Update the likes label.
        
        if (likesArray.count > 0) {
            
            // Update the status likes label.
            
            if (likesArray.count == 1) {
                self.likeslabel.text = "1"
            } else {
                self.likeslabel.text = "\(likesArray.count)"
            }
        } else {
            self.likeslabel.text = "0"
        }
    }
    
    func updateLikesButton(_ likePost: Bool, objectId: String) {
        
        if (likePost == true) {
            
            self.likebutton.backgroundColor = UIColor.white
            
            // Submit and save the like notification.
            let likeString = "\(PFUser.current()!.username!) has liked your post"
            self.SavingNotifacations(likeString, objectID: objectId, notificationType:"like")
        }
        else {
            self.likebutton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        }
    }
    
    func updateRsvpLabel(_ object: PFObject) {
        
        // Get the post rsvp (attendants) data.
        let rsvpArray:[String] = object.object(forKey: "rsvpArray") as! Array
        
        if (rsvpArray.count > 0) {
            if (rsvpArray.count == 1) {
                self.rsvpLabel.text = "1"
            } else {
                self.rsvpLabel.text = "\(rsvpArray.count)"
            }
        }
        else {
            self.rsvpLabel.text = "0"
        }
    }
    
    func updateRsvpButton(_ rsvpPost: Bool, objectId: String) {
        if (rsvpPost == true) {
            self.rsvpButton.isSelected = true
            
            // Submit and save the rsvp notification.
            let rsvpString = "\(PFUser.current()!.username!) is attending your event"
            self.SavingNotifacations(rsvpString, objectID: objectId, notificationType:"rsvp")
        } else {
            self.rsvpButton.isSelected = false
        }
        
    }
    
    func highlightLikedButton(_ likesArray: [String]) {
        if likesArray.contains(PFUser.current()!.objectId!) {
            self.likebutton.backgroundColor = UIColor.white
            self.likeButtonImage.image = UIImage(named: "Like Icon.png")
        } else {
            self.likebutton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            self.likeButtonImage.image = UIImage(named: "Like Icon.png")
        }
    }
    
    func updateLikeCount(_ likesArray: [String]) {
        if (likesArray.count > 0) {
            if (likesArray.count == 1) {
                self.likeslabel.text = "1"
            } else {
                self.likeslabel.text = "\(likesArray.count)"
            }
        } else {
            self.likeslabel.text = "0"
        }
    }
    
    //MARK: TAP GESTURE METHODS
    func commentsLabelClicked(_ sender: UITapGestureRecognizer) {
        let currentObject:PFObject = self.passedInObject
        // Open the comments view.
        PresentingViews.openComments(currentObject.objectId!, viewController: self)
    }
    
    func goToLikesList(_ sender: UITapGestureRecognizer) {
        
        let currentObject:PFObject = self.passedInObject
        // Save the status object ID.
        var defaults:UserDefaults!
        defaults = UserDefaults.standard
        defaults.set(currentObject.objectId!, forKey: "likesListID")
        defaults.synchronize()
        
        PresentingViews.showLikesView(self)
    }
    
    func likeClicked() {
        
        // Get the specific status object for this
        let currentObject:PFObject = passedInObject
        
        // Get the post likes data.
        let likesArray:[String] = currentObject.object(forKey: "likesarray") as! Array
        
        // Check if the logged in user has
        // already like the selected status.
        if (likesArray.count > 0) {
            
            if likesArray.contains(PFUser.current()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveLikeForPost(currentObject, likePost: false)
            } else {
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveLikeForPost(currentObject, likePost: true)
            }
        } else {
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
        if currentObject.object(forKey: "rsvpArray") != nil {
            rsvpArray = currentObject.object(forKey: "rsvpArray") as! Array
        }
        
        // Check if the logged in user has
        // already rsvp'd the selected status.
        if (rsvpArray.count > 0) {
            
            if rsvpArray.contains(PFUser.current()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveRsvpForPost(currentObject, rsvpPost: false)
            } else {
                
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveRsvpForPost(currentObject, rsvpPost: true)
            }
        } else {
            
            // This status has zero likes so the logged
            // in user hasn't liked the post either so we
            // can go ahead and save the like for the user.
            self.saveRsvpForPost(currentObject, rsvpPost: true)
        }
    }
    
    func commentClicked(_ sender: UIButton) {
        PresentingViews.openComments(self.passedInObject.objectId!, viewController: self)
    }
    
    func goToProfile() {
        
        let currentObject:PFObject = self.passedInObject
        
        // Setup the user query.
        var userQuery:PFQuery<PFObject>!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: (currentObject.object(forKey: "user") as! PFUser).objectId!)
        
        // Download the user object.
        userQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if let aobject = objects {
                PresentingViews.showProfileView(((aobject as NSArray).lastObject as? PFUser)!, viewController: self)
            }
        }
    }
    
    //MARK: SAVE DATA METHODS
    
    func saveLikeForPost(_ statusObject: PFObject, likePost: Bool) {
        
        // Setup the likes query.
        var query:PFQuery<PFObject>!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackground(withId: statusObject.objectId!) { (object, error) -> Void in
            
            // Check for errors before saving the like/dislike.
            if ((error == nil) && (object != nil)) {
                
                if (likePost == true) {
                    
                    // Add the user to the post likes array.
                    object?.addUniqueObject(PFUser.current()!.objectId!, forKey: "likesarray")
                } else {
                    
                    // Remove the user from the post likes array.
                    object?.remove(PFUser.current()!.objectId!, forKey: "likesarray")
                }
                
                // Save the like/dislike data.
                object?.saveInBackground(block: { (success, likeError) -> Void in
                    
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
    
    func SavingNotifacations(_ notifcation:String, objectID:String, notificationType:String) {
        
        // Setup the notificatios query.
        var query:PFQuery<PFObject>!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackground(withId: objectID) { (object, error) -> Void in
            
            // Only post the notification if no
            // errors have been returned.
            
            if (error == nil) {
                
                // Only post the notification if the user who
                // performed the action is NOT the logged in user.
                
                if (PFUser.current()!.objectId! != (object?.object(forKey: "user") as! PFUser).objectId!) {
                    
                    // Submit the push notification.
                    PFCloud.callFunction(inBackground: "StatusUpdate", withParameters: ["message" : notifcation, "user" : "\(PFUser.current()?.objectId!)"])
                    
                    // Save the notification data.
                    ManageUser.saveUserNotification(notifcation, fromUser: PFUser.current()!, toUser: object?.object(forKey: "user") as! PFUser, extType: notificationType, extObjectID: objectID)
                }
            }
        }
    }
    
    func saveRsvpForPost(_ statusObject: PFObject, rsvpPost: Bool) {
        
        // Setup the likes query.
        var query:PFQuery<PFObject>!
        query = PFQuery(className: "StatusUpdate")
        
        // Get the status update object.
        query.getObjectInBackground(withId: statusObject.objectId!) { (object, error) -> Void in
            
            // Check for errors before saving the like/dislike.
            
            if ((error == nil) && (object != nil)) {
                
                if (rsvpPost == true) {
                    
                    // Add the user to the post rsvp array.
                    object?.addUniqueObject(PFUser.current()!.objectId!, forKey: "rsvpArray")
                } else {
                    // Remove the user from the post likes array.
                    object?.remove(PFUser.current()!.objectId!, forKey: "rsvpArray")
                }
                
                // Save the like/dislike data.
                object?.saveInBackground(block: { (success, rsvpError) -> Void in
                    
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
        
        if (self.passedInObject != nil) {
            
            let likesData:[String] = self.passedInObject.object(forKey: "likesarray") as! Array
            self.highlightLikedButton(likesData)
            self.updateLikeCount(likesData)
        }
    }
    
    func getRsvpData() {
        
        if (self.passedInObject != nil) {
            
            if self.passedInObject.object(forKey: "rsvpArray") != nil {
                self.rsvpArray = self.passedInObject.object(forKey: "rsvpArray") as! Array
            }
            self.updateRsvpLabel(self.passedInObject)
        }
    }
    
    // Profile view image button
    
    @IBAction func openProfileTapped(_ sender: AnyObject) {
        self.goToProfile()
    }
    
    // Main news item image method
    
    @IBAction func feedImageTapped(_ sender: AnyObject) {
        PresentingViews.showPhotoViewer(self, userPostedImage: userPostedImage, userProfilePic: self.profileimageview.image!, userName: self.UserNameLabel.text!, statusObject: self.passedInObject)
    }
    
    // like button container button action method
    
    @IBAction func Likebuttoncontaineraction(_ sender: AnyObject) {
        self.likeClicked()
    }
    
    // Attendants button container: button action method
    
    @IBAction func AttendantsListContainerInteraction(_ sender: AnyObject) {
        PresentingViews.ViewAttendantsListView(parentViewController, eventID: self.passedInObject.objectId!)
    }
    
    // RSVP button container: button action method
    
    @IBAction func RSVPbuttontapped(_ sender: AnyObject) {
        self.rsvpClicked()
    }
    
    // Comment button container: button action method
    
    @IBAction func CommentButtonTapped(_ sender: AnyObject) {
        self.commentClicked(sender as! UIButton)
    }
}
