//
//  NewsFeedQueryViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 1/23/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import SDWebImage
import DOFavoriteButton
class NewsFeedQueryViewController: PFQueryTableViewController {
    
    
    var query: PFQuery!
    var reportedID:String!
    var currentobjectID:String!
    var likesarray:[String] = [""]
    var likesmaster: NSMutableArray!
    var guser:PFUser!
    var username:String!
    var Follower:[String]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Automatically show the recommended users
        // view if the user has just registered.
        let defaults = NSUserDefaults.standardUserDefaults()
        let showRecommendations = defaults.objectForKey("recoCheck") as? Bool
        
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
    }
    
    


    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //set view properties
        //method to allow tableview cell resizing based on content
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 254.0;
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Logo for nav title.
        let logo = UIImage(named: "newsFeedTitle")
        let imageview = UIImageView(image: logo)
        
        // Set the "Calendario" image int he navigation bar.
        self.navigationItem.titleView = imageview
        self.navigationItem.titleView?.contentMode = UIViewContentMode.Center
        self.navigationItem.titleView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        
        
    }
    
    
   


    
    
    
    
    

    
    override func queryForTable() -> PFQuery {
        
        
        query = PFQuery(className: "StatusUpdate")
        query.orderByDescending("createdAt")
        
        
        ManageUser.getUserFollowingList(PFUser.currentUser()!) { (userFollowing) -> Void in
            
            
            
            
            for user in userFollowing
            {
                let test = user as! PFUser
                
                
                
                self.query.whereKey("user", equalTo: test.username!)
                
                
                
                
            }
        }
        return query
    }
    
   
    
    
    
    
    
        
    
  
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        print(object?.valueForKey("likedby") as? String)
        
        
        var likedpost = object?.valueForKey("likedby") as? String
        
        if likedpost == PFUser.currentUser()?.objectId
        {
            cell.likebutton.select()
        }
        
        currentobjectID = object?.objectId
        let defaults = NSUserDefaults.standardUserDefaults().setObject(object?.objectId, forKey: "commentid")
        
        
        // date passed method
        isDatePassed((object?.createdAt!)!, date2: NSDate(), ParseID: (object?.objectId!)!)
        
        
        
        // hashtags
        if ((cell.statusTextView.text?.hasPrefix("#")) != nil)
        {
            cell.statusTextView.text = cell.statusTextView.text
            cell.statusTextView.hashtagLinkTapHandler = {label,hashtag,range in
                print(hashtag)
            }
        }
        
        if ((cell.statusTextView.text?.hasPrefix("@")) != nil)
        {
            cell.statusTextView.userInteractionEnabled = true
            cell.statusTextView.text = cell.statusTextView.text
            cell.statusTextView.userHandleLinkTapHandler = {label2,mention,range in
                print(mention)
                var userquery = PFUser.query()
                let editedtext = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                print(editedtext)
                userquery?.whereKey("username", equalTo: editedtext)
                userquery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error == nil
                    {
                        print(objects?.count)
                        if let objects = objects
                        {
                            for object in objects
                            {
                                var userid = object.objectId
                                var query2 = PFUser.query()
                                query2?.getObjectInBackgroundWithId(userid!, block: { (object, error) -> Void in
                                    var user:PFUser = object as! PFUser
                                    print(user)
                                    self.GotoProfile(user)
                                })
                            }
                        }
                    }
                })
            }
        }
        
        
        
        
        // getting updates
        let attrs = [NSForegroundColorAttributeName:UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
        // tense
        let tensestring = NSMutableAttributedString(string: object?.objectForKey("tense") as! String, attributes: attrs)
        let spacestring = NSMutableAttributedString(string: " ")
        // the update
        let updatestring = NSMutableAttributedString(string: object?.objectForKey("updatetext") as! String, attributes: [NSFontAttributeName: UIFont(name: "Futura", size: 14.0)!])
        tensestring.appendAttributedString(spacestring)
        tensestring.appendAttributedString(updatestring)
        
        cell.statusTextView.attributedText = tensestring
        cell.statusTextView.sizeToFit()
        
        
        
        
        
        
        // function that is called when comments button is tapped
        
        
        
        // profile images
        var getprofileimages = PFUser.query()
        getprofileimages?.whereKey("objectId", equalTo: (object?.objectForKey("user")?.objectId)!)
        getprofileimages?.findObjectsInBackgroundWithBlock({ (images, error) -> Void in
            if error == nil
            {
                self.getImageData(images!, imageview: cell.profileimageview)
                
                // make profile images circles
                cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
                cell.profileimageview.clipsToBounds = true
                
            }
            else
            {
                print("error")
            }
        })
        
        
        // image from posts
        let imagefile = object?.objectForKey("image") as? PFFile
        if imagefile == nil {
            cell.userPostedImage.image = UIImage(named: "defaultPhotoPost")
            cell.userPostedImage.contentMode = UIViewContentMode.ScaleAspectFit
        }
        else {
            
            imagefile?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data: imageData)
                        
                        cell.setPostedImage(image!)
                        cell.userPostedImage.layer.cornerRadius = 8.0
                        cell.userPostedImage.clipsToBounds = true
                        
                        // Allow user interaction.
                        cell.userPostedImage.userInteractionEnabled = true
                        
                        // Set the image tag needed for image loading.
                        cell.userPostedImage.tag = indexPath.row
                        
                        // Add the image viewer method to the image tap.
                        let tapgesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
                        cell.userPostedImage.addGestureRecognizer(tapgesture)
                    }
                }
            })
        }
        
        // location label
        cell.locationLabel.text = object?.valueForKey("location") as! String
        if cell.locationLabel.text == "tap to select location..."
        {
            cell.locationLabel.text = "No Location"
        }
        else
        {
            cell.locationLabel.hidden = false
        }
        
        
        
        // date label
        cell.uploaddatelabel.text = (object?.valueForKey("dateofevent") as! String)
        
        // likes label
        let likesamount = object?.valueForKey("likes") as? Int
        
        if likesamount == nil
        {
            cell.likeslabel.text = "0 likes"
        }
        else
        {
            cell.likeslabel.text = "\(likesamount!) Likes"
        }
        
        // comments label
        
        let commentquery = PFQuery(className: "comment")
        commentquery.whereKey("statusOBJID", equalTo: object!.objectId!)
        commentquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                let commentnum = objects?.count
                
                cell.commentsLabel.text = String("\(commentnum!) comments")
            }
        }
        
        
        // like button
        cell.likebutton.translatesAutoresizingMaskIntoConstraints = true
        cell.likebutton.clipsToBounds = false
        cell.likebutton.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        cell.likebutton.tag = indexPath.row
        cell.likebutton.addTarget(self, action: "likeclicked:", forControlEvents: .TouchUpInside)
        
        // comment button
        
        // set tthe tag to the current index path
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: "Commentclicked:", forControlEvents: .TouchUpInside)
        
        // getting usernames
        let findUser:PFQuery = PFUser.query()!
        
        findUser.whereKey("objectId", equalTo: (object?.objectForKey("user")?.objectId)!)
        
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        print(object.valueForKey("username") as! String)
                        
                        cell.UserNameLabel.text = (object.valueForKey("username") as! String)
                    }
                }
            }
        }
        
        return cell
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        
        // Get the image from the custom cell.
        let indexPath = NSIndexPath(forRow: (sender.view?.tag)!, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewsfeedTableViewCell
        
        // Set the image to be shown in the photo view.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(UIImagePNGRepresentation(cell.userPostedImage.image!), forKey: "image")
        
        // Open the photo view controller.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("photoviewer") as! CalPhotoViewerViewController
        let NC = UINavigationController(rootViewController: PVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    func GotoProfile(username:PFUser)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        reportVC.passedUser = username
        self.presentViewController(reportVC, animated: true, completion: nil)
        
        
    }
    
    func Commentclicked(sender:UIButton)
    {
        var index = sender.tag
        print(index)
        
        // get current id
        var id = self.objects![index].objectId
        GotoComments(id!!)
        
        
    }
    
    
    
    
    func likeclicked(sender:DOFavoriteButton)
    {
        
        if sender.selected
        {
            print("unlike")
            var index = sender.tag
            var id = self.objects![index].objectId
            sender.imageColorOn = UIColor.flatOrangeColor()
            var query = PFQuery(className: "StatusUpdate")
            query.getObjectInBackgroundWithId(id!!, block: { (update, error) -> Void in
                if error == nil
                {
                    var currentlikes = update?.valueForKey("likes") as! Int
                    
                    
                    update!["likes"] = currentlikes - 1
                    update!["likedby"] = ""
                    update?.saveInBackground()
                    
                    self.currentobjectID = nil
                    self.loadObjects()
                }
            })
            
            sender.deselect()
        }
            
        else
        {
            var index = sender.tag
            var id = self.objects![index].objectId
            print("like")
            sender.select()
            print("the tag is \(sender.tag)")
            sender.imageColorOn = UIColor.flatRedColor()
            var query = PFQuery(className: "StatusUpdate")
            likesarray.append((PFUser.currentUser()?.objectId)!)
            print(likesarray)
            
            
            query.getObjectInBackgroundWithId(id!!, block: { (update, error) -> Void in
                if error == nil
                {
                    var currentlikes = update?.valueForKey("likes") as? Int
                    
                    if currentlikes == nil
                    {
                        currentlikes = 0
                    }
                    
                    update!["likes"] = currentlikes! + 1
                    update!["likedby"] = PFUser.currentUser()?.objectId
                    update?.saveInBackground()
                    
                    let string = "\(PFUser.currentUser()!.username!) has liked your post"
                    print(string)
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(id!!, forKey: "objectidliked")
                    
                    self.currentobjectID = nil
                    self.SavingNotifacations(string)
                    self.loadObjects()
                }
            })
        }
    }
    
    func GotoComments(ObjectID:String)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var commentvc = sb.instantiateViewControllerWithIdentifier("comments") as! CommentsViewController
        commentvc.savedobjectID = ObjectID
        let NC = UINavigationController(rootViewController: commentvc)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    
    func isDatePassed(date1:NSDate, date2:NSDate, ParseID: String)
    {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        var newdate = dateformatter.stringFromDate(date2)
        
        
        if date1.timeIntervalSince1970 < date2.timeIntervalSince1970
        {
            print("Date2 has passed")
            
            var query = PFQuery(className: "StatusUpdate")
            query.getObjectInBackgroundWithId(ParseID, block: { (updates:PFObject?, error:NSError?) -> Void in
                if error == nil
                {
                    var aobject:PFObject = updates!
                    
                    print(error)
                    
                    print(aobject.objectForKey("dateofevent") as! String)
                    print(newdate)
                    
                    if aobject.objectForKey("dateofevent") as! String == newdate
                    {
                        print("tense stays")
                        aobject["tense"] = "Currently"
                        aobject.saveInBackground()
                        
                        
                    }
                    
                    if aobject.objectForKey("dateofevent") as! String > newdate
                    {
                        print("going tense")
                        aobject["tense"] = "Going"
                        aobject.saveInBackground()
                    }
                        
                        
                    else
                    {
                        
                        print("tense is going to change")
                        aobject["tense"] = "went"
                        aobject.saveInBackground()
                        
                    }
                    
                }
            })
            
            
        }
    }
    
    
    func ReportView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
        
        
    }
    
    // side out menu
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // reporting statusupdates
        var report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            var statusupdate = self.objects![indexPath.row] as! PFObject
            print("report was tapped")
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(statusupdate.objectId, forKey: "reported")
            
            self.ReportView()
            
            
            var reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.objectForKey("updatetext")!)
            reportquery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    print("objects found")
                    
                    if let objects = objects as [PFObject]!
                    {
                        for object in objects
                        {
                            var objID = object.objectId
                            self.reportedID = objID
                        }
                        
                        
                        var reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackgroundWithId(self.reportedID, block: { (status:PFObject?, error:NSError?) -> Void in
                            if error == nil
                            {
                                status!["reported"] = true
                                print("reported")
                                status?.saveInBackground()
                            }
                        })
                    }
                }
            })
        }
        
        
        // deleting updates
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete", handler: { (action, indexpath) -> Void in
            var statusupdate = self.objects![indexPath.row] as! PFObject
            var query = PFQuery(className: "StatusUpdate")
            query.includeKey("user")
            query.whereKey("objectId", equalTo: statusupdate.objectId!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if error == nil
                {
                    print(objects?.count)
                    for object in objects!
                    {
                        print(object)
                        let userstr = object["user"]?.username!
                        print(userstr!)
                        
                        if userstr == PFUser.currentUser()?.username
                        {
                            statusupdate.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                if success
                                {
                                    self.loadObjects()
                                    self.tableView.reloadData()
                                    statusupdate.saveInBackground()
                                    print("deleted")
                                    
                                }
                            })
                        }
                            
                        else
                        {
                            print("user not the owner")
                            let alert = UIAlertController(title: "Sorry", message: "You can only delete your own posts.", preferredStyle: .Alert)
                            alert.view.tintColor = UIColor.flatGreenColor()
                            let next = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(next)
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            })
        })
        
        // Set the button background colours.
        report.backgroundColor = UIColor.blackColor()
        deletestatus.backgroundColor = UIColor.redColor()
        
        // Get the status object.
        let statusObject = self.objects![indexPath.row] as! PFObject
        
        // Only show the delete button if the
        // user is looking at one of their own posts.
        
        if (((statusObject["user"]).objectId) == PFUser.currentUser()?.objectId) {
            return [report, deletestatus]
        }
            
        else {
            return [report]
        }
    }
    
    func getImageData(objects:[PFObject], imageview:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackgroundWithBlock({ (ImageData, error) -> Void in
                    if error == nil
                    {
                        var imageurl = image.url
                        var manager: SDWebImageManager = SDWebImageManager.sharedManager()
                        manager.downloadWithURL(NSURL(string: imageurl!), options: SDWebImageOptions.ContinueInBackground, progress: { (sent, recived) -> Void in
                            print(recived)
                            }, completed: { (image, error, cache, finished) -> Void in
                                if (image != nil)
                                {
                                    imageview.image = image
                                }
                        })
                    }
                    else
                    {
                        imageview.image = UIImage(named: "profile_icon")
                    }
                })
            }
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    func SavingNotifacations(notifcation:String)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var likedpostid = defaults.objectForKey("objectidliked") as! String
        var query = PFQuery(className: "StatusUpdate")
        
        query.whereKey("objectId", equalTo: likedpostid)
        query.includeKey("user")
        query.getObjectInBackgroundWithId(likedpostid) { (object, error) -> Void in
            if error == nil
            {

                // Only save the notification if the user recieving
                // the notification is NOT the same as the logged in user.
                
                if (PFUser.currentUser()!.objectId! != (object?.objectForKey("user") as! PFUser).objectId!) {
                    
                    PFCloud.callFunctionInBackground("StatusUpdate", withParameters: ["message" : notifcation, "user" : "\(PFUser.currentUser()?.username!)"])
                    
                    ManageUser.saveUserNotification(notifcation, fromUser: PFUser.currentUser()!, toUser: object?.objectForKey("user") as! PFUser)
                }
            }
        }
    }
    
    @IBAction func plusTapped(sender: AnyObject) {
        GotoPostView()
    }
    
    func GotoPostView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewControllerWithIdentifier("PostView") as! StatusUpdateViewController
        self.presentViewController(postsview, animated: true, completion: nil)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}
