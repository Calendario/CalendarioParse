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
    @IBOutlet weak var wentView: UIView!
    @IBOutlet weak var currentlyView: UIView!
    @IBOutlet weak var goingView: UIView!
    @IBOutlet weak var wentImage: UIImageView!
    @IBOutlet weak var goingImage: UIImageView!
    
    // Status update data array.
    var statusData:NSMutableArray = []
    var sortedArray:NSMutableArray = []
    var userData:NSMutableArray = []
    
    // Went/Currently/Going filter states.
    var wentFilter = true
    var currentlyFilter = true
    var goingFilter = true
    
    //MARK: BUTTONS.
    
    @IBAction func goBack(_ sender: UIButton) {
        self.searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeFilterState(_ sender: UIButton) {
        
        // Set the filer button states but do NOT allow ALL
        // three filters to be disabled at any one time.
        
        if (sender.tag == 1) {
            
            if ((self.currentlyFilter == false) && (self.goingFilter == false)) {
                self.displayAlert("Error", alertMessage: "You cannot disable all three filters at the same time, as this will result in 0 search results.")
                
            } else {
                self.wentFilter = !self.wentFilter
                self.setFilterViewDesign(state: self.wentFilter, filterView: self.wentView)
                self.organizeNewsFeedData()
            }
        }
        
        else if (sender.tag == 2) {
            
            if ((self.wentFilter == false) && (self.goingFilter == false)) {
                self.displayAlert("Error", alertMessage: "You cannot disable all three filters at the same time, as this will result in 0 search results.")
                
            } else {
                self.currentlyFilter = !self.currentlyFilter
                self.setFilterViewDesign(state: self.currentlyFilter, filterView: self.currentlyView)
                self.organizeNewsFeedData()
            }
        }
        
        else if (sender.tag == 3) {
            
            if ((self.wentFilter == false) && (self.currentlyFilter == false)) {
                self.displayAlert("Error", alertMessage: "You cannot disable all three filters at the same time, as this will result in 0 search results.")
                
            } else {
                self.goingFilter = !self.goingFilter
                self.setFilterViewDesign(state: self.goingFilter, filterView: self.goingView)
                self.organizeNewsFeedData()
            }
        }
    }
    
    func setFilterViewDesign(state: Bool, filterView: UIView) {
        
        // Run the UI update animations.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            
            if (state == true) {
                filterView.alpha = 1.0
            } else {
                filterView.alpha = 0.6
            }
        })
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set the status bar to black.
        UIApplication.shared.statusBarStyle = .default
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Set the status bar to black.
        UIApplication.shared.statusBarStyle = .default
        
        // Set the went and going images to white.
        self.wentImage.image = self.wentImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.goingImage.image = self.goingImage.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        // Curve the edges of the top filter views.
        self.wentView.layer.cornerRadius = 5.0
        self.wentView.clipsToBounds = true
        self.currentlyView.layer.cornerRadius = 5.0
        self.currentlyView.clipsToBounds = true
        self.goingView.layer.cornerRadius = 5.0
        self.goingView.clipsToBounds = true
        
        // Set the various label fonts.
        self.titleLabelOne.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.titleLabelTwo.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.noUsersLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        self.noEventsLabel.font = UIFont(name: "SFUIDisplay-Regular", size: 17)
        
        // Set the various UI properties.
        self.userList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.eventList.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag
        self.userList.backgroundColor = UIColor.white
        self.searchBar.tintColor = UIColor.gray
        self.noUsersLabel.isHidden = true
        self.noEventsLabel.isHidden = true
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
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search users & events", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
                    textField.textColor = UIColor.gray
                }
            }
        }
        
        // Show the on screen keyboard.
        self.searchBar.becomeFirstResponder()
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
            
            DispatchQueue.main.async(execute: {
                self.userList.reloadData()
            })
        }
        
        // Begin the data search method.
        self.loadNewsFeedData(inputString, inputUser: PFUser.current()!)
    }
    
    func loadNewsFeedData(_ inputString: String, inputUser: PFUser) {
        
        // Setup the status update query.
        var query:PFQuery<PFObject>!
        query = PFQuery(className:"StatusUpdate")
        query.limit = 100
        query.whereKey("eventTitle", matchesRegex: inputString, modifiers: "i")
        
        // Get the status update(s).
        query.findObjectsInBackground(block: { (statusUpdates, error) -> Void in
            
            self.statusData.removeAllObjects()
            
            if ((error == nil) && (statusUpdates?.count > 0)) {
                self.statusData =  NSMutableArray(array: statusUpdates!)
            }
            
            self.runSecondFeedQuery(inputString, inputUser: inputUser)
        })
    }
    
    func runSecondFeedQuery(_ inputString: String, inputUser: PFUser) {

        var queryTwo:PFQuery<PFObject>!
        queryTwo = PFQuery(className:"StatusUpdate")
        queryTwo.limit = 100
        queryTwo.whereKey("updatetext", matchesRegex: inputString, modifiers: "i")
        
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
        
        // Only sort the data if there are
        // any status updates for the user.
        
        if (self.statusData.count > 0) {
            
            // Sort the status updates by the 'createdAt' date.
            let newData:NSArray = (self.statusData.copy() as! NSArray).sortedArray (comparator: { (obj1, obj2) -> ComparisonResult in
                return ((obj2 as! PFObject).createdAt?.compare((obj1 as! PFObject).createdAt!))!
            }) as NSArray
            
            // If ALL filters are ON then we can show ALL the downloaded data. If one or two filters
            // are off then remove the appropriate data from the array depending on its tense setting.
            
            if ((self.wentFilter == true) && (self.currentlyFilter == true) && (self.goingFilter == true)) {
                
                // Save the sorted data to the mutable array.
                self.sortedArray = NSMutableArray(array: newData)
            }
            
            else {
                
                // Save the sorted data to the mutable array.
                var tempData:NSMutableArray!
                tempData = NSMutableArray(array: newData)
                
                // Loop through the data and remove the 
                // correct data depending on the filters.
                
                for loop in (0..<tempData.count).reversed() {
                    
                    let loopTense = tenseChanged(((tempData[loop] as! PFObject).value(forKey: "dateofevent")) as! String)
                    
                    // Check if we need to remove 'went' data.
                    
                    if ((self.wentFilter == false) && (loopTense == "Went")) {
                        tempData.removeObject(at: loop)
                    }
                    
                    // Check if we need to remove 'currently' data.
                    
                    if ((self.currentlyFilter == false) && (loopTense == "Currently")) {
                        tempData.removeObject(at: loop)
                    }
                    
                    // Check if we need to remove 'going' data.
                    
                    if ((self.goingFilter == false) && (loopTense == "Going")) {
                        tempData.removeObject(at: loop)
                    }
                }
                
                // Save the sorted data to the mutable array.
                self.sortedArray = NSMutableArray(array: tempData)
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
    
    func tenseChanged(_ passedInEventDate: String) -> String {
        
        // Get the cureent date.
        let currentDate:Date = Date()
        
        // Create a date formatter to turn the date into a readable string.
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "M/d/yy"
        
        // The current date is passed in the date formatter method.
        let datefromstring = dateformatter.date(from: passedInEventDate)
        
        // Set the tense label depending on the comparison result.
        
        if currentDate.compare(datefromstring!) == ComparisonResult.orderedAscending {
            
            // Current date is earlier than date of event.
            return "Going"
            
        } else if currentDate.compare(datefromstring!) == ComparisonResult.orderedDescending {
            
            // Current date is later than date of event.
            return "Went"
            
        } else if currentDate.compare(datefromstring!) == ComparisonResult.orderedSame {
            
            // Current date is same than date of event.
            return "Currently"
            
        } else {
            return "Currently"
        }
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
            self.eventList.isHidden = false
            self.loadUserData(searchText)
        } else {
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
            cell.setUserDetails()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if ((self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject).value(forKey: "image") == nil) {
            return 220
        } else {
            return 440
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the table view custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsfeedTableViewCell
        
        // Pass in the parent view controller.
        cell.parentViewController = self
        
        // Get the specific status object for this cell and call all needed methods.
        cell.passedInObject = self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject
        
        // We are not using autolayout for this cell.
        cell.autolayoutCheck = false
        
        // Reset the image views first.
        cell.userPostedImage.image = nil
        cell.profileimageview.image = nil
        
        ParseCalls.findUserDetails(self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, usernameLabel: cell.UserNameLabel, profileImageView: cell.profileimageview)
        
        ParseCalls.checkForUserPostedImage(cell.userPostedImage, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject, cell: cell, autolayoutCheck: false)
        
        ParseCalls.updateCommentsLabel(cell.commentsLabel, passedObject: self.sortedArray[(indexPath as NSIndexPath).row] as! PFObject)
        
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
            
            // Delete the selected status update.
            ManageUser.deleteStatusUpdate(statusupdate, self, completion: { (deletionSuccess) in
                
                if (deletionSuccess == true) {
                    
                    // Remove the status update from the array.
                    self.sortedArray.removeObject(at: (indexPath as NSIndexPath).row)
                    
                    // Remove the cell from the table view.
                    self.eventList.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
