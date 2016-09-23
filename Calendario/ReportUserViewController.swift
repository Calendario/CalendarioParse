//
//  ReportUserViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 15/12/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

class ReportUserViewController : UIViewController, UITextViewDelegate {
    
    // Setup the report UI objects.
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var reportDesc: UITextView!
    @IBOutlet weak var reportDescPlaceholder: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var categoryButton: UIButton!
    
    // Passed in user object.
    internal var passedUser:PFUser!
    var userString:String!
    
    // Report category data.
    var categoryCheck = false
    var reportCategoryString:String!
    
    // Setup the on screen button actions.
    
    @IBAction func cancel(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.reportDesc.resignFirstResponder()
        
        // Go back to the profile page.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitReport(_ sender: UIButton) {
        
        // Perform the report data checks
        // before submitting the report.
        self.checkReportData()
    }
    
    @IBAction func selectCategory(_ sender: UIButton) {
        
        // Show the variosu report categories.
        let unblockAlert = UIAlertController(title: "Report category", message: "Select one of the following categories and then enter the report description below.", preferredStyle: .actionSheet)
        
        // Setup the alert actions.
        let actionOne = { (action:UIAlertAction!) -> Void in
            
            self.reportCategoryString = "Harassment"
            self.categorySelected("I am being harassed by @\(self.userString)")
        }
        
        let actionTwo = { (action:UIAlertAction!) -> Void in
            
            self.reportCategoryString = "Witnessed abusive behavior"
            self.categorySelected("I have witnessed abusive behavior within the Calendario community.")
        }
        
        let actionThree = { (action:UIAlertAction!) -> Void in
            
            self.reportCategoryString = "Other"
            self.categorySelected("Other")
        }

        // Setup the alert buttons.
        let buttonOne = UIAlertAction(title: "I am being harassed by @\(userString)", style: .default, handler: actionOne)
        let buttonTwo = UIAlertAction(title: "I have witnessed abusive behavior.", style: .default, handler: actionTwo)
        let buttonThree = UIAlertAction(title: "Other", style: .default, handler: actionThree)
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        // Add the actions to the alert.
        unblockAlert.addAction(buttonOne)
        unblockAlert.addAction(buttonTwo)
        unblockAlert.addAction(buttonThree)
        unblockAlert.addAction(cancel)
        
        // Present the alert on screen.
        self.present(unblockAlert, animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Turn the profile picture into a cirlce.
        self.userImage.layer.cornerRadius = (self.userImage.frame.size.width / 2)
        self.userImage.clipsToBounds = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        editToolbar.barStyle = UIBarStyle.default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ReportUserViewController.textViewDismissKeyboard))
        ]
        
        editToolbar.sizeToFit()
        reportDesc.inputAccessoryView = editToolbar
        
        // Only enable save button access once
        // all the required data has been entered.
        self.saveButton.isEnabled = false
        
        // Load in the user data.
        self.loadUserData()
    }
    
    // Report data methods.
    
    func checkReportData() {
        
        if (categoryCheck == true) {
            
            if (self.reportDesc.hasText) {
                self.submitReportData()
            }
            
            else {
                self.displayAlert("Error", alertMessage: "Please enter a report description. This is vital in helping the Calendario team assess the situation.")
            }
        }
        
        else {
            self.displayAlert("Error", alertMessage: "Please select a report category before saving.")
        }
    }
    
    func submitReportData() {
        
        // Set the user to report and the
        // user which is reporting that user.
        var blockUserData:PFObject!
        blockUserData = PFObject(className:"reportUser")
        blockUserData["reportedUser"] = self.passedUser
        blockUserData["userReporting"] = PFUser.current()
        blockUserData["reportCategory"] = self.reportCategoryString
        blockUserData["reportDesc"] = self.reportDesc.text
        
        // Submit the report request.
        blockUserData.saveInBackground { (success: Bool, error: Error?) in
            
            // Check if the user report data
            // request was succesful or not.
            
            if (success) {
                
                // The user has been reported.
                let blockUpdate = UIAlertController(title: "Success", message: "The user has been reported. The Calendario team will assess the report and take the appropriate actions.", preferredStyle: .alert)
                
                // Setup the alert actions.
                let close = { (action:UIAlertAction!) -> Void in
                    self.dismiss(animated: true, completion: nil)
                }
                
                // Setup the alert buttons.
                let dismiss = UIAlertAction(title: "Dismiss", style: .default, handler: close)
                
                // Add the actions to the alert.
                blockUpdate.addAction(dismiss)
                
                // Present the alert on screen.
                self.present(blockUpdate, animated: true, completion: nil)
            }
                
            else {
                
                // There was a problem, check error.description.
                self.displayAlert("Error", alertMessage: "\(error?.localizedDescription)")
            }
        }
    }
    
    func categorySelected(_ buttonLabel: String) {
        
        // Set the category check/string.
        self.categoryCheck = true
        
        // Update the category button label.
        self.categoryButton.setTitle(buttonLabel, for: UIControlState())
        
        // Update the save button state.
        self.updateSaveButtonState()
    }
    
    // User data methods.
    
    func loadUserData() {
        
        // Notify the user that the app is loading.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Create the username string.
        userString = "\(passedUser.username!)"
        
        // Set the user profile labels.
        userFullName.text = passedUser?.object(forKey: "fullName") as? String
        userName.text = userString as String
        
        // Check if the user has a profile image.
        
        if (passedUser.object(forKey: "profileImage") == nil) {
            
            // No profile picture set the standard image.
            userImage.image = UIImage(named: "default_profile_pic.png")
            
            // Notify the user that the app has stopped loading.
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
            
        else {
            
            let userImageFile = passedUser!["profileImage"] as! PFFile
            
            userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        
                        // Set the downloaded profile image.
                        self.userImage.image = profileImage
                    }
                        
                    else {
                        
                        // No profile picture set the standard image.
                        self.userImage.image = UIImage(named: "default_profile_pic.png")
                    }
                }
                    
                else {
                    
                    // No profile picture set the standard image.
                    self.userImage.image = UIImage(named: "default_profile_pic.png")
                }
                
                // Notify the user that the app has stopped loading.
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
    }
    
    // Alert methods.
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    // Other methods.
    
    func updateSaveButtonState() {
        
        if ((self.reportDesc.hasText) && (categoryCheck == true)) {
            saveButton.isEnabled = true
        }
        
        else {
            saveButton.isEnabled = false
        }
    }
    
    func setPlaceholderAlpha() {
        
        if (self.reportDesc.hasText) {
            self.reportDescPlaceholder.alpha = 0.0
        }
            
        else {
            self.reportDescPlaceholder.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.setPlaceholderAlpha()
        self.updateSaveButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.setPlaceholderAlpha()
        self.updateSaveButtonState()
    }
    
    func textViewDismissKeyboard() {
        reportDesc.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
