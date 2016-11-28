//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    // Setup the various UI objects.
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // Calendar data objects.
    var filteredData:NSMutableArray = NSMutableArray()
    var currentObjectid:String!
    let likebuttonfilled = UIImage(named: "like button filled")
    var dateofevent:String!
    var eventsarray = [Date]()
    var selectedDate:Date!
    var headerSetCheck = false
        
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the calendar date selected notification.
        NotificationCenter.default.addObserver(self, selector: #selector(self.selectCalendarDate(date:)), name: NSNotification.Name(rawValue: "CalenderDateSelected"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupUI()
        
        // It is IMPORTANT that the header view is set in the
        // viewDidAppear method so that ineraction is enabled.
        
        if (self.headerSetCheck == false) {
            
            // Insert the user profile subview as the table header view.
            let story_file = UIStoryboard(name: "TimelineCalendarUI", bundle: nil)
            let calendarSubview = story_file.instantiateViewController(withIdentifier: "CalendarUI") as! TimelineCalendarViewController
            self.addChildViewController(calendarSubview)
            calendarSubview.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 370)
            self.tableview.tableHeaderView = calendarSubview.view
            
            // The header view has been set.
            self.headerSetCheck = true
            
            // Load the initial events for the first selected date.
            self.loadCalendarData(getCurrentDate())
        }
    }
    
    func setupUI() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.setTableViewProperties()
        self.setNavBarProperties()
    }
    
    func setTableViewProperties() {
        self.tableview.isUserInteractionEnabled = true
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
        self.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        let image = UIImage()
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
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
    
    func selectCalendarDate(date: NSNotification) {
        
        self.selectedDate = date.object as! Date!
        self.eventsarray.append(self.selectedDate)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        let newdate_V1 = dateformatter.string(from: self.selectedDate)
        
        // Load the calendar data.
        self.loadCalendarData(newdate_V1)
    }
    
    func loadCalendarData(_ selectedData: String) {
        
        // Save the selected date string (for later use).
        let defaults = UserDefaults.standard
        defaults.set(selectedData, forKey: "dateofevent")
        
        // Load in the events for the selected date.
        PFCloud.callFunction(inBackground: "getStatusUpdatesForDate", withParameters: ["inputeventdate": "\(selectedData)", "user": "\(PFUser.current()!.objectId!)"]) {
            (response: Any?, error) in
            
            // Reset the filtered data array.
            self.filteredData.removeAllObjects()
            
            // Check for data input errors.
            
            if error == nil {
                
                // Ensure we have at least one status update.
                
                if (response != nil) {
                    
                    // Convert the downloaded data into an array.
                    let updatesData:NSArray = (response as! NSArray)
                    
                    if (updatesData.count > 0) {
                        self.filteredData = updatesData.mutableCopy() as! NSMutableArray
                    }
                }
            }
            
            // Now reload the table view.
            self.tableview.reloadData()
        }
    }
    
    func getImageData(_ objects:[PFObject], imageView:UIImageView) {
        
        for object in objects {
            
            if let image = object["profileImage"] as! PFFile? {
                
                image.getDataInBackground(block: { (imagedata, error) -> Void in
                    
                    if error == nil {
                        
                        let image = UIImage(data: imagedata!)
                        imageView.image = image
                    } else {
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
        report.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)
        
        // Only show the delete button if the status
        // belongs to the currently logged in user.
        
        if ((statusupdate.object(forKey: "user") as! PFUser!).objectId! == PFUser.current()?.objectId!) {
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
            DateManager.createDateDifferenceString((self.filteredData[(indexPath as NSIndexPath).row] as! PFObject).createdAt!, false) { (difference) -> Void in
                
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                })
            }
        }
        
        return cell
    }
    
    // Other methods.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
