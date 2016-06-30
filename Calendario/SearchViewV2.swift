//
//  SearchViewV2.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 27/06/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SearchViewV2 : UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Setup the various UI objects.
    @IBOutlet weak var userList: UICollectionView!
    @IBOutlet weak var eventList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabelOne: UILabel!
    @IBOutlet weak var titleLabelTwo: UILabel!
    @IBOutlet weak var noUsersLabel: UILabel!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var introSearchView: UIView!
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    var userData:NSMutableArray = []
    
    //MARK: BUTTONS.
    
    @IBAction func openFilterSettings(sender: UIButton) {
        let sb = UIStoryboard(name: "SearchFilterUI", bundle: nil)
        let filterVC = sb.instantiateViewControllerWithIdentifier("FilterView") as! SearchFilterView
        self.presentViewController(filterVC, animated: true, completion: nil)
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        self.userList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.eventList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        self.userList.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 1.0)
        self.searchBar.tintColor = UIColor.whiteColor()
        self.noUsersLabel.hidden = true
        self.noEventsLabel.hidden = true
        self.introSearchView.hidden = false
        self.eventList.hidden = true
        
        for subView in self.searchBar.subviews {
            
            for subsubView in subView.subviews {
                
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
                    textField.textColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    //MARK: DATA LOADING METHODS.
    
    func loadUserData(inputString: String) {
        
        var findUsers:PFQuery!
        findUsers = PFUser.query()!
        findUsers.whereKey("username", containsString: inputString.lowercaseString)
        
        findUsers.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            
            self.userData.removeAllObjects()
            
            if ((error == nil) && (objects != nil)) {
                self.userData = NSMutableArray(array: (objects! as NSArray))
            }
            
            self.noUsersLabel.hidden = (self.userData.count > 0)
            self.userList.reloadData()
        }
        
        self.reloadNewsFeed(inputString)
    }
    
    func reloadNewsFeed(inputString: String) {
        
        // Get the search filter settings.
        let defaults = NSUserDefaults.standardUserDefaults()
        let locationState = defaults.objectForKey("filterLocationCheck") as? Bool
        let userState = defaults.objectForKey("filterUserCheck") as? Bool
        var locationMode:Int = 2
        var point:PFGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        var locatonRadius:Double = 0
        
        if (locationState == true) {
            
            let locationLat = defaults.objectForKey("filterLocationLat") as? Double
            let locationLon = defaults.objectForKey("filterLocationLon") as? Double
            locatonRadius = (defaults.objectForKey("filterLocationRadius") as? Double)!
            let locatonRadiusType = defaults.objectForKey("filterLocationRadiusType") as? String
            point = PFGeoPoint(latitude:locationLat!, longitude:locationLon!)
            
            if (locatonRadiusType == "mi") {
                locationMode = 1
            } else {
                locationMode = 2
            }
        }
        
        if (userState == true) {
            
            var findUser:PFQuery!
            findUser = PFUser.query()!
            findUser.getObjectInBackgroundWithId((defaults.objectForKey("filterUserObject") as? String)!, block: { (userAccount, error) in
                
                if (error == nil) {
                    self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: true, inputUser: (userAccount as! PFUser))
                    
                } else {
                    self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: false, inputUser: PFUser.currentUser()!)
                }
            })
        } else {
            self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: false, inputUser: PFUser.currentUser()!)
        }
    }
    
    func loadNewsFeedData(inputString: String, locationMode: Int, locationPoint: PFGeoPoint, radius: Double, userMode: Bool, inputUser: PFUser) {
        
        // Setup the status update query.
        var query:PFQuery!
        query = PFQuery(className:"StatusUpdate")
        query.limit = 100
        query.whereKey("eventTitle", matchesRegex: inputString, modifiers: "i")

        if (locationMode == 0) {
            query.whereKey("placeGeoPoint", nearGeoPoint: locationPoint, withinMiles: radius)
        } else if (locationMode == 1) {
            query.whereKey("placeGeoPoint", nearGeoPoint: locationPoint, withinKilometers: radius)
        }
        
        if (userMode == true) {
            query.whereKey("user", equalTo: inputUser)
        }
        
        // Get the status update(s).
        query.findObjectsInBackgroundWithBlock({ (statusUpdates, error) -> Void in
            
            self.statusData.removeAllObjects()
            
            if ((error == nil) && (statusUpdates?.count > 0)) {
                self.statusData =  NSMutableArray(array: statusUpdates!)
            }
            
            self.runSecondFeedQuery(inputString, locationMode: locationMode, locationPoint: locationPoint, radius: radius, userMode: userMode, inputUser: inputUser)
        })
    }
    
    func runSecondFeedQuery(inputString: String, locationMode: Int, locationPoint: PFGeoPoint, radius: Double, userMode: Bool, inputUser: PFUser) {

        var queryTwo:PFQuery!
        queryTwo = PFQuery(className:"StatusUpdate")
        queryTwo.limit = 100
        queryTwo.whereKey("updatetext", matchesRegex: inputString, modifiers: "i")
        
        if (locationMode == 0) {
            queryTwo.whereKey("placeGeoPoint", nearGeoPoint: locationPoint, withinMiles: radius)
        } else if (locationMode == 1) {
            queryTwo.whereKey("placeGeoPoint", nearGeoPoint: locationPoint, withinKilometers: radius)
        }
        
        if (userMode == true) {
            queryTwo.whereKey("user", equalTo: inputUser)
        }
        
        queryTwo.findObjectsInBackgroundWithBlock({ (statusUpdatesTwo, errorTwo) -> Void in
            
            if ((errorTwo == nil) && (statusUpdatesTwo!.count > 0)) {
                
                if (self.statusData.count > 0) {
                    
                    for loop in 0..<statusUpdatesTwo!.count {
                        
                        let statusTwo:PFObject = statusUpdatesTwo![loop]
                        var matchCheck:Bool = false
                        
                        for innerLoop in 0..<self.statusData.count {
                            
                            let status:PFObject = self.statusData[innerLoop] as! PFObject
                            
                            if (status.objectId! == statusTwo.objectId!) {
                                matchCheck = true
                                break
                            }
                        }
                        
                        if (matchCheck == false) {
                            self.statusData.addObject(statusTwo)
                        }
                    }
                    
                } else {
                    
                    if (statusUpdatesTwo!.count > 0) {
                        self.statusData =  NSMutableArray(array: statusUpdatesTwo!)
                    }
                }
            }
            
            self.organizeNewsFeedData()
        })
    }
    
    func organizeNewsFeedData() {
        
        // Get the feed filter settings.
        let filterSettings = NSUserDefaults.standardUserDefaults()
        
        // Only sort the data if there are
        // any status updates for the user.
        
        if (self.statusData.count > 0) {
            
            // Sort the status updates by the 'createdAt' date.
            let newData:NSArray = (self.statusData.copy() as! NSArray).sortedArrayUsingComparator { (obj1, obj2) -> NSComparisonResult in
                return ((obj2 as! PFObject).createdAt?.compare((obj1 as! PFObject).createdAt!))!
            }
            
            // Save the sorted data to the mutable array.
            let tempData = NSMutableArray(array: newData)
            
            // Get the data/user filter settings.
            let dateState = filterSettings.objectForKey("filterDateCheck") as? Bool
            
            if (dateState == true) {
                
                let dateStart = filterSettings.objectForKey("filterDateStart") as? NSDate
                let dateEnd = filterSettings.objectForKey("filterDateEnd") as? NSDate
                
                self.sortedArray.removeAllObjects()
                
                for loop in 0..<tempData.count {
                    
                    let currentObject:PFObject = tempData[loop] as! PFObject
                    
                    if let dateString = currentObject["dateofevent"] {
                        
                        if ((dateString as! String).characters.count > 1) {
                            
                            let date:NSDate = self.convertStringToDate(dateString as! String)
                            
                            if (self.isBetweenDates(dateStart!, endDate: dateEnd!, dateToCheck: date) == true) {
                                self.sortedArray.addObject(tempData[loop])
                            }
                        }
                    }
                }
            } else {
                self.sortedArray = NSMutableArray(array: newData)
            }
        }
            
        else {
            
            // Show the no posts error message.
            self.sortedArray.removeAllObjects()
        }
        
        // Reload the table view.
        self.eventList.scrollEnabled = (self.sortedArray.count > 0)
        self.noEventsLabel.hidden = (self.sortedArray.count > 0)
        self.eventList.reloadData()
    }
    
    func isBetweenDates(beginDate: NSDate, endDate: NSDate, dateToCheck: NSDate) -> Bool {
        
        if dateToCheck.compare(beginDate) == .OrderedAscending {
            return false
        }
        
        if dateToCheck.compare(endDate) == .OrderedDescending {
            return false
        }
        
        return true
    }
    
    func convertStringToDate(inputText: String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.dateFormat = "M/d/yy"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")

        return dateFormatter.dateFromString(inputText)!
    }
    
    //MARK: OTHER METHODS.
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Check the search text.
        let searchCheck = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (searchCheck.characters.count > 0) {
            self.titleLabelOne.text = "Users matching \"\(searchText)\""
            self.titleLabelTwo.text = "Events with \"\(searchText)\""
            self.introSearchView.hidden = true
            self.eventList.hidden = false
            self.loadUserData(searchText)
        } else {
            self.introSearchView.hidden = false
            self.eventList.hidden = true
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
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
    
    //MARK: COLLECTIONVIEW METHODS.
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userData.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! SearchUserCell
        
        if (indexPath.row < self.userData.count) {
            cell.passedInUser = self.userData[indexPath.row] as! PFUser
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row < self.userData.count) {
            PresentingViews.showProfileView(self.userData[indexPath.row] as! PFUser, viewController: self)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: TABLEVIEW METHODS.
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 511.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[indexPath.row] as! PFObject
        
        ParseCalls.findUserDetails(self.sortedArray[indexPath.row] as! PFObject, usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.sortedArray[indexPath.row] as! PFObject, cell: cell)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.sortedArray[indexPath.row] as! PFObject)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {() -> Void in
            
            // Background Thread
            DateManager.createDateDifferenceString((self.sortedArray[indexPath.row] as! PFObject).createdAt!) { (difference) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {() -> Void in
                    
                    // Run UI Updates
                    cell.createdAtLabel.text = difference
                    
                    //let currentobjects = self.sortedArray[indexPath.row] as! PFObject
                    //let dateofevent = currentobjects.objectForKey("dateofevent") as! String
                    //let currentid = currentobjects.objectId!
                    //tenseChanged(NSDate(), StatusObjectID: currentid, StatusDateofevent: dateofevent)
                })
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
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
                                    self.eventList.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
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
        // seemore.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
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
