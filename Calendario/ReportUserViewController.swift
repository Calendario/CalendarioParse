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
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedUser:PFUser!
    var userString:String!
    
    // Report category data.
    var categoryCheck = false
    var reportCategoryString:String!
    
    // Setup the on screen button actions.
    
    @IBAction func cancel(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.reportDesc.resignFirstResponder()
        
        // Go back to the profile page.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitReport(sender: UIButton) {
        
        // Perform the report data checks
        // before submitting the report.
        self.checkReportData()
    }
    
    @IBAction func selectCategory(sender: UIButton) {
        
        // Show the variosu report categories.
        let unblockAlert = UIAlertController(title: "Report category", message: "Select one of the following categories and then enter the report description below.", preferredStyle: .ActionSheet)
        
        // Setup the alert actions.
        let actionOne = { (action:UIAlertAction!) -> Void in
            
            self.reportCategoryString = "Harassment"
            self.categorySelected("I am being harassed by \(self.userString)")
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
        let buttonOne = UIAlertAction(title: "I am being harassed by \(userString)", style: .Default, handler: actionOne)
        let buttonTwo = UIAlertAction(title: "I have witnessed abusive behavior.", style: .Default, handler: actionTwo)
        let buttonThree = UIAlertAction(title: "Other", style: .Default, handler: actionThree)
        let cancel = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        // Add the actions to the alert.
        unblockAlert.addAction(buttonOne)
        unblockAlert.addAction(buttonTwo)
        unblockAlert.addAction(buttonThree)
        unblockAlert.addAction(cancel)
        
        // Present the alert on screen.
        self.presentViewController(unblockAlert, animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Turn the profile picture into a cirlce.
        self.userImage.layer.cornerRadius = (self.userImage.frame.size.width / 2)
        self.userImage.clipsToBounds = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        editToolbar.barStyle = UIBarStyle.Default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewDismissKeyboard")
        ]
        
        editToolbar.sizeToFit()
        reportDesc.inputAccessoryView = editToolbar
        
        // Only enable save button access once
        // all the required data has been entered.
        self.saveButton.enabled = false
        
        // Load in the user data.
        self.loadUserData()
    }
    
    // Report data methods.
    
    func checkReportData() {
        
        if (categoryCheck == true) {
            
            if (self.reportDesc.hasText()) {
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
        var blockUserData = PFObject(className:"reportUser")
        blockUserData["reportedUser"] = self.passedUser
        blockUserData["userReporting"] = PFUser.currentUser()
        blockUserData["reportCategory"] = self.reportCategoryString
        blockUserData["reportDesc"] = self.reportDesc.text
        
        // Submit the report request.
        blockUserData.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            // Check if the user report data
            // request was succesful or not.
            
            if (success) {
                
                // The user has been reported.
                let blockUpdate = UIAlertController(title: "Success", message: "The user has been reported. The Calendario team will assess the report and take the appropriate actions.", preferredStyle: .Alert)
                
                // Setup the alert actions.
                let close = { (action:UIAlertAction!) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                
                // Setup the alert buttons.
                let dismiss = UIAlertAction(title: "Dismiss", style: .Default, handler: close)
                
                // Add the actions to the alert.
                blockUpdate.addAction(dismiss)
                
                // Present the alert on screen.
                self.presentViewController(blockUpdate, animated: true, completion: nil)
            }
                
            else {
                
                // There was a problem, check error.description.
                self.displayAlert("Error", alertMessage: "\(error?.description)")
            }
        }
    }
    
    func categorySelected(buttonLabel: String) {
        
        // Set the category check/string.
        self.categoryCheck = true
        
        // Update the category button label.
        self.categoryButton.setTitle(buttonLabel, forState: .Normal)
        
        // Update the save button state.
        self.updateSaveButtonState()
    }
    
    // User data methods.
    
    func loadUserData() {
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // Create the username string.
        userString = "@\(passedUser.username!)"
        
        // Set the user profile labels.
        userFullName.text = passedUser?.objectForKey("fullName") as? String
        userName.text = userString as String
        
        // Check if the user has a profile image.
        
        if (passedUser.objectForKey("profileImage") == nil) {
            
            // No profile picture set the standard image.
            userImage.image = UIImage(named: "default_profile_pic.png")
            
            // Notify the user that the app has stopped loading.
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
            
        else {
            
            let userImageFile = passedUser!["profileImage"] as! PFFile
            
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                
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
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    // Alert methods.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Other methods.
    
    func updateSaveButtonState() {
        
        if ((self.reportDesc.hasText()) && (categoryCheck == true)) {
            saveButton.enabled = true
        }
        
        else {
            saveButton.enabled = false
        }
    }
    
    func setPlaceholderAlpha() {
        
        if (self.reportDesc.hasText()) {
            self.reportDescPlaceholder.alpha = 0.0
        }
            
        else {
            self.reportDescPlaceholder.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        self.setPlaceholderAlpha()
        self.updateSaveButtonState()
    }
    
    func textViewDidChange(textView: UITextView) {
        
        self.setPlaceholderAlpha()
        self.updateSaveButtonState()
    }
    
    func textViewDismissKeyboard() {
        reportDesc.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
