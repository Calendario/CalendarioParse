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

class SearchFilterView : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate {
    
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
    @IBOutlet weak var scroll: UIScrollView!
    
    // Filter settings data.
    var dateOne:Date!
    var dateTwo:Date!
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
    
    @IBAction func goBack(_ sender: UIButton) {
        self.checkSettings()
    }
    
    @IBAction func changeDate(_ sender: UIDatePicker) {
        
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
    
    @IBAction func changeDateSwitch(_ sender: UISwitch) {
        self.blockViewOne.isHidden = sender.isOn
        self.blockViewTwo.isHidden = sender.isOn
        self.dateOneLabel.isUserInteractionEnabled = sender.isOn
        self.dateTwoLabel.isUserInteractionEnabled = sender.isOn
        
        if (sender.isOn == false) {
            self.dateView.isHidden = true
        }
    }
    
    @IBAction func changeLocationSwitch(_ sender: UISwitch) {
        self.blockViewThree.isHidden = sender.isOn
        self.blockViewFour.isHidden = sender.isOn
        self.locationOneLabel.isUserInteractionEnabled = sender.isOn
        self.locationTwoLabel.isUserInteractionEnabled = sender.isOn
        
        if (sender.isOn == false) {
            self.radiusView.isHidden = true
        }
    }
    
    @IBAction func changeUserSwitch(_ sender: UISwitch) {
        self.blockViewFive.isHidden = sender.isOn
        self.userLabel.isUserInteractionEnabled = sender.isOn
    }
    
    //MARK: VIWW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: VIEW DID APPEAR METHOD.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkForSetLocation()
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Setup the user pass back notification.
        NotificationCenter.default.addObserver(self, selector: #selector(SearchFilterView.updateUser(_:)), name: NSNotification.Name(rawValue: "userSelected"), object: nil)
        
        // Setup the scroll view.
        self.scroll.isScrollEnabled = true
        let result: CGSize = UIScreen.main.bounds.size
        
        if result.height == 480 {
            scroll.contentSize = CGSize(width: result.width, height: 520)
        } else {
            scroll.contentSize = CGSize(width: result.width, height: 520)
        }
        
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
        self.dateView.isHidden = true
        self.radiusView.isHidden = true
        
        // Get the current filter settings.
        let defaults = UserDefaults.standard
        let dateState = defaults.object(forKey: "filterDateCheck") as? Bool
        let locationState = defaults.object(forKey: "filterLocationCheck") as? Bool
        let userState = defaults.object(forKey: "filterUserCheck") as? Bool
        
        // Set the switches.
        self.dateSwitch.setOn(dateState!, animated: true)
        self.locationSwitch.setOn(locationState!, animated: true)
        self.userSwitch.setOn(userState!, animated: true)
        
        // Set the block hidden and label interaction states.
        self.blockViewOne.isHidden = dateState!
        self.blockViewTwo.isHidden = dateState!
        self.blockViewThree.isHidden = locationState!
        self.blockViewFour.isHidden = locationState!
        self.blockViewFive.isHidden = userState!
        self.dateOneLabel.isUserInteractionEnabled = dateState!
        self.dateTwoLabel.isUserInteractionEnabled = dateState!
        self.locationOneLabel.isUserInteractionEnabled = locationState!
        self.locationTwoLabel.isUserInteractionEnabled = locationState!
        self.userLabel.isUserInteractionEnabled = userState!
        
        // Set the other labels depending on
        // the current filter settings.
        
        if (dateState == true) {
            self.dateOne = defaults.object(forKey: "filterDateStart") as? Date
            self.dateTwo = defaults.object(forKey: "filterDateEnd") as? Date
            self.dateOneLabel.text = self.convertDateToString(self.dateOne!)
            self.dateTwoLabel.text = self.convertDateToString(self.dateTwo!)
        }
        
        if (locationState == true) {
            self.checkForSetLocation()
            self.locatonRadius = defaults.object(forKey: "filterLocationRadius") as? Double
            self.locatonRadiusType = defaults.object(forKey: "filterLocationRadiusType") as? String
            self.locationTwoLabel.text = "\(self.locatonRadius!) \(self.locatonRadiusType!)"
        }
        
        if (userState == true) {
            
            var findUser:PFQuery<PFObject>!
            findUser = PFUser.query()!
            findUser.getObjectInBackground(withId: (defaults.object(forKey: "filterUserObject") as? String)!, block: { (userAccount, error) in
                
                if (error == nil) {
                    self.userObject = (userAccount as! PFUser)
                    self.userLabel.text = self.userObject.username!
                }
            })
        }
    }
    
    func setDateSelection(_ sender: UITapGestureRecognizer) {
        self.currentDateSelection = ((sender.view?.tag)! - 1)
        self.dateView.isHidden = !self.dateView.isHidden
    }
    
    func setLocationSelection() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = sb.instantiateViewController(withIdentifier: "LocationVC") as UIViewController!
        self.present(filterVC!, animated: true, completion: nil)
    }
    
