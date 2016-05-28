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

class TimelineViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var filteredData:NSMutableArray = NSMutableArray()
    var currentObjectid:String!
    let likebuttonfilled = UIImage(named: "like button filled")
    var dateofevent:String!
    var b:Bool = false
    var eventsarray = [NSDate]()
    var selectedDate:NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        loadCalendarData(getCurrentDate())
    }
    
    func setupUI() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        setTableViewProperties()
        setCalendarProperties()
        setNavBarProperties()
    }
    
    func setTableViewProperties() {
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.estimatedRowHeight = 292.0;
        self.tableview.separatorInset = UIEdgeInsetsZero
        self.tableview.sectionHeaderHeight = 0
        self.tableview.sectionFooterHeight = 0
    }
    
    func setNavBarProperties() {
        self.navigationBar.topItem?.title = "Timeline"
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 18)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let image = UIImage()
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
    }
    
    func setCalendarProperties() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .Horizontal
        calendar.selectDate(NSDate())
        calendar.appearance.eventColor = UIColor.whiteColor()
        calendar.appearance.titleSelectionColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        calendar.appearance.weekdayFont = UIFont(name: "SFUIDisplay-Regular", size: 14)
        calendar.appearance.titleFont = UIFont(name: "SFUIDisplay-Light", size: 16)
        calendar.appearance.subtitleFont = UIFont(name: "SFUIDisplay-Light", size: 16)
        calendar.layoutIfNeeded()
    }
    
    func ReportView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    
    func getCurrentDate() -> String {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let currentDate = dateformatter.stringFromDate(NSDate())
        return currentDate
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
        
        let getdates:PFQuery = PFQuery(className: "StatusUpdate")
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
                    print("success finding objects")
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
    
    //MARK: TABLEVIEW METHODS
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.filteredData[indexPath.row] as! PFObject
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.filteredData[indexPath.row] as! PFObject, cell: cell)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.filteredData[indexPath.row] as! PFObject)
        
        ParseCalls.findUserDetails(self.filteredData[indexPath.row] as! PFObject
            , usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            
            // Background Thread
            DateManager.createDateDifferenceString((self.filteredData[indexPath.row] as! PFObject).createdAt!) { (difference) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                })
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // Other methods.
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "timelineComments" {
            //let vc = segue.destinationViewController as! CommentsViewController
            //vc.savedobjectID = currentObjectid
        }
    }
}
