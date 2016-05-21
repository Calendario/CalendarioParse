//
//  HashtagViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 22/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import QuartzCore

class HashtagViewController: UITableViewController {
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    var hashtagString:String!
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    //MARK: LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadInitialHashtagData()
        setActivityIndicatorForRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
      
        // Load in the hashtag feed data.
        self.reloadHashtagFeed()
    }
    
    func setupUI() {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 254.0;
        self.tableView.separatorInset = UIEdgeInsetsZero

        setNavigationBarProperties()
        setBackButtonProperties()
    }
    
    func setNavigationBarProperties() {
        // Set the navigation bar properties.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = hashtagString
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    func setBackButtonProperties() {
        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "back_button.png"), forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: "closeView", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
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
    
    func setActivityIndicatorForRefreshing() {
        menuIndicator.addTarget(self, action: "reloadNewsFeed", forControlEvents: .ValueChanged)
        menuIndicatorActivity(true)
    }
    
    func menuIndicatorActivity(start: Bool) {
        if start == true {
            self.menuIndicator.beginRefreshing()
        } else {
            self.menuIndicator.endRefreshing()
        }
    }

    //MARK: REQUIRED EDIT TABLEVIEW METHODS
    func ReportView() {
        
        // Open the report view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
//    func Seemore() {
//        
//        // Open the see more view.
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
//        let NC = UINavigationController(rootViewController: SMVC)
//        self.presentViewController(NC, animated: true, completion: nil)
//    }
    
    func closeView() {
        
        // Load in the hashtag data.
        var defaults = NSUserDefaults.standardUserDefaults()
        var hashtagData: NSMutableArray = []
        hashtagData = ((defaults.objectForKey("HashtagData"))?.mutableCopy())! as! NSMutableArray
        
        // Set the correct inex number.
        var hashtagIndex = hashtagData[0] as! Int
        hashtagIndex = hashtagIndex - 1
        
        // Remove the last hashtag string and
        // update the hashtag array index number.
        hashtagData.replaceObjectAtIndex(0, withObject: hashtagIndex)
        hashtagData.removeLastObject()
        
        // Save the hashtag data.
        defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(hashtagData, forKey: "HashtagData")
        defaults.synchronize()
        
        // Close the hashtag view.
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //MARK: LOAD DATA METHODS
    
    func loadInitialHashtagData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let hashtagData = defaults.objectForKey("HashtagData") as? NSMutableArray
        
        // Set the hashtag string.
        hashtagString = hashtagData![hashtagData![0] as! Int] as! String
    }
    
    func reloadHashtagFeed() {
        
        self.menuIndicator.beginRefreshing()
        
        // Clear the status data array.
        
        if (self.statusData.count > 0) {
            self.statusData.removeAllObjects()
        }
        
        // Load in the hashtag feed data.
        self.loadHashtagData()
    }
    
    func loadHashtagData() {
        
        // Setup the status update query.
        var query:PFQuery!
        query = PFQuery(className:"StatusUpdate")
        query.limit = 300
        query.whereKey("updatetext", containsString: hashtagString)
        
        // Get the hashtag status update(s).
        query.findObjectsInBackgroundWithBlock({ (statusUpdates, error) -> Void in
            
            if ((error == nil) && (statusUpdates?.count > 0)) {
                
                for (var loop = 0; loop < statusUpdates!.count; loop++) {
                    self.statusData.addObject(statusUpdates![loop])
                }
            }
                
            else {
                
                // Stop the loading indicator.
                self.menuIndicator.endRefreshing()
            }
            
            // Organize the downloaded data.
            self.organizeHashtagData()
        })
    }
    
    func organizeHashtagData() {
        
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
            self.displayAlert("No posts", alertMessage: "No posts have been found containing the \(hashtagString) hashtag.")
        }
    }
    
    //MARK: TABLEVIEW METHODS
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[indexPath.row] as! PFObject
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
      //  seemore.backgroundColor = UIColor.flatGrayColor()
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