    func setLocationRadiusSelection() {
        self.radiusView.isHidden = !self.radiusView.isHidden
    }
    
    func setUserSelection() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = sb.instantiateViewController(withIdentifier: "UserSearch") as UIViewController!
        self.present(filterVC!, animated: true, completion: nil)
    }
    
    func updateUser(_ object: Notification) {
        self.userObject = (object.object as! PFUser)
        self.userLabel.text = self.userObject.username!
    }
    
    func checkForSetLocation() {

        // Get the current filter settings.
        let defaults = UserDefaults.standard

        // Set the location data/labels.
        
        if ((self.locationSwitch.isOn == true) && (defaults.object(forKey: "filterLocationLat") != nil)) {
            self.locationName = defaults.object(forKey: "filterLocationName") as? String
            self.locationLat = defaults.object(forKey: "filterLocationLat") as? Double
            self.locationLon = defaults.object(forKey: "filterLocationLon") as? Double
            self.locationOneLabel.text = self.locationName!
        }
    }
    
    //MARK: DATA METHODS.
    
    func convertDateToString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return dateFormatter.string(from: date)
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
        
        if (self.dateSwitch.isOn == true) {
            
            if ((self.dateOne != nil) && (self.dateTwo != nil)) {
                
                if self.dateOne.isLessThanDate(self.dateTwo) {
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
        
        if (self.locationSwitch.isOn == true) {
            
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
        
        if (self.userSwitch.isOn == true) {
            
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
        let defaults = UserDefaults.standard
        
        // Set the filters to on/off depending on the switch.
        defaults.set(self.dateSwitch.isOn, forKey: "filterDateCheck")
        defaults.set(self.locationSwitch.isOn, forKey: "filterLocationCheck")
        defaults.set(self.userSwitch.isOn, forKey: "filterUserCheck")
        
        // Set the date filter settings.
        
        if (self.dateSwitch.isOn == true) {
            defaults.set(self.dateOne, forKey: "filterDateStart")
            defaults.set(self.dateTwo, forKey: "filterDateEnd")
        } else {
            defaults.removeObject(forKey: "filterDateStart")
            defaults.removeObject(forKey: "filterDateEnd")
        }
        
        // Set the location filter settings.
        
        if (self.locationSwitch.isOn == true) {
            defaults.set(self.locationName, forKey: "filterLocationName")
            defaults.set(self.locationLat, forKey: "filterLocationLat")
            defaults.set(self.locationLon, forKey: "filterLocationLon")
            defaults.set(self.locatonRadius, forKey: "filterLocationRadius")
            defaults.set(self.locatonRadiusType, forKey: "filterLocationRadiusType")
        } else {
            defaults.removeObject(forKey: "filterLocationName")
            defaults.removeObject(forKey: "filterLocationLat")
            defaults.removeObject(forKey: "filterLocationLon")
            defaults.removeObject(forKey: "filterLocationRadius")
            defaults.removeObject(forKey: "filterLocationRadiusType")
        }
        
        // Set the 'by user' username filter setting.
        
        if (self.userSwitch.isOn == true) {
            defaults.set(self.userObject.objectId!, forKey: "filterUserObject")
        } else {
            defaults.removeObject(forKey: "filterUserObject")
        }
        
        // Save the new filter settings.
        defaults.synchronize()

        // Close the filter view.
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: OTHER METHODS.
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: UISCROLLVIEW METHODS.
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.dateView.isHidden = true
        self.radiusView.isHidden = true
    }
    
    //MARK: UIPICKER METHODS.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0) {
            return self.pickerDataSetOne.count
        } else {
            return self.pickerDataSetTwo.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (component == 0) {
            return "\(self.pickerDataSetOne[row])"
        } else {
            return self.pickerDataSetTwo[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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
