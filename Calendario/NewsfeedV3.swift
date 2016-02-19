//
//  NewsfeedV3.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 16/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore
import DOFavoriteButton

class NewsfeedV3: UITableViewController {
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var followingData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    // Setup the on screen button actions.
    
    @IBAction func postStatus(sender: UIButton) {
        
        // Open the status post view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewControllerWithIdentifier("PostView") as! StatusUpdateViewController
        self.presentViewController(postsview, animated: true, completion: nil)
    }
    
    // View Did Load.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load in the recommended view controller state.
        let defaults = NSUserDefaults.standardUserDefaults()
        let showRecommendations = defaults.objectForKey("recoCheck") as? Bool
        
        // If the state is set to 'true' then the
        // user is new and we must show the recommended
        // view controller to help the user follow people.
        
        if (showRecommendations == true) {
            
            // Open the user recommendations view.
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let postsview = sb.instantiateViewControllerWithIdentifier("recommend") as! RecommendedUsersViewController
            self.presentViewController(postsview, animated: true, completion:{
                
                // Make sure the view does not appear every time.
                defaults.setObject(false, forKey: "recoCheck")
                defaults.synchronize()
            })
        }
        
        // Link the pull to refresh to the refresh method.
        menuIndicator.addTarget(self, action: "reloadNewsFeed", forControlEvents: .ValueChanged)
        self.menuIndicator.beginRefreshing()
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Allow tableview cell resizing based on content.
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 254.0;
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Logo for navigation title.
        let logo = UIImage(named: "newsFeedTitle")
        let imageview = UIImageView(image: logo)
        imageview.contentMode = .ScaleAspectFit

        
        // Set the "Calendario" image in the navigation bar.
        self.navigationItem.titleView = imageview
        self.navigationItem.titleView?.contentMode = UIViewContentMode.Center
        self.navigationItem.titleView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.navigationItem.titleView?.backgroundColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
   
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false

