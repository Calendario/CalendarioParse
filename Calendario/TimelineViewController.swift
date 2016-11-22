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
    var eventsarray = [Date]()
    var selectedDate:Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        loadCalendarData(getCurrentDate())
    }
    
    func setupUI() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        setTableViewProperties()
        setCalendarProperties()
        setNavBarProperties()
    }
    
    func setTableViewProperties() {
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.rowHeight = UITableViewAutomaticDimension;
        self.tableview.estimatedRowHeight = 292.0;
        self.tableview.separatorInset = UIEdgeInsets.zero
        self.tableview.sectionHeaderHeight = 0
        self.tableview.sectionFooterHeight = 0
        self.tableview.separatorColor = UIColor.clear

    }
    
    func setNavBarProperties() {
        self.navigationBar.topItem?.title = "Timeline"
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 18)!, NSForegroundColorAttributeName: UIColor.white]
        
        let image = UIImage()
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
    }
    
    func setCalendarProperties() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollDirection = .horizontal
        calendar.select(Date())
        calendar.appearance.eventColor = UIColor.white
        calendar.appearance.titleSelectionColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        calendar.appearance.weekdayFont = UIFont(name: "SFUIDisplay-Regular", size: 14)
        calendar.appearance.titleFont = UIFont(name: "SFUIDisplay-Light", size: 16)
        calendar.appearance.subtitleFont = UIFont(name: "SFUIDisplay-Light", size: 16)
        calendar.layoutIfNeeded()
    }
    
    func ReportView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewController(withIdentifier: "report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.present(NC, animated: true, completion: nil)
    }
    
    
    func getCurrentDate() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let currentDate = dateformatter.string(from: Date())
        return currentDate
    }
    
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        
        selectedDate = date
        eventsarray.append(date)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let newdate_V1 = dateformatter.string(from: date)
        
        // Load the calendar data.
        self.loadCalendarData(newdate_V1)
    }
    
    func loadCalendarData(_ selectedData: String) {
        
        let getdates:PFQuery = PFQuery(className: "StatusUpdate")
        getdates.whereKey("dateofevent", equalTo: selectedData)
        getdates.includeKey("user")
        let defaults = UserDefaults.standard
        defaults.set(selectedData, forKey: "dateofevent")
        
        var postsdata:NSMutableArray = NSMutableArray()
        
        getdates.findObjectsInBackground { (objects:[PFObject]?, error: Error?) in
            
            if error == nil {
                
                print(objects)
                
                // print(objects!.count)
                for object in objects! {
                    
                    let statusupdate:PFObject = object
                    postsdata.add(statusupdate)
                    self.b = true
                }
                
                let array:NSArray = postsdata.reverseObjectEnumerator().allObjects as NSArray
                postsdata = NSMutableArray(array: array)
                
                // Reset the filtered data array.
                self.filteredData.removeAllObjects()
                
                // Get the list of accounts the user is following.
                ManageUser.getUserFollowingList(PFUser.current()!, withCurrentUser: true, completion: { (userFollowing) -> Void in
                    
                    // We need to filter the post data so that we only
                    // see the status updates of people we are folowing.
                    
                    for loop in 0..<postsdata.count {
                        
                        // Get the current user from the
                        // downloaded status update data.
                        let loopUser:PFUser = (postsdata[loop] as AnyObject).value(forKey: "user") as! PFUser
                        
                        // Loop through the following array and check if the user
                        // from the postsdata array is being followed or not.
                        
                        for loopTwo in 0..<userFollowing.count {
                            
                            // Get the current user from the following array.
                            let followingUser:PFUser = userFollowing[loopTwo] as! PFUser
                            
                            // If the user matches add the data
                            // to the filtered data array.
                            
                            if (loopUser.objectId! == followingUser.objectId!) {
                                self.filteredData.add(postsdata[loop])
                            }
                        }
                    }
                    
                    DispatchQueue.main.async(execute: {
                        
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
    
    func getImageData(_ objects:[PFObject], imageView:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackground(block: { (imagedata, error) -> Void in
                    if error == nil
                    {
                        let image = UIImage(data: imagedata!)
                        imageView.image = image
                    }
                    else
                    {
                        imageView.image = UIImage(named: "default_profile_pic.png")
                    }
                })
            } else {
                imageView.image = UIImage(named: "default_profile_pic.png")
            }
        }
    }
    
    //MARK: TABLEVIEW METHODS
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.filteredData.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
        // Setup the report status button.
        var report:UITableViewRowAction!
        report = UITableViewRowAction(style: .normal, title: "Report") { (action, index) -> Void in
            
            let defaults = UserDefaults.standard
            defaults.set(statusupdate.objectId, forKey: "reported")
            
            self.ReportView()
            
            var reportquery:PFQuery<PFObject>!
            reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.object(forKey: "updatetext")!)
            
            reportquery.findObjectsInBackground(block: { (objects:[PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    if let objects = objects as [PFObject]! {
                        
                        var reportedID:String!
                        
                        for object in objects {
                            reportedID = object.objectId
                        }
                        
                        var reportstatus:PFQuery<PFObject>!
                        reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackground(withId: reportedID, block: { (status:PFObject?, error: Error?) in
                            
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
        let deletestatus = UITableViewRowAction(style: .normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            // Delete the selected status update.
            ManageUser.deleteStatusUpdate(statusupdate, self, completion: { (deletionSuccess) in
                
                if (deletionSuccess == true) {
                    
                    // Remove the status update from the array.
                    self.filteredData.removeObject(at: (indexPath as NSIndexPath).row)
                    
                    // Remove the cell from the table view.
                    self.tableview.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
            })
        }
        
        // Set the button backgrond colours.
        //   seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
        report.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)
        
        
        // Only show the delete button if the status
        // belongs to the currently logged in user.
        
        if ((statusupdate.object(forKey: "user") as! PFUser!).objectId! == PFUser.current()?.objectId!) {
            
            // For V1.0 we will not be adding access to
            // the "See More" section as it is not needed.
            // return [report, seemore, deletestatus]
            return [report, deletestatus]
        }
            
        else {
            return [report]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.filteredData[(indexPath as NSIndexPath).row] as! PFObject
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.filteredData[(indexPath as NSIndexPath).row] as! PFObject, cell: cell, autolayoutCheck: true)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.filteredData[(indexPath as NSIndexPath).row] as! PFObject)
        
        ParseCalls.findUserDetails(self.filteredData[(indexPath as NSIndexPath).row] as! PFObject
            , usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        DispatchQueue.global(qos: .background).async {
            
            // Background Thread
            DateManager.createDateDifferenceString((self.filteredData[(indexPath as NSIndexPath).row] as! PFObject).createdAt!) { (difference) -> Void in
                
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                })
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // Other methods.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "timelineComments" {
            //let vc = segue.destinationViewController as! CommentsViewController
            //vc.savedobjectID = currentObjectid
        }
    }
}
