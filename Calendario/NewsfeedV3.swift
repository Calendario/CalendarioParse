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
    var defaults: UserDefaults!
    
    // Setup the on screen UI objects.
    @IBOutlet weak var menuIndicator: UIRefreshControl!
    
    @IBAction func createStatus(_ sender: UIBarButtonItem) {
        showStatusPostView()
    }
    @IBAction func presentSearchController(_ sender: UIBarButtonItem) {
        PresentingViews.ViewSearchController(self)
    }
    
    //MARK: LIFECYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showRecommendedUsers(checkForNewUser())
        setActivityIndicatorForRefreshing()
        setHashtagDefaultKey()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.contentInset = UIEdgeInsetsMake(((self.navigationController?.navigationBar.frame.height)! + 15), 0, 44, 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    func setNavigationBarProperties() {
        let font = UIFont.init(name: "SignPainter-HouseScript", size: 30.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font!, NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        
        let image = UIImage()
        self.navigationController?.navigationBar.shadowImage = image
        self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
    }
    
    func setTableViewProperties() {
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionHeaderHeight = 0
        self.tableView.sectionFooterHeight = 0
        self.tableView.separatorColor = UIColor.clear
    }
    
    func setHashtagDefaultKey() {
        defaults.set(([1, "#test"]) as NSMutableArray, forKey: "HashtagData")
        defaults.synchronize()
    }
    
    func showStatusPostView() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewController(withIdentifier: "PostView") as! StatusUpdateViewController
        self.present(postsview, animated: true, completion: nil)
    }
    
    func setActivityIndicatorForRefreshing() {
        // Link the pull to refresh to the refresh method.
        menuIndicator.addTarget(self, action: #selector(NewsfeedV3.reloadNewsFeed), for: .valueChanged)
        menuIndicatorActivity(true)
    }
    
    func checkForNewUser() -> Bool {
        self.defaults = UserDefaults.standard
        let showRecommendations = defaults.object(forKey: "recoCheck") as? Bool
        
        if (showRecommendations == true) {
            return true
        }
        else {
            return false
        }
    }
    
    func showRecommendedUsers(_ show: Bool) {
        if show {
            // Open the user recommendations view.
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let postsview = sb.instantiateViewController(withIdentifier: "recommend") as! RecommendedUsersViewController
            self.present(postsview, animated: true, completion:{
                
                // Make sure the view does not appear every time.
                self.defaults.set(false, forKey: "recoCheck")
                self.defaults.synchronize()
            })
        }
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
    
    func menuIndicatorActivity(_ start: Bool) {
        if start == true {
            self.menuIndicator.beginRefreshing()
        } else {
            self.menuIndicator.endRefreshing()
        }
    }
    
    //MARK: LOAD DATA METHODS
    func reloadNewsFeed() {
        
        // Start the loading indicators.
        self.menuIndicatorActivity(true)
        
        // Call the newsfeed cloud code method.
        PFCloud.callFunction(inBackground: "getUserNewsFeed", withParameters: ["user" : "\(PFUser.current()!.objectId!)"]) { (response: Any?, error: Error?) in
            
            // Stop the loading indicators.
            self.menuIndicatorActivity(false)
            
            // Check for request errors first.
            
            if (error == nil) {
                
                // Save the sorted data to the mutable array.
                self.sortedArray = NSMutableArray(array: (response as! NSArray))
                
                // Reload the table view.
                self.tableView.reloadData()
                
            } else {
                self.displayAlert("Error", alertMessage: (error?.localizedDescription)!)
            }
        }
    }
    
    //MARK: TABLEVIEW METHODS
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 511.0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsfeedTableViewCell
                
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject
        
        ParseCalls.findUserDetails(self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, cell: cell)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject)
        
        DispatchQueue.global(qos: .background).async {
            
            // Background Thread
            DateManager.createDateDifferenceString((self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject).createdAt!) { (difference) -> Void in
                
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                    
                    //let currentobjects = self.sortedArray[indexPath.row] as! PFObject
                    //let dateofevent = currentobjects.objectForKey("dateofevent") as! String
                    //let currentid = currentobjects.objectId!
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
            PresentingViews.ReportView(self)
            
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
        // WILL BE ADDED IN FUTURE APP UPDATES //
        
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



