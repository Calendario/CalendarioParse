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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SearchViewV2 : UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Setup the various UI objects.
    @IBOutlet weak var userList: UICollectionView!
    @IBOutlet weak var eventList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabelOne: UILabel!
    @IBOutlet weak var titleLabelTwo: UILabel!
    @IBOutlet weak var noUsersLabel: UILabel!
    @IBOutlet weak var noEventsLabel: UILabel!
    var introSearchView: UIView!
    var introSearchImage: UIImageView!
    var introSearchLabel: UITextView!
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    var userData:NSMutableArray = []
    
    //MARK: BUTTONS.
    
    @IBAction func openFilterSettings(_ sender: UIButton) {
        let sb = UIStoryboard(name: "SearchFilterUI", bundle: nil)
        let filterVC = sb.instantiateViewController(withIdentifier: "FilterView") as! SearchFilterView
        self.present(filterVC, animated: true, completion: nil)
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Create and add the intro view to the search view.
        self.introSearchView = UIView(frame: CGRect(x: 0, y: (self.view.frame.size.height / 2), width: self.view.frame.size.width, height: 200))
        self.view.addSubview(self.introSearchView)
        self.introSearchLabel = UITextView(frame: CGRect(x: (self.introSearchView.frame.origin.x / 2), y: 0, width: (self.introSearchView.frame.size.width - 14), height: 100))
        self.introSearchView.addSubview(self.introSearchLabel)
        self.introSearchLabel.text = "Search for users and events. Tap the filter button to set event filters."
        self.introSearchLabel.textAlignment = NSTextAlignment.center
        self.introSearchLabel.isEditable = false
        self.introSearchLabel.isUserInteractionEnabled = false
        self.introSearchImage = UIImageView(frame:CGRect(x: (self.introSearchView.bounds.width / 2) - 10, y: -50, width: 40, height: 40));
        self.introSearchImage.image = UIImage(named: "searchTabLogo.png")
        self.introSearchImage.contentMode = .scaleAspectFit
        self.introSearchView.addSubview(self.introSearchImage)
        
        // Set the various label fonts.
        self.introSearchLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.titleLabelOne.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.titleLabelTwo.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.noUsersLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.noEventsLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        
        // Set the various UI properties.
        self.userList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.eventList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.userList.backgroundColor = UIColor(red: 223.0/255, green: 223.0/255, blue: 223.0/255, alpha: 1.0)
        self.searchBar.tintColor = UIColor.white
        self.noUsersLabel.isHidden = true
        self.noEventsLabel.isHidden = true
        self.introSearchView.isHidden = false
        self.eventList.isHidden = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        editToolbar.barStyle = UIBarStyle.default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SearchViewV2.hideKeyboard))
        ]
        
        editToolbar.sizeToFit()
        self.searchBar.inputAccessoryView = editToolbar
        
        for subView in self.searchBar.subviews {
            
            for subsubView in subView.subviews {
                
                if let textField = subsubView as? UITextField {
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
                    textField.textColor = UIColor.white
                }
            }
        }
    }
    
    //MARK: DATA LOADING METHODS.
    
    func loadUserData(_ inputString: String) {
        
        var findUsers:PFQuery<PFObject>!
        findUsers = PFUser.query()!
        findUsers.whereKey("username", contains: inputString.lowercased())
        
        findUsers.findObjectsInBackground { (objects:[PFObject]?, error: Error?) in
            
            self.userData.removeAllObjects()
            
            if ((error == nil) && (objects != nil)) {
                self.userData = NSMutableArray(array: (objects! as NSArray))
            }
            
            self.noUsersLabel.isHidden = (self.userData.count > 0)
            self.userList.reloadData()
        }
        
        self.reloadNewsFeed(inputString)
    }
    
    func reloadNewsFeed(_ inputString: String) {
        
        // Get the search filter settings.
        let defaults = UserDefaults.standard
        let locationState = defaults.object(forKey: "filterLocationCheck") as? Bool
        let userState = defaults.object(forKey: "filterUserCheck") as? Bool
        var locationMode:Int = 2
        var point:PFGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        var locatonRadius:Double = 0
        
        if (locationState == true) {
            
            let locationLat = defaults.object(forKey: "filterLocationLat") as? Double
            let locationLon = defaults.object(forKey: "filterLocationLon") as? Double
            locatonRadius = (defaults.object(forKey: "filterLocationRadius") as? Double)!
            let locatonRadiusType = defaults.object(forKey: "filterLocationRadiusType") as? String
            point = PFGeoPoint(latitude:locationLat!, longitude:locationLon!)
            
            if (locatonRadiusType == "mi") {
                locationMode = 1
            } else {
                locationMode = 2
            }
        }
        
        if (userState == true) {
            
            var findUser:PFQuery<PFObject>!
            findUser = PFUser.query()!
            findUser.getObjectInBackground(withId: (defaults.object(forKey: "filterUserObject") as? String)!, block: { (userAccount, error) in
                
                if (error == nil) {
                    self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: true, inputUser: (userAccount as! PFUser))
                    
                } else {
                    self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: false, inputUser: PFUser.current()!)
                }
            })
        } else {
            self.loadNewsFeedData(inputString, locationMode: locationMode, locationPoint: point, radius: locatonRadius, userMode: false, inputUser: PFUser.current()!)
        }
    }
    
    func loadNewsFeedData(_ inputString: String, locationMode: Int, locationPoint: PFGeoPoint, radius: Double, userMode: Bool, inputUser: PFUser) {
        
        // Setup the status update query.
        var query:PFQuery<PFObject>!
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
        query.findObjectsInBackground(block: { (statusUpdates, error) -> Void in
            
            self.statusData.removeAllObjects()
            
            if ((error == nil) && (statusUpdates?.count > 0)) {
                self.statusData =  NSMutableArray(array: statusUpdates!)
            }
            
            self.runSecondFeedQuery(inputString, locationMode: locationMode, locationPoint: locationPoint, radius: radius, userMode: userMode, inputUser: inputUser)
        })
    }
    
    func runSecondFeedQuery(_ inputString: String, locationMode: Int, locationPoint: PFGeoPoint, radius: Double, userMode: Bool, inputUser: PFUser) {

        var queryTwo:PFQuery<PFObject>!
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
        
        queryTwo.findObjectsInBackground(block: { (statusUpdatesTwo, errorTwo) -> Void in
            
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
                            self.statusData.add(statusTwo)
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
        let filterSettings = UserDefaults.standard
        
        // Only sort the data if there are
        // any status updates for the user.
        
        if (self.statusData.count > 0) {
            
            // Sort the status updates by the 'createdAt' date.
            let newData:NSArray = (self.statusData.copy() as! NSArray).sortedArray (comparator: { (obj1, obj2) -> ComparisonResult in
                return ((obj2 as! PFObject).createdAt?.compare((obj1 as! PFObject).createdAt!))!
            }) as NSArray
            
            // Save the sorted data to the mutable array.
            let tempData = NSMutableArray(array: newData)
            
            // Get the data/user filter settings.
            let dateState = filterSettings.object(forKey: "filterDateCheck") as? Bool
            
            if (dateState == true) {
                
                let dateStart = filterSettings.object(forKey: "filterDateStart") as? Date
                let dateEnd = filterSettings.object(forKey: "filterDateEnd") as? Date
                
                self.sortedArray.removeAllObjects()
                
                for loop in 0..<tempData.count {
                    
                    let currentObject:PFObject = tempData[loop] as! PFObject
                    
                    if let dateString = currentObject["dateofevent"] {
                        
                        if ((dateString as! String).characters.count > 1) {
                            
                            let date:Date = self.convertStringToDate(dateString as! String)
                            
                            if (self.isBetweenDates(dateStart!, endDate: dateEnd!, dateToCheck: date) == true) {
                                self.sortedArray.add(tempData[loop])
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
        self.eventList.isScrollEnabled = (self.sortedArray.count > 0)
        self.noEventsLabel.isHidden = (self.sortedArray.count > 0)
        self.eventList.reloadData()
    }
    
    func isBetweenDates(_ beginDate: Date, endDate: Date, dateToCheck: Date) -> Bool {
        
        if dateToCheck.compare(beginDate) == .orderedAscending {
            return false
        }
        
        if dateToCheck.compare(endDate) == .orderedDescending {
            return false
        }
        
        return true
    }
    
    func convertStringToDate(_ inputText: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "M/d/yy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        return dateFormatter.date(from: inputText)!
    }
    
    //MARK: OTHER METHODS.
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Check the search text.
        let searchCheck = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (searchCheck.characters.count > 0) {
            self.titleLabelOne.text = "Users matching \"\(searchText)\""
            self.titleLabelTwo.text = "Events with \"\(searchText)\""
            self.introSearchView.isHidden = true
            self.eventList.isHidden = false
            self.loadUserData(searchText)
        } else {
            self.introSearchView.isHidden = false
            self.eventList.isHidden = true
            self.noEventsLabel.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.hideKeyboard()
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
    
    func hideKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    //MARK: COLLECTIONVIEW METHODS.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! SearchUserCell
        
        if ((indexPath as NSIndexPath).row < self.userData.count) {
            cell.passedInUser = self.userData[(indexPath as NSIndexPath).row] as! PFUser
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if ((indexPath as NSIndexPath).row < self.userData.count) {
            PresentingViews.showProfileView(self.userData[(indexPath as NSIndexPath).row] as! PFUser, viewController: self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    //MARK: TABLEVIEW METHODS.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 511.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                })
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
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
            
            reportquery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
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
            
            var query:PFQuery<PFObject>!
            query = PFQuery(className: "StatusUpdate")
            query.includeKey("user")
            query.whereKey("objectId", equalTo: statusupdate.objectId!)
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                
                if (error == nil) {
                    
                    for object in objects! {
                        
                        let userstr = (object["user"] as AnyObject).username!
                        
                        if (userstr == PFUser.current()?.username) {
                            
                            statusupdate.deleteInBackground(block: { (success, error) -> Void in
                                
                                if (success) {
                                    
                                    // Remove the status update from the array.
                                    self.sortedArray.removeObject(at: (indexPath as NSIndexPath).row)
                                    
                                    // Remove the cell from the table view.
                                    self.eventList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                                }
                            })
                        }
                            
                        else {
                            let alert = UIAlertController(title: "Error", message: "You can only delete your own posts.", preferredStyle: .alert)
                            alert.view.tintColor = UIColor.flatGreen()
                            let next = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                            alert.addAction(next)
                            
                            self.present(alert, animated: true, completion: nil)
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