        // Load in the news feed data.
        self.reloadNewsFeed()
    }
    
    // Data loading methods.
    
    func reloadNewsFeed() {
        
        self.menuIndicator.beginRefreshing()
        
        // Clear the status data array.
        
        if (self.statusData.count > 0) {
            self.statusData.removeAllObjects()
        }
        
        // Download the user following data.
        ManageUser.getUserFollowingList(PFUser.currentUser()!) { (userFollowing) -> Void in
            
            dispatch_async(dispatch_get_main_queue(),{
                
                if (userFollowing.count > 0) {
                    
                    self.followingData = userFollowing
                    self.loadNewsFeedData(0)
                }
                    
                else {
                    
                    // Show the no posts error message.
                    self.menuIndicator.endRefreshing()
                    self.displayAlert("No posts", alertMessage: "You are not folowing anyone.")
                }
            })
        }
    }
    
    func loadNewsFeedData(currentPos: Int) {
        
        // Setup the status update query.
        var query:PFQuery!
        query = PFQuery(className:"StatusUpdate")
        query.limit = 100
        query.whereKey("user", equalTo: self.followingData[currentPos] as! PFUser)
        
        // Get the status update(s).
        query.findObjectsInBackgroundWithBlock({ (statusUpdates, error) -> Void in
            
            if ((error == nil) && (statusUpdates?.count > 0)) {
                
                for (var loop = 0; loop < statusUpdates!.count; loop++) {
                    self.statusData.addObject(statusUpdates![loop])
                }
            }
            
            if ((currentPos + 1) < self.followingData.count) {
                self.loadNewsFeedData(currentPos + 1)
            }
                
            else {
                self.organizeNewsFeedData()
            }
        })
    }
    
    func organizeNewsFeedData() {
        
        // Only sort the data if there are
        // any status updates for the user.
        
        if (self.statusData.count > 0) {
            
            // Sort the status updates by the 'createdAt' date.
            let newData:NSArray = (self.statusData.copy() as! NSArray).sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in
                return ((obj2 as! PFObject).createdAt?.compare((obj1 as! PFObject).createdAt!))!
            }
            
            // Save the sorted data to the mutable array.
            sortedArray = NSMutableArray(array: newData)
            
            // Stop the loading indicator.
            self.menuIndicator.endRefreshing()
            
            // Reload the table view.
            self.tableView.reloadData()
        }
        
        else {
            
            // Show the no posts error message.
            self.menuIndicator.endRefreshing()
            self.displayAlert("No posts", alertMessage: "An error has occurred, the newsfeed posts have not been loaded. Make sure you are following at least one person to view posts on the news feed.")
        }
    }
    
    // UITableView methods.
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject
        
        // Setup the user details query.
        var findUser:PFQuery!
        findUser = PFUser.query()!
        findUser.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
        
        // Download the user detials.
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                let userObject = (aobject as NSArray).lastObject as? PFUser
                
                // Set the user name label.
                cell.UserNameLabel.text = userObject?.username

                // Check the profile image data first.
                var profileImage = UIImage(named: "default_profile_pic.png")
                
                // Setup the user profile image file.
                let userImageFile = userObject!["profileImage"] as! PFFile
                
                // Download the profile image.
                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    
                    if ((error == nil) && (imageData != nil)) {
                        profileImage = UIImage(data: imageData!)
                    }
                    
                    cell.profileimageview.image = profileImage
                }
            }
        }
        
        // Set the various label/button tag attributes
        // this will be needed to perform tasks such as:
        // like post, comment on post, view likes, etc...
        cell.profileimageview.tag = indexPath.row
        cell.likebutton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.likeslabel.tag = indexPath.row
        cell.commentsLabel.tag = indexPath.row
        
        // Setup the tag gesture recognizers, so we can open
        // the various different views, ie: comments view.
        let tapGesturePostImage = UITapGestureRecognizer(target: self, action: "imageTapped:")
        let tapGestureProfileImage = UITapGestureRecognizer(target: self, action: "goToProfile:")
        let tapGestureLikesLabel = UITapGestureRecognizer(target: self, action: "goToLikesList:")
        let tapGestureCommentLabel = UITapGestureRecognizer(target: self, action: "commentsLabelClicked:")
        cell.userPostedImage.addGestureRecognizer(tapGesturePostImage)
        cell.profileimageview.addGestureRecognizer(tapGestureProfileImage)
        cell.likeslabel.addGestureRecognizer(tapGestureLikesLabel)
        cell.commentsLabel.addGestureRecognizer(tapGestureCommentLabel)
        
        // Link the comment button to the comment method.
        cell.commentButton.addTarget(self, action: "commentClicked:", forControlEvents: .TouchUpInside)
        
        // Set the status labels.
        cell.statusTextView.text = currentObject["updatetext"] as? String
        cell.uploaddatelabel.text = currentObject["dateofevent"] as? String
        
        // If the status contains hashtags then highlight them.
        
        if ((cell.statusTextView.text?.hasPrefix("#")) != nil) {
            
            // Highlight the status hashtags.
            cell.statusTextView.hashtagLinkTapHandler = {label, hashtag, range in}
        }
        
        // Create the tense/date all in one attributed string.
        let attrs2 = [NSForegroundColorAttributeName:UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
        let tensestring2 = NSMutableAttributedString(string: currentObject.objectForKey("tense") as! String, attributes: attrs2)
        let spacestring2 = NSMutableAttributedString(string: " ")
        let onstring = NSAttributedString(string: "on")
        let spacestr3 = NSAttributedString(string: " ")
        tensestring2.appendAttributedString(spacestring2)
        tensestring2.appendAttributedString(onstring)
        tensestring2.appendAttributedString(spacestr3)
        let dateattrstring = NSAttributedString(string: currentObject.objectForKey("dateofevent") as! String, attributes: attrs2)
        tensestring2.appendAttributedString(dateattrstring)
        
        // Set the date/tense all in one label.
        cell.uploaddatelabel.attributedText = tensestring2
        
        // Set location label and checking contents.
        let locationValue: String = currentObject.objectForKey("location") as! String
        
        if locationValue == "tap to select location..." {
            cell.locationLabel.text = ""
        }
            
        else {
            cell.locationLabel.text = locationValue
        }
        
        // Turn the profile picture into a circle.
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        // Show or hide the media image view
        // depending on the cell data type.
        cell.userPostedImage.clipsToBounds = true
        
        if (currentObject.objectForKey("image") == nil) {
            cell.userPostedImage.alpha = 0.0
            cell.imageViewHeightConstraint.constant = 1
            cell.updateConstraintsIfNeeded()
        }
            
        else {
            
            // Show the edia image view.
            cell.userPostedImage.alpha = 1.0
            cell.imageViewHeightConstraint.constant = 127
            cell.updateConstraintsIfNeeded()
            
            // Setup the user profile image file.
            let statusImage = currentObject["image"] as! PFFile
            
            // Download the profile image.
            statusImage.getDataInBackgroundWithBlock { (mediaData: NSData?, error: NSError?) -> Void in
                
                if ((error == nil) && (mediaData != nil)) {
                    cell.userPostedImage.image = UIImage(data: mediaData!)
                }
                
                else {
                    cell.userPostedImage.image = UIImage(imageLiteral: "no-image-icon + Rectangle 4")
                }
            }
        }
        
        // Setup the cell likes button.
        cell.likebutton.translatesAutoresizingMaskIntoConstraints = true
        cell.likebutton.clipsToBounds = false
        cell.likebutton.addTarget(self, action: "likeClicked:", forControlEvents: .TouchUpInside)
        
        // Get the post likes data.
        let likesArray:[String] = currentObject.objectForKey("likesarray") as! Array
        
        // Highlight the like button if the
        // logged in user has liked the post.
        
        if (likesArray.count > 0) {
            
            // Update the status likes label.
            
            if (likesArray.count == 1) {
                cell.likeslabel.text = "1 Like"
            }
            
            else {
                cell.likeslabel.text = "\(likesArray.count) Likes"
            }
            
            // Update the like button.
            
            if likesArray.contains(PFUser.currentUser()!.objectId!) {
                cell.likebutton.select()
            }
        }
        
        else {
            cell.likeslabel.text = "0 Likes"
        }
        
        // Update the comments label.
        var commentsquery:PFQuery!
        commentsquery = PFQuery(className: "comment")
        commentsquery.orderByDescending("createdAt")
        commentsquery.addDescendingOrder("updatedAt")
        commentsquery.whereKey("statusOBJID", equalTo: currentObject.objectId!)
        commentsquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if (error == nil) {
                
                if (objects!.count == 1) {
                    cell.commentsLabel.text = "1 Comment"
                }
                
                else {
                    cell.commentsLabel.text = "\(String(objects!.count) ) Comments"
                }
            }
            
            else {
                cell.commentsLabel.text = "0 Comments"
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject

        // Setup the report status button.
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(statusupdate.objectId, forKey: "reported")
            
            self.ReportView()
            
            var reportquery:PFQuery!
            reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.objectForKey("updatetext")!)
            reportquery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        
                        var reportedID:String!
                        
                        for object in objects {
                            reportedID = object.objectId
                        }
                        
                        var reportstatus:PFQuery!
                        reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackgroundWithId(reportedID, block: { (status:PFObject?, error:NSError?) -> Void in
                            
                            if (error == nil) {
                                
                                status!["reported"] = true
                                status?.saveInBackground()
                            }
                        })
                    }
                }
            })
        }
        
        // Setup the see more button.
        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let updatetext = statusupdate.objectForKey("updatetext") as! String
            let currentobjectID = statusupdate.objectId
            
            defaults.setObject(updatetext, forKey: "updatetext")
            defaults.setObject(currentobjectID, forKey: "objectId")
            
            self.Seemore()
        }
        
        // Setup the delete status button.
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            var query:PFQuery!
            query = PFQuery(className: "StatusUpdate")
            query.includeKey("user")
            query.whereKey("objectId", equalTo: statusupdate.objectId!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                
                if (error == nil) {
                    
                    for object in objects! {
                        
                        let userstr = object["user"]?.username!
                        
                        if (userstr == PFUser.currentUser()?.username) {
                            
                            statusupdate.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                
                                if (success) {
                                    
                                    // Remove the status update from the array.
                                    self.sortedArray.removeObjectAtIndex(indexPath.row)
                                    
                                    // Remove the cell from the table view.
                                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                                }
                            })
                        }
                            
                        else {
                            
                            let alert = UIAlertController(title: "Error", message: "You can only delete your own posts.", preferredStyle: .Alert)
                            alert.view.tintColor = UIColor.flatGreenColor()
                            let next = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                            alert.addAction(next)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        }
        
        // Set the button backgrond colours.
        seemore.backgroundColor = UIColor.flatGrayColor()
        report.backgroundColor = UIColor.blackColor()
        deletestatus.backgroundColor = UIColor.redColor()
        
        // Only show the delete button if the status
        // belongs to the currently logged in user.
        
        if ((statusupdate.objectForKey("user") as! PFUser!).objectId! == PFUser.currentUser()?.objectId!) {
            
            // For V1.0 we will not be adding access to
            // the "See More" section as it is not needed.
            // return [report, seemore, deletestatus]
            return [report, deletestatus]
        }
            
        else {
            return [report]
        }
    }
    
    // Alert methods.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Other methods.
    
    func commentClicked(sender: UIButton) {
        
        // Get the status array index.
        let index = sender.tag
        
        // Open the comments view.
        self.openComments((self.sortedArray.objectAtIndex(index) as! PFObject).objectId!)
    }
    
    func commentsLabelClicked(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject
        
        // Open the comments view.
        self.openComments(currentObject.objectId!)
    }
    
    func openComments(commentsID: String) {
        
        // Open the comments view for the selected post.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let commentvc = sb.instantiateViewControllerWithIdentifier("comments") as! CommentsViewController
        commentvc.savedobjectID = commentsID
        let NC = UINavigationController(rootViewController: commentvc)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
    
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! NewsfeedTableViewCell
        
        // Set the image to be shown in the photo view.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(UIImagePNGRepresentation(cell.userPostedImage.image!), forKey: "image")
        
        // Open the photo view controller.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("photoviewer") as! CalPhotoViewerViewController
        let NC = UINavigationController(rootViewController: PVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func likeClicked(sender: DOFavoriteButton) {
        
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.tag), inSection: 0)
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject
        
        // Get the post likes data.
        let likesArray:[String] = currentObject.objectForKey("likesarray") as! Array
        
        // Check if the logged in user has
        // already like the selected status.
        
        if (likesArray.count > 0) {
            
            if likesArray.contains(PFUser.currentUser()!.objectId!) {
                
                // The user has already liked the status
                // so lets dislike the status update.
                self.saveLikeForPost(currentObject, likePost: false, likeButton: sender)
            }
            
            else {
                
                // The user has not liked the status
                // so lets go ahead and like it.
                self.saveLikeForPost(currentObject, likePost: true, likeButton: sender)
            }
        }
        
        else {
            
            // This status has zero likes so the logged
            // in user hasn't liked the post either so we
            // can go ahead and save the like for the user.
            self.saveLikeForPost(currentObject, likePost: true, likeButton: sender)
        }
    }
    
    func saveLikeForPost(statusObject: PFObject, likePost: Bool, likeButton: DOFavoriteButton) {
        
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
                        self.sortedArray.replaceObjectAtIndex(likeButton.tag, withObject: object!)
                        
                        // Get access to the cell.
                        let indexPath = NSIndexPath(forRow: (likeButton.tag), inSection: 0)
                        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! NewsfeedTableViewCell
                        
                        // Get the post likes data.
                        let likesArray:[String] = object!.objectForKey("likesarray") as! Array
                        
                        // Update the likes label.
                        
                        if (likesArray.count > 0) {
                            
                            // Update the status likes label.
                            
                            if (likesArray.count == 1) {
                                cell.likeslabel.text = "1 Like"
                            }
                                
                            else {
                                cell.likeslabel.text = "\(likesArray.count) Likes"
                            }
                        }
                            
                        else {
                            cell.likeslabel.text = "0 Likes"
                        }
                        
                        // Update the like button.
                        
                        if (likePost == true) {
                            
                            likeButton.select()
                            
                            // Submit and save the like notification.
                            let likeString = "\(PFUser.currentUser()!.username!) has liked your post"
                            self.SavingNotifacations(likeString, objectID: statusObject.objectId!, notificationType:"like")
                        }
                        
                        else {
                            likeButton.deselect()
                        }
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
    
    func goToProfile(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject
        
        // Setup the user query.
        var userQuery:PFQuery!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: (currentObject.objectForKey("user")?.objectId)!)
        
        // Download the user object.
        userQuery.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            if let aobject = objects {
                
                // Open the selected users profile.
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
                reportVC.passedUser = (aobject as NSArray).lastObject as? PFUser
                self.presentViewController(reportVC, animated: true, completion: nil)
            }
        }
    }
    
    func goToLikesList(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.sortedArray.objectAtIndex(indexPath.row) as! PFObject
        
        // Save the status object ID.
        var defaults:NSUserDefaults!
        defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(currentObject.objectId!, forKey: "likesListID")
        defaults.synchronize()

        // Open the likes list view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("likesNav") as! UINavigationController
        self.presentViewController(likesView, animated: true, completion: nil)
    }
    
    func ReportView() {
        
        // Open the report view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func Seemore() {
        
        // Open the see more view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
        let NC = UINavigationController(rootViewController: SMVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}
