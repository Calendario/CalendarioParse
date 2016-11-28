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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        // Load in the hashtag feed data.
        self.reloadHashtagFeed()
    }
    
    func setupUI() {
        
        // Set the status bar to white.
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 254.0;
        self.tableView.separatorInset = UIEdgeInsets.zero

        setNavigationBarProperties()
        setBackButtonProperties()
    }
    
    func setNavigationBarProperties() {
        // Set the navigation bar properties.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = hashtagString
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 20)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
    }
    
    func setBackButtonProperties() {
        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(UIImage(named: "back_button.png"), for: UIControlState())
        button.tintColor = UIColor.white
        button.addTarget(self, action: #selector(HashtagViewController.closeView), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    func setActivityIndicatorForRefreshing() {
        menuIndicator.addTarget(self, action: #selector(HashtagViewController.reloadHashtagFeed), for: .valueChanged)
        menuIndicatorActivity(true)
    }
    
    func menuIndicatorActivity(_ start: Bool) {
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
        let reportVC = sb.instantiateViewController(withIdentifier: "report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.present(NC, animated: true, completion: nil)
    }
    
    func closeView() {
        
        // Load in the hashtag data.
        var defaults = UserDefaults.standard
        var hashtagData: NSMutableArray = []
        hashtagData = (((defaults.object(forKey: "HashtagData")) as! NSArray).mutableCopy()) as! NSMutableArray
        
        if (hashtagData.count > 0) {
            
            // Set the correct inex number.
            var hashtagIndex = hashtagData[0] as! Int
            hashtagIndex = hashtagIndex - 1
            
            // Remove the last hashtag string and
            // update the hashtag array index number.
            hashtagData.replaceObject(at: 0, with: hashtagIndex)
            hashtagData.removeLastObject()
            
            // Save the hashtag data.
            defaults = UserDefaults.standard
            defaults.set(hashtagData, forKey: "HashtagData")
            defaults.synchronize()
        }
        
        // Close the hashtag view.
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: LOAD DATA METHODS
    
    func loadInitialHashtagData() {
        let defaults = UserDefaults.standard
        var hashtagData: NSMutableArray = []
        hashtagData = (((defaults.object(forKey: "HashtagData")) as! NSArray).mutableCopy()) as! NSMutableArray
        
        // Set the hashtag string.
        hashtagString = hashtagData[1] as! String
        self.navigationItem.title = hashtagString
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
        var query:PFQuery<PFObject>!
        query = PFQuery(className:"StatusUpdate")
        query.limit = 300
        query.whereKey("updatetext", contains: hashtagString)
        
        // Get the hashtag status update(s).
        query.findObjectsInBackground(block: { (statusUpdates, error) -> Void in
            
            if ((error == nil) && ((statusUpdates?.count)! > 0)) {
                
                for loop in 0..<statusUpdates!.count {
                    self.statusData.add(statusUpdates![loop])
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
            let newData:NSArray = (self.statusData.copy() as! NSArray).sortedArray (comparator: { (obj1, obj2) -> ComparisonResult in
                return ((obj2 as! PFObject).createdAt?.compare((obj1 as! PFObject).createdAt!))!
            }) as NSArray
            
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, cell: cell, autolayoutCheck: true)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject)
        
        ParseCalls.findUserDetails(self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        DispatchQueue.global(qos: .background).async {
            
            // Background Thread
            DateManager.createDateDifferenceString((self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject).createdAt!, false) { (difference) -> Void in
                
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                })
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Get the current status update.
        let statusupdate:PFObject = self.sortedArray.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
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
                        
                        reportstatus.getObjectInBackground(withId: reportedID, block: { (status: PFObject?, error: Error?) in
                            
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
                    self.sortedArray.removeObject(at: (indexPath as NSIndexPath).row)
                    
                    // Remove the cell from the table view.
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
}
