//
//  SearchFilterView.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 28/06/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts

class SearchFilterView : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Setup the various UI objects.
    @IBOutlet weak var dateOneLabel: UILabel!
    @IBOutlet weak var dateTwoLabel: UILabel!
    @IBOutlet weak var locationOneLabel: UILabel!
    @IBOutlet weak var locationTwoLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var userSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var blockViewOne: UIView!
    @IBOutlet weak var blockViewTwo: UIView!
    @IBOutlet weak var blockViewThree: UIView!
    @IBOutlet weak var blockViewFour: UIView!
    @IBOutlet weak var blockViewFive: UIView!
    @IBOutlet weak var radiusPicker: UIPickerView!
    @IBOutlet weak var radiusView: UIView!
    
    // Filter settings data.
    var dateOne:NSDate!
    var dateTwo:NSDate!
    var locationName:String!
    var locationLat:Double!
    var locationLon:Double!
    var locatonRadius:Double!
    var locatonRadiusType:String!
    var userObject:PFUser!
    var currentDateSelection:Int = 0
    let pickerDataSetOne:Array<Double> = [5, 10, 25, 50, 100]
    let pickerDataSetTwo:Array<String> = ["mi", "km"]
    
    //MARK: BUTTONS.
    
    @IBAction func goBack(sender: UIButton) {
        self.checkSettings()
    }
    
    @IBAction func changeDate(sender: UIDatePicker) {
        
        // Create a readable date string.
        let dateString = self.convertDateToString(sender.date)
        
        // Set the appropriate date label.
        
        if (self.currentDateSelection == 0) {
            self.dateOneLabel.text = dateString
            self.dateOne = sender.date
        } else {
            self.dateTwoLabel.text = dateString
            self.dateTwo = sender.date
        }
    }
    
    @IBAction func changeDateSwitch(sender: UISwitch) {
        self.blockViewOne.hidden = sender.on
        self.blockViewTwo.hidden = sender.on
        self.dateOneLabel.userInteractionEnabled = sender.on
        self.dateTwoLabel.userInteractionEnabled = sender.on
    }
    
    @IBAction func changeLocationSwitch(sender: UISwitch) {
        self.blockViewThree.hidden = sender.on
        self.blockViewFour.hidden = sender.on
        self.locationOneLabel.userInteractionEnabled = sender.on
        self.locationTwoLabel.userInteractionEnabled = sender.on
    }
    
    @IBAction func changeUserSwitch(sender: UISwitch) {
        self.blockViewFive.hidden = sender.on
        self.userLabel.userInteractionEnabled = sender.on
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForSetLocation()
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Setup the user pass back notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchFilterView.updateUser(_:)), name: "userSelected", object: nil)
        
        // Set the label tap recognizers.
        let tapgestureDate = UITapGestureRecognizer(target: self, action: #selector(SearchFilterView.setDateSelection(_:)))
        let tapgestureDate_2 = UITapGestureRecognizer(target: self, action: #selector(SearchFilterView.setDateSelection(_:)))
        self.dateOneLabel.addGestureRecognizer(tapgestureDate)
        self.dateTwoLabel.addGestureRecognizer(tapgestureDate_2)

        let tapgestureLocation = UITapGestureRecognizer(target: self, action: #selector(SearchFilterView.setLocationSelection))
        self.locationOneLabel.addGestureRecognizer(tapgestureLocation)

        let tapgestureLocationRadius = UITapGestureRecognizer(target: self, action: #selector(SearchFilterView.setLocationRadiusSelection))
        self.locationTwoLabel.addGestureRecognizer(tapgestureLocationRadius)

        let tapgestureUser = UITapGestureRecognizer(target: self, action: #selector(SearchFilterView.setUserSelection))
        self.userLabel.addGestureRecognizer(tapgestureUser)
        
        // Hide the date picker views by default.
        self.dateView.hidden = true
        self.radiusView.hidden = true
        
        // Get the current filter settings.
        let defaults = NSUserDefaults.standardUserDefaults()
        let dateState = defaults.objectForKey("filterDateCheck") as? Bool
        let locationState = defaults.objectForKey("filterLocationCheck") as? Bool
        let userState = defaults.objectForKey("filterUserCheck") as? Bool
        
        // Set the switches.
        self.dateSwitch.setOn(dateState!, animated: true)
        self.locationSwitch.setOn(locationState!, animated: true)
        self.userSwitch.setOn(userState!, animated: true)
        
        // Set the block hidden and label interaction states.
        self.blockViewOne.hidden = dateState!
        self.blockViewTwo.hidden = dateState!
        self.blockViewThree.hidden = locationState!
        self.blockViewFour.hidden = locationState!
        self.blockViewFive.hidden = userState!
        self.dateOneLabel.userInteractionEnabled = dateState!
        self.dateTwoLabel.userInteractionEnabled = dateState!
        self.locationOneLabel.userInteractionEnabled = locationState!
        self.locationTwoLabel.userInteractionEnabled = locationState!
        self.userLabel.userInteractionEnabled = userState!
        
        // Set the other labels depending on
        // the current filter settings.
        
        if (dateState == true) {
            self.dateOne = defaults.objectForKey("filterDateStart") as? NSDate
            self.dateTwo = defaults.objectForKey("filterDateEnd") as? NSDate
            self.dateOneLabel.text = self.convertDateToString(self.dateOne!)
            self.dateTwoLabel.text = self.convertDateToString(self.dateTwo!)
        }
        
        if (locationState == true) {
            self.checkForSetLocation()
            self.locatonRadius = defaults.objectForKey("filterLocationRadius") as? Double
            self.locatonRadiusType = defaults.objectForKey("filterLocationRadiusType") as? String
            self.locationTwoLabel.text = "\(self.locatonRadius!) \(self.locatonRadiusType!)"
        }
        
        if (userState == true) {
            
            var localUserQuery:PFQuery!
            localUserQuery = PFQuery()
            localUserQuery.fromLocalDatastore()
            localUserQuery.whereKeyExists("filterUserObject")
            localUserQuery.findObjectsInBackgroundWithBlock({ (object, error) in
                
                print("\(object)")
                
                if (error == nil) {
                    self.userObject = (object![0] as! PFUser)
                    self.userLabel.text = self.userObject.username!
                } else {
                    print("\(error?.localizedDescription)")
                }
            })
        }
    }
    
    func setDateSelection(sender: UITapGestureRecognizer) {
        self.currentDateSelection = ((sender.view?.tag)! - 1)
        self.dateView.hidden = !self.dateView.hidden
    }
    
    func setLocationSelection() {
        let locView = self.storyboard!.instantiateViewControllerWithIdentifier("LocationVC") as UIViewController!
        self.presentViewController(locView, animated: true, completion: nil)
    }
    
    func setLocationRadiusSelection() {
        self.radiusView.hidden = !self.radiusView.hidden
    }
    
    func setUserSelection() {
        let userView = self.storyboard!.instantiateViewControllerWithIdentifier("UserSearch") as UIViewController!
        self.presentViewController(userView, animated: true, completion: nil)
    }
    
    func updateUser(object: NSNotification) {
        self.userObject = (object.object as! PFUser)
        self.userLabel.text = self.userObject.username!
    }
    
    func checkForSetLocation() {

        // Get the current filter settings.
        let defaults = NSUserDefaults.standardUserDefaults()

        // Set the location data/labels.
        
        if ((self.locationSwitch.on == true) && (defaults.objectForKey("filterLocationLat") != nil)) {
            self.locationName = defaults.objectForKey("filterLocationName") as? String
            self.locationLat = defaults.objectForKey("filterLocationLat") as? Double
            self.locationLon = defaults.objectForKey("filterLocationLon") as? Double
            self.locationOneLabel.text = self.locationName!
        }
    }
    
    //MARK: DATA METHODS.
    
    func convertDateToString(date: NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return dateFormatter.stringFromDate(date)
    }
    
    func checkSettings() {
        
        if (self.checkTheDate() == true) {
            
            if (self.checkTheLocation() == true) {
                
                if (self.checkTheUser() == true) {
                    self.saveSettings()
                } else {
                    self.displayAlert("Error", alertMessage: "Please make sure you have set a user search filter.")
                }
                
            } else {
                self.displayAlert("Error", alertMessage: "Please make sure you have set the location and radius search filters.")
            }
            
        } else {
            self.displayAlert("Error", alertMessage: "Please make sure you have set the start/end date search filters and that the start date is earlier than the end date.")
        }
    }
    
    func checkTheDate() -> Bool {
        
        if (self.dateSwitch.on == true) {
            
            if ((self.dateOne != nil) && (self.dateTwo != nil)) {
                
                if self.dateOne.earlierDate(self.dateTwo) == self.dateOne {
                    return true
                } else {
                    return false
                }
                
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
    
    func checkTheLocation() -> Bool {
        
        if (self.locationSwitch.on == true) {
            
            if ((self.locationName != nil) && (self.locationLat != nil) && (self.locationLon != nil) && (self.locatonRadius != nil) && (self.locatonRadiusType != nil)) {
                return true
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
    
    func checkTheUser() -> Bool {
        
        if (self.userSwitch.on == true) {
            
            if (self.userObject != nil) {
                return true
            } else {
                return false
            }
            
        } else {
            return true
        }
    }
    
    func saveSettings() {
        
        // Get the settings defaults object.
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // Set the filters to on/off depending on the switch.
        defaults.setObject(self.dateSwitch.on, forKey: "filterDateCheck")
        defaults.setObject(self.locationSwitch.on, forKey: "filterLocationCheck")
        defaults.setObject(self.userSwitch.on, forKey: "filterUserCheck")
        
        // Set the date filter settings.
        
        if (self.dateSwitch.on == true) {
            defaults.setObject(self.dateOne, forKey: "filterDateStart")
            defaults.setObject(self.dateTwo, forKey: "filterDateEnd")
        } else {
            defaults.removeObjectForKey("filterDateStart")
            defaults.removeObjectForKey("filterDateEnd")
        }
        
        // Set the location filter settings.
        
        if (self.locationSwitch.on == true) {
            defaults.setObject(self.locationName, forKey: "filterLocationName")
            defaults.setObject(self.locationLat, forKey: "filterLocationLat")
            defaults.setObject(self.locationLon, forKey: "filterLocationLon")
            defaults.setObject(self.locatonRadius, forKey: "filterLocationRadius")
            defaults.setObject(self.locatonRadiusType, forKey: "filterLocationRadiusType")
        } else {
            defaults.removeObjectForKey("filterLocationName")
            defaults.removeObjectForKey("filterLocationLat")
            defaults.removeObjectForKey("filterLocationLon")
            defaults.removeObjectForKey("filterLocationRadius")
            defaults.removeObjectForKey("filterLocationRadiusType")
        }
        
        // Set the 'by user' username filter setting.
        
        if (self.userSwitch.on == true) {
            self.userObject.pinInBackgroundWithName("filterUserObject") { (success, error) in }
        } else {
            
            var localUserQuery:PFQuery!
            localUserQuery = PFQuery()
            localUserQuery.fromLocalDatastore()
            localUserQuery.whereKeyExists("filterUserObject")
            localUserQuery.findObjectsInBackgroundWithBlock({ (object, error) in
                
                if (error == nil) {
                    (object![0] as! PFUser).unpinInBackgroundWithName("filterUserObject")
                }
            })
        }
        
        // Save the new filter settings.
        defaults.synchronize()

        // Close the filter view.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: OTHER METHODS.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: UIPICKER METHODS.
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0) {
            return self.pickerDataSetOne.count
        } else {
            return self.pickerDataSetTwo.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (component == 0) {
            return "\(self.pickerDataSetOne[row])"
        } else {
            return self.pickerDataSetTwo[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (component == 0) {
            self.locatonRadius = self.pickerDataSetOne[row]
        } else {
            self.locatonRadiusType = self.pickerDataSetTwo[row]
        }
        
        if (self.locatonRadiusType == nil) {
            self.locatonRadiusType = "mi"
        }
        
        if (self.locatonRadius != nil) {
            
            if (self.locatonRadiusType != nil) {
                self.locationTwoLabel.text = "\(self.locatonRadius) \(self.locatonRadiusType)"
            } else {
                self.locationTwoLabel.text = "\(self.locatonRadius)"
            }
            
        } else {
            
            if (self.locatonRadiusType != nil) {
                self.locationTwoLabel.text = "\(self.locatonRadiusType)"
            }
        }
    }
}
