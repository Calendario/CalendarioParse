//
//  Newsfeed2TableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 2/3/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import SDWebImage
import DOFavoriteButton




class Newsfeed2TableViewController: UITableViewController, UINavigationBarDelegate {
    
    @IBOutlet weak var refreshcontrol: UIRefreshControl!
   
        var statusData:NSMutableArray = NSMutableArray()
       var currentobjectID:String!
      var reportedID:String!
    var likedstatus = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoadData()
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Automatically show the recommended users
        // view if the user has just registered.
        
        refreshcontrol.attributedTitle = NSAttributedString(string: "Refresh")
        refreshcontrol.addTarget(self, action: "LoadData", forControlEvents: .ValueChanged)
        
        
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
    
    
    
    func setRefreshIndicators(state: Bool) {
        
        if (state == true) {
            refreshcontrol.beginRefreshing()
        }
            
        else {
            refreshcontrol.endRefreshing()
        }
    }

    
    
    
    override func viewDidAppear(animated: Bool) {
        // this only calls the viewappearonce, so no reload happens after expanding images
        if self.isBeingPresented() || self.isMovingToParentViewController()
        {
             LoadData()
        }
        
        //LoadData()
        
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
        
       

        
        
    }
    
    func GotoPostView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewControllerWithIdentifier("PostView") as! StatusUpdateViewController
        self.presentViewController(postsview, animated: true, completion: nil)
    }
    

    
    
    
    func GotoProfile(username:PFUser)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        reportVC.passedUser = username
        self.presentViewController(reportVC, animated: true, completion: nil)
        
        
    }

    
    
    // this method loads all data from parse to the app
    func LoadData()
    {
         statusData.removeAllObjects()
        
        
        
        
        
        
        
        self.setRefreshIndicators(true)
        self.tableView.userInteractionEnabled = false
        
         
        // mange user call first
        ManageUser.getUserFollowingList(PFUser.currentUser()!) { (userFollowing) -> Void in
            for user in userFollowing
            {
                let test = user as! PFUser
                // create query 
                var username = test.username!
                var getposts:PFQuery = PFQuery(className: "StatusUpdate")
                getposts.orderByDescending("dateofevent")
               getposts.addDescendingOrder("createdAt")
                getposts.addDescendingOrder("updatedAt")
                                 
                
                
                getposts.includeKey("user")
                print(username)
                getposts.whereKey("user", equalTo: test)
                //start query 
                getposts.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    
                    if error == nil
                    {
                        for object in objects!
                        {
                            let statusupdate:PFObject = object as! PFObject
                                self.statusData.addObject(statusupdate)
                                self.setRefreshIndicators(false)
                            
                        }
                        
                        let array:NSArray = self.statusData.reverseObjectEnumerator().allObjects
                        self.statusData = NSMutableArray(array: array)
                        self.tableView.reloadData()
                        self.tableView.userInteractionEnabled = true
                    }
                  
                })
                
               
                
                
            }
        }
    }
   
    
    
    
    
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func plustapped(sender: AnyObject) {
        GotoPostView()
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.statusData.count
        //// 
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell

        // Configure the cell..
        
        let statusUpdate:PFObject = self.statusData.objectAtIndex(indexPath.row) as! PFObject
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        var newdate = dateformatter.dateFromString(statusUpdate.objectForKey("dateofevent") as! String)

        
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        
        cell.statusTextView.text = statusUpdate.objectForKey("updatetext") as! String
        
        // NSMutableAttributedString FOR USER STATUS
        
        /*let attrs = [NSForegroundColorAttributeName:UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
        let tensestring = NSMutableAttributedString(string: statusUpdate.objectForKey("tense") as! String, attributes: attrs)
        let spacestring = NSMutableAttributedString(string: " ")
        
        let attributedString = NSMutableAttributedString(string:statusUpdate.objectForKey("updatetext") as! String, attributes:[NSFontAttributeName : UIFont(name: "Futura", size: 14.0)!])
        
        tensestring.appendAttributedString(spacestring)
        tensestring.appendAttributedString(attributedString)
       */
        
        
        // checking for hashtags and mentions
        
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
            cell.statusTextView.text = cell.statusTextView.text
            cell.statusTextView.userHandleLinkTapHandler = {label,mention,range in
                var userquery = PFUser.query()
                let editedtext = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                print(editedtext)
                userquery?.whereKey("username", equalTo: editedtext)
                userquery?.includeKey("user")
                userquery?.orderByDescending("createdAt")
                userquery?.addDescendingOrder("updatedAt")
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
                                query2?.includeKey("user")
                                query2?.orderByDescending("createdAt")
                                query2!.addDescendingOrder("updatedAt")
                                

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
        
        
        //cell.statusTextView.attributedText = tensestring
        cell.statusTextView.sizeToFit()
        
        // cell profile image properties
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        // date label
        
        let attrs2 = [NSForegroundColorAttributeName:UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0), NSFontAttributeName : UIFont(name: "Futura-Medium", size: 14.0)!]
        let tensestring2 = NSMutableAttributedString(string: statusUpdate.objectForKey("tense") as! String, attributes: attrs2)
        let spacestring2 = NSMutableAttributedString(string: " ")
        let onstring = NSAttributedString(string: "on")
        let spacestr3 = NSAttributedString(string: " ")
        
        tensestring2.appendAttributedString(spacestring2)
        tensestring2.appendAttributedString(onstring)
        tensestring2.appendAttributedString(spacestr3)
        let dateattrstring = NSAttributedString(string: statusUpdate.objectForKey("dateofevent") as! String, attributes: attrs2)
        tensestring2.appendAttributedString(dateattrstring)
        
        cell.uploaddatelabel.attributedText = tensestring2
        
        var likedbyuser = statusUpdate.objectForKey("likedby") as? String
        let username = likedbyuser
        print(username)
        
        
        

        
        
        

        //cell.uploaddatelabel.text = statusUpdate.objectForKey("dateofevent") as! String
        // location label
        cell.locationLabel.text = statusUpdate.objectForKey("location") as! String
        
        if cell.locationLabel.text == "tap to select location..."
        {
            cell.locationLabel.text = ""
        }
        else
        {
            cell.locationLabel.hidden = false
        }

        
        // likes label
        var likesamount = statusUpdate.objectForKey("likes") as? Int
        
        if likesamount == nil
        {
            cell.likeslabel.text = "0 Likes"
        }
        else
        {
            cell.likeslabel.text = "\(likesamount!) Likes"
        }
        
        
        currentobjectID = statusUpdate.objectId
        
        
        
      var commentsquery = PFQuery(className: "comment")
        commentsquery.orderByDescending("createdAt")
        commentsquery.addDescendingOrder("updatedAt")
        commentsquery.whereKey("statusOBJID", equalTo: statusUpdate.objectId!)
        commentsquery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                print(objects!.count)
                cell.commentsLabel.text = "\(String(objects!.count) ) Comments"
            }
        }
        
        
        var findUser:PFQuery = PFUser.query()!
        findUser.orderByDescending("createdAt")
        findUser.addDescendingOrder("updatedAt")
        
        findUser.whereKey("objectId", equalTo: (statusUpdate.objectForKey("user")?.objectId)!)
        
        
        // user names label
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if let aobject = objects
            {
                let puser = (aobject as NSArray).lastObject as? PFUser
                cell.UserNameLabel.text = puser?.username
        
        
            }
        }
        
        //profile images
        var getImages:PFQuery = PFUser.query()!
        getImages.whereKey("objectId", equalTo: (statusUpdate.objectForKey("user")?.objectId)!)
        getImages.orderByDescending("createdAt")

        getImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                self.getImageData(objects!, imageview: cell.profileimageview)
            }
            else
            {
                print("error")
            }
        }
        
        
        // like button
        
        cell.likebutton.translatesAutoresizingMaskIntoConstraints = true
        cell.likebutton.clipsToBounds = false
        cell.likebutton.tag = indexPath.row
        cell.likebutton.addTarget(self, action: "likeclicked:", forControlEvents: .TouchUpInside)
        
        if PFUser.currentUser()!.username! == username
        {
            cell.likebutton.select()
        }

        
        
        
        // commennt button
        
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: "Commentclicked:", forControlEvents: .TouchUpInside)
        
        
        let QOS = QOS_CLASS_BACKGROUND
        let backgroundqueue = dispatch_get_global_queue(QOS, 0)
        dispatch_async(backgroundqueue, { () -> Void in
            // user image posts-THIS MIGHT NOT WORK
            
            
            let imagefile = statusUpdate.objectForKey("image") as? PFFile
            
            if imagefile == nil
            {
                cell.userPostedImage.image = UIImage(named: "defaultPhotoPost")
                cell.userPostedImage.contentMode = UIViewContentMode.ScaleAspectFit
                
                
                
            }
            
            imagefile?.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil
                {
                    if let ImageData = imageData
                    {
                        let image = UIImage(data: ImageData)
                        cell.setPostedImage(image!)
                        cell.userPostedImage.layer.cornerRadius = 0.0
                        cell.userPostedImage.clipsToBounds = true
                        cell.userPostedImage.tag = indexPath.row
                        cell.userPostedImage.userInteractionEnabled = true
                        let tapgesture = UITapGestureRecognizer(target: self, action: "imageTapped:")
                        cell.userPostedImage.addGestureRecognizer(tapgesture)
                        
                    }
                }
            })

            })
            
        
        isDatePassed(statusUpdate.createdAt!, date2: NSDate(), ParseID: statusUpdate.objectId!)
        
        
        
        
    

    
        

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

    
    func GotoComments(ObjectID:String)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var commentvc = sb.instantiateViewControllerWithIdentifier("comments") as! CommentsViewController
        commentvc.savedobjectID = ObjectID
        let NC = UINavigationController(rootViewController: commentvc)
        self.presentViewController(NC, animated: true, completion: nil)
    }

    
    func Commentclicked(sender:UIButton)
    {
        var index = sender.tag
        print(index)
        
        let statusupdate = self.statusData.objectAtIndex(index) as! PFObject
        GotoComments(statusupdate.objectId!)
    }
    
    func likeclicked(sender:DOFavoriteButton)
    {
        
        if sender.selected
        {
            print("unlike")
            var index = sender.tag
            var id = self.statusData[index].objectId
            sender.imageColorOn = UIColor.flatOrangeColor()
            var query = PFQuery(className: "StatusUpdate")
            query.orderByDescending("createdAt")
            query.addDescendingOrder("dateofevent")


            query.getObjectInBackgroundWithId(id!!, block: { (update, error) -> Void in
                if error == nil
                {
                    update?.incrementKey("likes", byAmount: -1)
                    update!["likedby"] = ""
                    update?.saveInBackground()
                    
                    
                    
                    self.currentobjectID = nil
                    //self.LoadData()
                    
                    let QOS = QOS_CLASS_BACKGROUND
                    let backgroundqueue = dispatch_get_global_queue(QOS, 0)
                    dispatch_async(backgroundqueue, { () -> Void in
                       self.LoadData()
                    })
                    
                    //self.tableView.reloadData()
                }
            })
            
            sender.deselect()
        }
            
        else
        {
            print("like")
            sender.select()
            print("the tag is\(sender.tag)")
            var index = sender.tag
            var id = self.statusData[index].objectId

            sender.imageColorOn = UIColor.flatRedColor()
            likedstatus = true
            
            let string = "\(PFUser.currentUser()!.username!) has liked your post"
            self.SavingNotifacations(string, objectID: id!!, notificationType:"like")
            var query = PFQuery(className: "StatusUpdate")
            query.orderByDescending("createdAt")
            print(currentobjectID)
            
            
            query.getObjectInBackgroundWithId(id!!, block: { (update, error) -> Void in
                
                if error == nil
                {
                    update!.incrementKey("likes", byAmount: 1)
                    print("saved")
                    update!["likedby"] = PFUser.currentUser()!.username!
                    update!.saveInBackground()
                    
                    
                    let QOS = QOS_CLASS_BACKGROUND
                    let backgroundqueue = dispatch_get_global_queue(QOS, 0)
                    dispatch_async(backgroundqueue, { () -> Void in
                        self.LoadData()
                      

                    })
                    
                }
            })
        }
    }
    
    
    
    
    func SavingNotifacations(notifcation:String, objectID:String, notificationType:String)
    {
        var query = PFQuery(className: "StatusUpdate")
        
        query.getObjectInBackgroundWithId(objectID) { (object, error) -> Void in
            if error == nil
            {
                if (PFUser.currentUser()!.objectId! != (object?.objectForKey("user") as! PFUser).objectId!)
                {
                    PFCloud.callFunctionInBackground("StatusUpdate", withParameters: ["message" : notifcation, "user" : "\(PFUser.currentUser()?.username!)"])
                    
                    ManageUser.saveUserNotification(notifcation, fromUser: PFUser.currentUser()!, toUser: object?.objectForKey("user") as! PFUser, extType: notificationType, extObjectID: objectID)
                }
            }
        }
        
       /* var query = PFQuery(className: "StatusUpdate")
        
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
*/
    }
    
    
    func isDatePassed(date1:NSDate, date2:NSDate, ParseID: String)
    {
        print(date1)
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        var newdate = dateformatter.stringFromDate(date2)
        
       
        
       
    


    
        

    
        if date1.timeIntervalSince1970 < date2.timeIntervalSince1970
        {
            print("Date2 has passed")
            
            var query = PFQuery(className: "StatusUpdate")
            query.orderByDescending("createdAt")
            query.addDescendingOrder("dateofevent")
            query.addDescendingOrder("updateddAt")
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
                        
                    if  aobject.objectForKey("dateofevent") as! String > newdate
                        
                        
                    {
                        print("going tense")
                        aobject["tense"] = "Going"
                        aobject.saveInBackground()
                    }
                        

                    
                        
                        
                    else if newdate != aobject.objectForKey("dateofevent") as! String
                    {
                        print("tense is going to change")
                        aobject["tense"] = "went"
                        aobject.saveInBackground()
                        
                    }
                    
                }
            })
            
            
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
    
    func ReportView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
        
        
    }
    
    

    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        ///reporting statusupdates
        
        
        var report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            var statusupdate = self.statusData[indexPath.row] as! PFObject
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
            var statusupdate = self.statusData[indexPath.row] as! PFObject
            var query = PFQuery(className: "StatusUpdate")
            query.includeKey("user")
            query.orderByDescending("createdAt")
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
                                    self.LoadData()
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
        let statusObject = self.statusData[indexPath.row] as! PFObject
        
        // Only show the delete button if the
        // user is looking at one of their own posts.
        
        if (((statusObject["user"]).objectId) == PFUser.currentUser()?.objectId) {
            return [report, deletestatus]
        }
            
        else {
            return [report]
        }

    }
    
   
    
    
    
    
    




    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}