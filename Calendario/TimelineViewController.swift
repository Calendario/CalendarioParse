//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

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
    var eventsarray = [String]()
    
    
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.scrollDirection = .Horizontal
        
        
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
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
        
        print("the date is \(date)")
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let newdate_V1 = dateformatter.stringFromDate(date)
        
        var getdates:PFQuery!
        getdates = PFQuery(className: "StatusUpdate")
        getdates.whereKey("dateofevent", equalTo: newdate_V1)
        print("V1 passed date is \(String(newdate_V1))")
        getdates.includeKey("user")
        
        var postsdata:NSMutableArray = NSMutableArray()
        postsdata.removeAllObjects()
        
        getdates.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            
            if error == nil{
                
                // print(objects!.count)
                for object in objects! {
                    
                    let statusupdate:PFObject = object
                    postsdata.addObject(statusupdate)
                    self.b = true
                }
                
                let array:NSArray = postsdata.reverseObjectEnumerator().allObjects
                postsdata = NSMutableArray(array: array)
                
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
                    
                    // Now reload the table view.
                    self.tableview.reloadData()
                })
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
        
        var datesArray:[NSDate]!
        var eventdate:String!
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/d/yy"
        var newdate = dateformatter.stringFromDate(date)
        var query = PFQuery(className: "StatusUpdate")
        query.whereKey("dateofevent", equalTo: newdate)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        //print(object.valueForKey("dateofevent") as! String)
                        
                        eventdate = object.valueForKey("dateofevent") as! String
                        print(eventdate)
                        
                        datesArray = [dateformatter.dateFromString(eventdate)!]
                        print(datesArray)
                        
                        calendar.selectDate(dateformatter.dateFromString(eventdate))
                        
                        
                        if datesArray.contains(calendar.selectedDate)
                        {
                            //self.b = true
                            print(self.b)
                            
                        }
                        else
                        {
                            self.b = false
                            
                        }
                        
                        
                        
                        
                        
                    }
                    
                }
                
                
                
                
            }
            print(self.b)
        }
        
        return b
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            
            let statusupdate:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
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
        
        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            let statusupdate:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
            let updatetext = statusupdate.objectForKey("updatetext") as! String
            let currentobjectID = statusupdate.objectId
            
            defaults.setObject(updatetext, forKey: "updatetext")
            defaults.setObject(currentobjectID, forKey: "objectId")
            
            self.Seemore()
        }
        
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            let statusupdate:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
            
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
                                    
                                    self.filteredData.removeObjectAtIndex(indexPath.row)
                                    statusupdate.saveInBackground()
                                    self.tableview.reloadData()
                                }
                            })
                        }
                            
                        else {
                            
                            let alert = UIAlertController(title: "Sorry", message: "You can only delete your own posts.", preferredStyle: .Alert)
                            alert.view.tintColor = UIColor.flatGreenColor()
                            let next = UIAlertAction(title: "OK", style: .Default, handler: nil)
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

        // For V1.0 we will not be adding access to
        // the "See More" section as it is not needed.
        // return [report, seemore, deletestatus]
        return [report, deletestatus]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("TimelineCell") as! TimeLineTableViewCell
        let status:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        
        print("\(status)")
        
        cell.userLabel.text = status.valueForKey("user")?.username!
        cell.tenseLabel.text = status.valueForKey("tense") as? String
        cell.updateTextView.text = status.valueForKey("updatetext") as! String
        cell.dateLabel.text = status.valueForKey("dateofevent") as? String
        currentObjectid = status.objectId
        dateofevent = status.valueForKey("dateofevent") as! String
        
        
        
        let likes = status.valueForKey("likes") as? Int
        
        if likes >= 1
        {
            cell.likeButton.setImage(likebuttonfilled, forState: .Normal)
        }
        
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        var getimages:PFQuery!
        getimages = PFUser.query()!
        getimages.whereKey("objectId", equalTo: (status.objectForKey("user")?.objectId)!)
        getimages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            if error == nil {
                self.getImageData(objects!, imageView: cell.profileimageview)
            }
                
            else {
                print("error")
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let status:PFObject = self.filteredData.objectAtIndex(indexPath.row) as! PFObject
        GotoPost(status.objectId!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "timelineComments" {
            let vc = segue.destinationViewController as! CommentsViewController
            vc.savedobjectID = currentObjectid
        }
    }
    
    func GotoPost(objectid:String) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var seemore = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
        let NC = UINavigationController(rootViewController: seemore)
        seemore.propertyid = objectid
        self.presentViewController(NC, animated: true, completion: nil)
    }
}
