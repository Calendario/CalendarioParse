//
//  EditProfileViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 21/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Photos
import QuartzCore

class EditProfileViewController : UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Setup the edit form UI objects.
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userFullName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var userDescriptionPlaceholder: UITextView!
    @IBOutlet weak var userWebsite: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userReEnterPassword: UITextField!
    @IBOutlet weak var editScroll: UIScrollView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var privateSwitch: UISwitch!
    
    // Store the selected profile image data.
    var imageData : NSData!
    
    // Profile image set by user check.
    var userSetImage = false
    
    // Unsaved changes check.
    var editSavedCheck : Bool!
    
    // Setup the on screen button actions.
    
    @IBAction func saveEdit(sender: UIButton) {
        
        // Check the data before saving it.
        checkData()
    }
    
    @IBAction func editPicture(sender: UIButton) {
        
        // Setup the image picker view controller.
        var imagePicker:UIImagePickerController!
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Setup the alert controller.
        let imageAlert = UIAlertController(title: "Profile Picture", message: "Add a photo from your library or take a picture with the camera.", preferredStyle: .Alert)
        
        // Photo library action button.
        let libraryPicture = { (action:UIAlertAction!) -> Void in
            
            // Check if the device has a photo library.
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
                
                // Access the photo library (not the camera).
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                
                // Request photo library authorisation.
                let check = PHPhotoLibrary.authorizationStatus()
                
                // Check to see what the users response if.
                
                if (check == PHAuthorizationStatus.Authorized) {
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }
                    
                else if ((check == PHAuthorizationStatus.NotDetermined) || (check == PHAuthorizationStatus.Denied)) {
                    
                    // Request library authorisation.
                    PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                        
                        // Check to see if access has been granted.
                        
                        if (status == PHAuthorizationStatus.Authorized) {
                            self.presentViewController(imagePicker, animated: true, completion: nil)
                        }
                            
                        else {
                            self.displayAlert("Error", alertMessage: "You have not granted access to your photo library.")
                        }
                    })
                }
                    
                else if (check == PHAuthorizationStatus.Restricted) {
                    self.displayAlert("Error", alertMessage: "You have not granted access to your photo library.")
                }
            }
                
            else {
                self.displayAlert("Error", alertMessage: "Your device does not have a photo library")
            }
        }
        let buttonOne = UIAlertAction(title: "Library", style: .Default, handler: libraryPicture)
        
        // Take a picture button.
        let cameraPicture = { (action:UIAlertAction!) -> Void in
            
            // Check if the device has a camera.
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
                
                // Access the camera (not the photo library).
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                
                // Request access to the camera.
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (success) -> Void in
                    
                    if (success) {
                        self.presentViewController(imagePicker, animated: true, completion: nil)
                    }
                        
                    else {
                        self.displayAlert("Error", alertMessage: "You have not granted access to your camera.")
                    }
                })
            }
                
            else {
                self.displayAlert("Error", alertMessage: "Your device does not have a camera.")
            }
        }
        let buttonTwo = UIAlertAction(title: "Camera", style: .Default, handler: cameraPicture)
        
        // Set to default picture button.
        let defaultPicture = { (action:UIAlertAction!) -> Void in
            
            // The user has not set an image.
            self.userSetImage = false
            
            // Set the image data to the default image.
            self.imageData = UIImageJPEGRepresentation(UIImage(named: "default_profile_pic.png")!, 1.0)
            
            // Set the profile picture to the default image.
            self.userPicture.image = UIImage(named: "default_profile_pic.png")
        }
        let buttonThree = UIAlertAction(title: "Default picture", style: .Default, handler: defaultPicture)
        
        // Cancel button.
        let buttonFour = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        // Add the actions to the alert.
        imageAlert.addAction(buttonOne)
        imageAlert.addAction(buttonTwo)
        
        if (userSetImage == true) {
            imageAlert.addAction(buttonThree)
        }
        
        imageAlert.addAction(buttonFour)
        
        // Present the alert on screen.
        self.presentViewController(imageAlert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Enable access to the UI and
        // hide the loading indicator view.
        self.changeUIAccess(true)
        
        // Check if the user has saved their edits.
        
        if (editSavedCheck == true) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        else if (editSavedCheck == false) {
            
            // Setup the alert controller.
            let exitAlert = UIAlertController(title: "Unsaved changes", message: "Are you sure you want to go back? Your new changes have not been saved.", preferredStyle: .Alert)
            
            // Exit alert action buttons.
            let ok = { (action:UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let buttonOne = UIAlertAction(title: "Exit without saving changes", style: .Destructive, handler: ok)
            
            let cancel = { (action:UIAlertAction!) -> Void in
            }
            let buttonTwo = UIAlertAction(title: "Cancel", style: .Default, handler: cancel)
            
            // Add the actions to the alert.
            exitAlert.addAction(buttonOne)
            exitAlert.addAction(buttonTwo)
            
            // Present the alert on screen.
            self.presentViewController(exitAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchChangeState(sender: UISwitch) {
        editSavedCheck = false
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the loading view background colour.
        loadingView.backgroundColor = UIColor.clearColor()
        
        // Add a blur view to the loading view.
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = loadingView.bounds
        loadingView.insertSubview(visualEffectView, atIndex: 0)
        
        // Turn the profile picture into a cirlce.
        self.userPicture.layer.cornerRadius = (self.userPicture.frame.size.width / 2)
        self.userPicture.clipsToBounds = true
        
        // Curve the edges of the loading view.
        self.loadingView.layer.cornerRadius = 12
        self.loadingView.clipsToBounds = true
        
        // By default the user hasn't made any edits.
        editSavedCheck = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        editToolbar.barStyle = UIBarStyle.Default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewDismissKeyboard")
        ]
        
        editToolbar.sizeToFit()
        userDescription.inputAccessoryView = editToolbar
        
        // Load in the current user data.
        loadCurrentData()
    }
    
    // View Did Layout Subviews method.
    
    override func viewDidLayoutSubviews() {
        
        // Calculate the appropriate scroll height.
        var scrollHeight: CGFloat = 0.0
        
        if (self.editScroll.bounds.height > 780) {
            scrollHeight = self.editScroll.bounds.height
        }
            
        else {
            scrollHeight = 780
        }
        
        // Setup the profile scroll view.
        self.editScroll.scrollEnabled = true
        self.editScroll.contentSize = CGSizeMake(self.view.bounds.width, scrollHeight)
    }
    
    // Data methods.
    
    func loadCurrentData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        changeUIAccess(false)
        
        // Setup the user object.
        var currentUser:PFUser!
        
        // Show the currently logged in user.
        currentUser = PFUser.currentUser()
        
        // Get the current user details.
        self.userFullName.text = currentUser?.objectForKey("fullName") as? String
        self.userDescription.text = currentUser?.objectForKey("userBio") as? String
        self.userEmail.text = currentUser?.objectForKey("email") as? String
        let lockCheck = currentUser?.objectForKey("privateProfile") as? Bool
        
        // Update the private profile switch.
        privateSwitch.setOn(lockCheck!, animated: true)
        
        // Update the description placeholder view.
        setPlaceholderAlpha()
        
        // Set the username label text.
        let userString = "\(currentUser.username!)"
        self.userName.text = userString as String
        
        // Check the website URL link.
        userWebsite.text = currentUser?.objectForKey("website") as? String
        
        // Check if the user has a profile image.
        
        if (currentUser.objectForKey("profileImage") == nil) {
            self.userPicture.image = UIImage(named: "default_profile_pic.png")
        }
            
        else {
            
            // Check for an image.
            let userImageFile = currentUser!["profileImage"] as! PFFile
            
            // Download the user image.
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        
                        // Set the downloaded profile image.
                        self.userPicture.image = profileImage
                    }
                        
                    else {
                        
                        // No profile picture set the standard image.
                        self.userPicture.image = UIImage(named: "default_profile_pic.png")
                    }
                }
                    
                else {
                    
                    // No profile picture set the standard image.
                    self.userPicture.image = UIImage(named: "default_profile_pic.png")
                }
            }
        }
        
        // Enable access to the UI and
        // hide the loading indicator view.
        changeUIAccess(true)
    }
    
    func checkData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        changeUIAccess(false)
        
        // Check if the user has made any profile
        // changes before attempting to save them.
        
        if (editSavedCheck == true) {
            
            // Enable access to the UI and
            // hide the loading indicator view.
            self.changeUIAccess(true)
            
            // No changes have bee made.
            self.displayAlert("Info", alertMessage: "You have made no changes to your profile information.")
        }
        
        else if (editSavedCheck == false) {
            
            // Error message strings.
            let errorStrings = ["Full Name", "Username", "Email Address", "Profile Description", "Website URL"]
            
            // Get the user updated data.
            let userData = [self.userFullName.text, self.userName.text, self.userEmail.text, self.userDescription.text, self.userWebsite.text]
            
            // Loop through the data and make sure it is valid.
            
            for (var loop = 0; loop < 5; loop++) {
                
                // Get the current string.
                let data = userData[loop]
                
                if (data == nil) {
                    
                    // Enable access to the UI and
                    // hide the loading indicator view.
                    changeUIAccess(true)
                    
                    // Create the error message.
                    let errorMessage = "Please ensure you have completed the '\(errorStrings[loop])' field before continuing."
                    
                    // Display the error alert.
                    displayAlert("Error", alertMessage: errorMessage)
                    
                    // Exit out of the for-loop/method.
                    return
                }
            }
            
            // Check the username to ensure that there
            // are no capital letters in the string.
            let capitalLetterRegEx  = ".*[A-Z]+.*"
            let textData = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
            let capitalresult = textData.evaluateWithObject(self.userName.text)
            
            if (capitalresult == true) {
                
                // Enable access to the UI and
                // hide the loading indicator view.
                changeUIAccess(true)
                
                // Alert the user that there are
                // capital letters in the username.
                self.displayAlert("Error", alertMessage: "Calendario usernames cannot include capital letters.")
            }
                
            else {
                
                // Check if the user has decided
                // to created a new password.
                
                if (userPassword.text != nil) {
                    
                    if (userReEnterPassword != nil) {
                        
                        if (userPassword.text == userReEnterPassword.text) {
                            
                            // The user profile changes are valid
                            // and can be uploaded to the Parse server.
                            uploadNewData()
                        }
                        
                        else {
                            
                            // Enable access to the UI and
                            // hide the loading indicator view.
                            changeUIAccess(true)
                            
                            // Display the password alert.
                            self.displayAlert("Error", alertMessage: "The 'Password' and 'Re-Enter Password' fields must match before your password can be changed.")
                        }
                    }
                    
                    else {
                        
                        // Enable access to the UI and
                        // hide the loading indicator view.
                        changeUIAccess(true)
                        
                        // Display the password alert.
                        self.displayAlert("Error", alertMessage: "The 'Password' and 'Re-Enter Password' fields must match before your password can be changed.")
                    }
                }
                
                else {
                    
                    // The user profile changes are valid
                    // and can be uploaded to the Parse server.
                    uploadNewData()
                }
            }
        }
    }
    
    func uploadNewData() {
        
        // Setup the Parse user object.
        var currentUser:PFUser!
        currentUser = PFUser.currentUser()
        
        // Set the user data in the Parse object.
        currentUser["fullName"] = self.userFullName.text
        currentUser["username"] = self.userName.text
        currentUser["email"] = self.userEmail.text
        currentUser["userBio"] = self.userDescription.text
        currentUser["website"] = self.userWebsite.text
        
        // Set the private profile property.
        
        if (privateSwitch.on == true) {
            currentUser["privateProfile"] = true
        }
        
        else {
            currentUser["privateProfile"] = false
        }
        
        // Store current username is NSUserDefults so it can be used later to follow a user.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(self.userName.text, forKey: "username")
        defaults.synchronize()
        
        // Set the user password if a new 
        // one has been created by the user.
        let passCheck = (userPassword.text)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if ((userPassword.hasText() == true) && (passCheck.characters.count > 0)) {
            currentUser.password = self.userPassword.text
        }
        
        // Only upload a profile picture if a
        // new picture has been set by the user.
        
        if (userSetImage == true) {
            
            // Add the profile image in the form of a
            // PFFile object to the update profile api request.
            let imageFile = PFFile(name: "prof.jpg", data: imageData!)
            currentUser["profileImage"] = imageFile
        }
        
        // Upload the changes to the Parse servers.
        currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
            
            // Enable access to the UI and
            // hide the loading indicator view.
            self.changeUIAccess(true)
            
            // Check if the data has been saved.
            
            if (success) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
                
            else {
                
                // Display the error alert.
                self.displayAlert("Error", alertMessage: "\(error?.description)")
            }
        }
    }
    
    // UI access methods.
    
    func changeUIAccess(mode : Bool) {
        
        // True means we should enable access to the UI
        // objects and false means we should disable access.
        userEmail.userInteractionEnabled = mode
        userName.userInteractionEnabled = mode
        userPassword.userInteractionEnabled = mode
        userReEnterPassword.userInteractionEnabled = mode
        userDescription.userInteractionEnabled = mode
        userFullName.userInteractionEnabled = mode
        userWebsite.userInteractionEnabled = mode
        editScroll.userInteractionEnabled = mode
        saveButton.enabled = mode
        backButton.enabled = mode
        
        // Show or hide the loading indicator views.
        
        if (mode == true) {
            
            loadingView.alpha = 0.0
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
            
        else if (mode == false) {
            
            loadingView.alpha = 1.0
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
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
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        // Dismiss the image picker view controller.
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            // New edits have been made.
            self.editSavedCheck = false
            
            // The user has set an image.
            self.userSetImage = true
            
            // Store the image for use in the registration.
            self.imageData = UIImageJPEGRepresentation(image, 1.0)
            
            // Set the profile picture view.
            self.userPicture.image = image
        })
    }
    
    func setPlaceholderAlpha() {
        
        if (self.userDescription.hasText()) {
            self.userDescriptionPlaceholder.alpha = 0.0
        }
            
        else {
            self.userDescriptionPlaceholder.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        editSavedCheck = false
        self.setPlaceholderAlpha()
    }
    
    func textViewDidChange(textView: UITextView) {
        
        editSavedCheck = false
        self.setPlaceholderAlpha()
    }
    
    func textViewDismissKeyboard() {
        
        editSavedCheck = false
        userDescription.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        editSavedCheck = false
        textField.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
