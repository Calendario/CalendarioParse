//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import UIKit
import Parse
import QuartzCore
import DOFavoriteButton

class TimelineViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    // Final correct data to be used for the timeline.
    var filteredData:NSMutableArray = NSMutableArray()
    //////
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableview: UITableView!
    
    var currentObjectid:String!
    
     let likebuttonfilled = UIImage(named: "like button filled")
    
    var dateofevent:String!
    
    var b:Bool = false
    var eventsarray = [NSDate]()
    
    var selectedDate:NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Allow tableview cell resizing based on content.
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.estimatedRowHeight = 292.0;
        self.tableview.separatorInset = UIEdgeInsetsZero
        
        calendar.scrollDirection = .Horizontal
        calendar.selectDate(NSDate())
        calendar.appearance.eventColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let currentDate = dateformatter.stringFromDate(NSDate())
        
        // Load the calendar data for today.
        self.loadCalendarData(currentDate)
        
        /*self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
        let navigationbar = UINavigationBar(frame:  CGRectMake(0, 0, self.view.frame.size.width, 55))
        navigationbar.backgroundColor = UIColor.whiteColor()
        navigationbar.delegate = self
        navigationbar.barTintColor =  UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        navigationbar.tintColor = UIColor.whiteColor()
        
        // logo for nav title
        
        let logo = UIImage(named: "navtext")
        let imageview = UIImageView(image: logo)
        
        let navitems = UINavigationItem()
        navitems.title = "Timeline"
        // set nav items in nav bar
        navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)*/
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        
        selectedDate = date
        eventsarray.append(date)
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let newdate_V1 = dateformatter.stringFromDate(date)
        
        // Load the calendar data.
        self.loadCalendarData(newdate_V1)
    }
    
    func loadCalendarData(selectedData: String) {
        
        var getdates:PFQuery = PFQuery(className: "StatusUpdate")
        getdates.whereKey("dateofevent", equalTo: selectedData)
        getdates.includeKey("user")
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(selectedData, forKey: "dateofevent")
        
        var postsdata:NSMutableArray = NSMutableArray()
        
        getdates.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            
            if error == nil {
                
                print(objects)
                
                // print(objects!.count)
                for object in objects! {
                    
                    let statusupdate:PFObject = object
                    postsdata.addObject(statusupdate)
                    self.b = true
                }
                
                let array:NSArray = postsdata.reverseObjectEnumerator().allObjects
                postsdata = NSMutableArray(array: array)
                
                print(postsdata)
                
                // Reset the filtered data array.
                self.filteredData.removeAllObjects()
                
                // Get the list of accounts the user is following.
                ManageUser.getUserFollowingList(PFUser.currentUser()!, completion: { (userFollowing) -> Void in
                    
                    // We need to filter the post data so that we only
                    // see the status updates of people we are folowing.
                    
                    for (var loop = 0; loop < postsdata.count; loop++) {
                        
                        // Get the current user from the
                        // downloaded status update data.
                        let loopUser:PFUser = postsdata[loop].valueForKey("user") as! PFUser
                        
                        // Loop through the following array and check if the user
                        // from the postsdata array is being followed or not.
                        
                        for (var loopTwo = 0; loopTwo < userFollowing.count; loopTwo++) {
                            
                            // Get the current user from the following array.
                            let followingUser:PFUser = userFollowing[loopTwo] as! PFUser
                            
                            // If the user matches add the data
                            // to the filtered data array.
                            
                            if (loopUser.objectId! == followingUser.objectId!) {
                                self.filteredData.addObject(postsdata[loop])
                            }
                        }
                    }
                    
                    print(self.filteredData)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        // Now reload the table view.
                        self.tableview.reloadData()
                    })
                })
            }
            
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func getImageData(objects:[PFObject], imageView:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackgroundWithBlock({ (imagedata, error) -> Void in
                    if error == nil
                    {
                        let image = UIImage(data: imagedata!)
                        imageView.image = image
                    }
                    else
                    {
                        imageView.image = UIImage(named: "profile_icon")
                    }
                })
            }
        }
    }
    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        var bool = false
        
        if calendar.selectedDate == date
        {
            bool = true
        }
        return bool
    }
    
    // Table view methods.
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
                                    self.filteredData.removeObjectAtIndex(indexPath.row)
                                    
                                    // Remove the cell from the table view.
                                    self.tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
        seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)

        report.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)

        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)

        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TimeLineTableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
        cell.userPostedImage.tag = indexPath.row
        
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
            cell.statusTextView.hashtagLinkTapHandler = {label, hashtag, range in
                
                // Save the hashtag string.
                var defaults:NSUserDefaults!
                defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(([1, hashtag]) as NSMutableArray, forKey: "HashtagData")
                defaults.synchronize()
                
                // Open the hashtag view with status
                // posts containing the selected #hashtag.
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let likesView = sb.instantiateViewControllerWithIdentifier("HashtagNav") as! UINavigationController
                self.presentViewController(likesView, animated: true, completion: nil)
            }
        }
        
        // If the status contains @mentions then highligh
        // and link them to the open profile view action.
        
        if ((cell.statusTextView.text?.hasPrefix("@")) != nil) {
            
            // Highlight the @username label.
            cell.statusTextView.userHandleLinkTapHandler = {label2, mention, range in
                
                // Remove the '@' symbol from the username
                let userMention = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                
                // Setup the user query.
                var query:PFQuery!
                query = PFUser.query()
                query.whereKey("username", equalTo: userMention)
                
                // Get the user data object.
                query.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                    
                    // Check for errors before passing
                    // the user object to the profile view.
                    
                    if ((error == nil) && (userObject != nil)) {
                        
                        // Open the selected users profile.
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
                        reportVC.passedUser = userObject as? PFUser
                        self.presentViewController(reportVC, animated: true, completion: nil)
                    }
                })
            }
        }
        
        // Create the tense/date all in one attributed string.
        let attrs2 = [NSForegroundColorAttributeName:UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
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
        
        //set radius of imageview on status
        cell.userPostedImage.layer.cornerRadius = 4.0
        cell.userPostedImage.clipsToBounds = true
        
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
                
            else {
                cell.likebutton.deselect()
            }
        }
            
        else {
            cell.likeslabel.text = "0 Likes"
        }
        
        // Set the createdAt date label.
        DateManager.createDateDifferenceString(currentObject.createdAt!) { (difference) -> Void in
            cell.createdAtLabel.text = difference
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
        
        // Set cell strip color.
        
        if indexPath.row % 2 == 0 {
            cell.colorStrip.backgroundColor = UIColor(red: 30/255.0, green: 206/255.0, blue: 241/255.0, alpha: 1.0)
        }
            
        else {
            cell.colorStrip.backgroundColor = UIColor(red: 25/255.0, green: 181/255.0, blue: 215/255.0, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // We dont want to show the see more section in V1.0
        // let status:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        // GotoPost(status.objectId!)
    }
    
    // Other methods.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "timelineComments" {
            //let vc = segue.destinationViewController as! CommentsViewController
            //vc.savedobjectID = currentObjectid
        }
    }
    
    func commentClicked(sender: UIButton) {
        
        // Get the status array index.
        let index = sender.tag
        
        // Open the comments view.
        self.openComments((self.filteredData.objectAtIndex(index) as! PFObject).objectId!)
    }
    
    func commentsLabelClicked(sender: UITapGestureRecognizer) {
        
        // Get the specific status object for this cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let currentObject:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
        let cell = self.tableview.cellForRowAtIndexPath(indexPath) as! TimeLineTableViewCell
        
        // Open the photo view controller.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("PhotoV2") as! PhotoViewV2
        PVC.passedImage = cell.userPostedImage.image!
        let NC = UINavigationController(rootViewController: PVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func likeClicked(sender: DOFavoriteButton) {
        
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.tag), inSection: 0)
        
        // Get the specific status object for this cell.
        let currentObject:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
                        self.filteredData.replaceObjectAtIndex(likeButton.tag, withObject: object!)
                        
                        // Get access to the cell.
                        let indexPath = NSIndexPath(forRow: (likeButton.tag), inSection: 0)
                        let cell = self.tableview.cellForRowAtIndexPath(indexPath) as! TimeLineTableViewCell
                        
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
        let currentObject:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
        let currentObject:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
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
}
