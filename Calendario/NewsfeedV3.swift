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

class NewsfeedV3: UITableViewController, UIGestureRecognizerDelegate {
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var followingData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    
    //Create Defaults
    var defaults: NSUserDefaults!
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    @IBAction func createStatus(sender: UIBarButtonItem) {
        showStatusPostView()
    }
    @IBAction func presentSearchController(sender: UIBarButtonItem) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let searchView = sb.instantiateViewControllerWithIdentifier("search") as! SearchViewController
        self.presentViewController(searchView, animated: true, completion: nil)
    }
    
    //MARK: LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showRecommendedUsers(checkForNewUser())
        setActivityIndicatorForRefreshing()
        setHashtagDefaultKey()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        self.reloadNewsFeed()
    }
    
    func setupUI() {
        setStatusBarProperties()
        setTableViewProperties()
        setNavigationBarProperties()
    }
    
    func setStatusBarProperties() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func setNavigationBarProperties() {
        let font = UIFont(name: "SignPainter-HouseScript", size: 30.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.translucent = false
        
        let image = UIImage()
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
    }
    
    func setTableViewProperties() {
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionHeaderHeight = 0
        self.tableView.sectionFooterHeight = 0
    }
    
    func setHashtagDefaultKey() {
        defaults.setObject(([1, "#test"]) as NSMutableArray, forKey: "HashtagData")
        defaults.synchronize()
    }
    
    func showStatusPostView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewControllerWithIdentifier("PostView") as! StatusUpdateViewController
        self.presentViewController(postsview, animated: true, completion: nil)
    }
    
    func setActivityIndicatorForRefreshing() {
        // Link the pull to refresh to the refresh method.
        menuIndicator.addTarget(self, action: "reloadNewsFeed", forControlEvents: .ValueChanged)
        menuIndicatorActivity(true)
    }
    
    func checkForNewUser() -> Bool {
        self.defaults = NSUserDefaults.standardUserDefaults()
        let showRecommendations = defaults.objectForKey("recoCheck") as? Bool
        
        if (showRecommendations == true) {
            return true
        }
        else {
            return false
        }
    }
    
    func showRecommendedUsers(show: Bool) {
        if show {
            // Open the user recommendations view.
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let postsview = sb.instantiateViewControllerWithIdentifier("recommend") as! RecommendedUsersViewController
            self.presentViewController(postsview, animated: true, completion:{
                
                // Make sure the view does not appear every time.
                self.defaults.setObject(false, forKey: "recoCheck")
                self.defaults.synchronize()
            })
        }
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func menuIndicatorActivity(start: Bool) {
        if start == true {
            self.menuIndicator.beginRefreshing()
        } else {
            self.menuIndicator.endRefreshing()
        }
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
            
            menuIndicatorActivity(false)
            
            // Reload the table view.
            self.tableView.reloadData()
        }
            
        else {
            
            menuIndicatorActivity(false)
            // Show the no posts error message.
            self.displayAlert("No posts", alertMessage: "An error has occurred, the newsfeed posts have not been loaded. Make sure you are following at least one person to view posts on the news feed.")
        }
    }
    
    
    //MARK: LOAD DATA METHODS
    func reloadNewsFeed() {
        menuIndicatorActivity(true)
        
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
                    self.menuIndicatorActivity(false)
                    
                    // Show the no posts error message.
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
    
    //MARK: TABLEVIEW METHODS
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 511.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[indexPath.row] as! PFObject
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.sortedArray[indexPath.row] as! PFObject, animatedConstraint: cell.imageViewHeightConstraint, cell: cell)
            
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.sortedArray[indexPath.row] as! PFObject)
            
        ParseCalls.findUserDetails(self.sortedArray[indexPath.row] as! PFObject, usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            
            // Background Thread
            DateManager.createDateDifferenceString((self.sortedArray[indexPath.row] as! PFObject).createdAt!) { (difference) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                })
            }
        })
        
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
            PresentingViews.ReportView(self)
            
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
        
        //        // Setup the see more button.
        //        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
        //
        //            let defaults = NSUserDefaults.standardUserDefaults()
        //            let updatetext = statusupdate.objectForKey("updatetext") as! String
        //            let currentobjectID = statusupdate.objectId
        //
        //            defaults.setObject(updatetext, forKey: "updatetext")
        //            defaults.setObject(currentobjectID, forKey: "objectId")
        //
        //            self.Seemore()
        //        }
        
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
        //   seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
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
}



//MARK: DEREKS TENSE SORTING METHOD
//func isDatePassed(date1:NSDate, date2:NSDate, ParseID: String)
//{
//    print(date1)
//    
//    let dateformatter = NSDateFormatter()
//    dateformatter.dateFormat = "M/d/yy"
//    var newdate = dateformatter.stringFromDate(date2)
//    
//    
//    
//    if date1.timeIntervalSince1970 < date2.timeIntervalSince1970
//    {
//        print("Date2 has passed")
//        
//        var query = PFQuery(className: "StatusUpdate")
//        query.orderByDescending("createdAt")
//        query.addDescendingOrder("dateofevent")
//        query.addDescendingOrder("updateddAt")
//        query.getObjectInBackgroundWithId(ParseID, block: { (updates:PFObject?, error:NSError?) -> Void in
//            if error == nil
//            {
//                var aobject:PFObject = updates!
//                
//                print(error)
//                
//                print(aobject.objectForKey("dateofevent") as! String)
//                print(newdate)
//                
//                if aobject.objectForKey("dateofevent") as! String == newdate
//                {
//                    print("tense stays")
//                    aobject["tense"] = "Currently"
//                    aobject.saveInBackground()
//                    
//                    
//                }
//
//                if  aobject.objectForKey("dateofevent") as! String > newdate
//       
//                    
//                {
//                    print("going tense")
//                    aobject["tense"] = "Going"
//                    aobject.saveInBackground()
//                }
//   
//                else if newdate != aobject.objectForKey("dateofevent") as! String
//                {
//                    print("tense is going to change")
//                    aobject["tense"] = "went"
//                    aobject.saveInBackground()
//                    
//                }
//            }
//        })
//    }
//}

