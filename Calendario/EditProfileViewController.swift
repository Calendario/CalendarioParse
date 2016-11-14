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
    @IBOutlet weak var userBackgroundPicture: UIImageView!
    @IBOutlet weak var userFullName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userDescription: UITextView!
    @IBOutlet weak var userDescriptionPlaceholder: UITextView!
    @IBOutlet weak var userWebsite: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var userReEnterPassword: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerTable: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var privateSwitch: UISwitch!
    
    // Store the selected profile image data.
    var imageData : Data!
    
    // Store the selected profile background data.
    var imageBackgroundData : Data!
    
    // Profile image set by user check.
    var userSetImage = false
    
    // Profile background image set by user check.
    var userBackgroundSetImage = false
    
    // Current image mode check.
    var currentImageMode = true
    
    // Unsaved changes check.
    var editSavedCheck : Bool!
    
    // Scroll movement data.
    var currentlyEditing:Bool = false
    
    // Setup the on screen button actions.
    
    @IBAction func saveEdit(_ sender: UIButton) {
        
        // Check the data before saving it.
        checkData()
    }
    
    @IBAction func editPicture(_ sender: UIButton) {
        
        // Setup the alert controller.
        let choiceAlert = UIAlertController(title: "Edit Profile", message: "Would you like to edit your profile picture or background picture?", preferredStyle: .actionSheet)
        
        // Setup the alert actions.
        let editProfilePicture = { (action:UIAlertAction!) -> Void in
            self.setUserPicture(mode: true, inputTitle: "Profile Picture")
        }
        let selectProfile = UIAlertAction(title: "Profile Picture", style: .default, handler: editProfilePicture)
        
        let editBackgroundPicture = { (action:UIAlertAction!) -> Void in
            self.setUserPicture(mode: false, inputTitle: "Background Picture")
        }
        let selectBackground = UIAlertAction(title: "Background Picture", style: .default, handler: editBackgroundPicture)
        
        let cancel = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        choiceAlert.addAction(selectBackground)
        choiceAlert.addAction(selectProfile)
        choiceAlert.addAction(cancel)
        
        // Present the alert on screen.
        present(choiceAlert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Enable access to the UI and
        // hide the loading indicator view.
        self.changeUIAccess(true)
        
        // Check if the user has saved their edits.
        
        if (editSavedCheck == true) {
            self.dismiss(animated: true, completion: nil)
        }
        
        else if (editSavedCheck == false) {
            
            // Setup the alert controller.
            let exitAlert = UIAlertController(title: "Unsaved changes", message: "Are you sure you want to go back? Your new changes have not been saved.", preferredStyle: .alert)
            
            // Exit alert action buttons.
            let ok = { (action:UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            let buttonOne = UIAlertAction(title: "Exit without saving changes", style: .destructive, handler: ok)
            
            let cancel = { (action:UIAlertAction!) -> Void in
            }
            let buttonTwo = UIAlertAction(title: "Cancel", style: .default, handler: cancel)
            
            // Add the actions to the alert.
            exitAlert.addAction(buttonOne)
            exitAlert.addAction(buttonTwo)
            
            // Present the alert on screen.
            self.present(exitAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchChangeState(_ sender: UISwitch) {
        editSavedCheck = false
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the loading view background colour.
        loadingView.backgroundColor = UIColor.clear
        
        // Add a blur view to the loading view.
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)) as UIVisualEffectView
        visualEffectView.frame = loadingView.bounds
        loadingView.insertSubview(visualEffectView, at: 0)
        
        // Turn the profile picture into a cirlce.
        self.userPicture.layer.cornerRadius = (self.userPicture.frame.size.width / 2)
        self.userPicture.clipsToBounds = true
        
        // Curve the edges of the loading view.
        self.loadingView.layer.cornerRadius = 12
        self.loadingView.clipsToBounds = true
        
        // Esnure the background picture crops.
        self.userBackgroundPicture.clipsToBounds = true
        
        // Set tha table view header view.
        self.containerTable.tableHeaderView = self.containerView
        
        // By default the user hasn't made any edits.
        editSavedCheck = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        editToolbar.barStyle = UIBarStyle.default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditProfileViewController.textViewDismissKeyboard))
        ]
        
        editToolbar.sizeToFit()
        userDescription.inputAccessoryView = editToolbar
        
        // Load in the current user data.
        loadCurrentData()
    }
    
    // View Did Layout Subviews method.
    
    override func viewDidLayoutSubviews() {
    }
    
    // Data methods.
    
    func setUserPicture(mode: Bool, inputTitle: String) {
        
        // Set the current image mode.
        self.currentImageMode = mode
        
        // Setup the image picker view controller.
        var imagePicker:UIImagePickerController!
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Setup the alert controller.
        let imageAlert = UIAlertController(title: inputTitle, message: "Add a photo from your library or take a picture with the camera.", preferredStyle: .actionSheet)
        
        // Photo library action button.
        let libraryPicture = { (action:UIAlertAction!) -> Void in
            
            // Check if the device has a photo library.
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
                
                // Access the photo library (not the camera).
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                
                // Request photo library authorisation.
                let check = PHPhotoLibrary.authorizationStatus()
                
                // Check to see what the users response if.
                
                if (check == PHAuthorizationStatus.authorized) {
                    self.present(imagePicker, animated: true, completion: nil)
                }
                    
                else if ((check == PHAuthorizationStatus.notDetermined) || (check == PHAuthorizationStatus.denied)) {
                    
                    // Request library authorisation.
                    PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                        
                        // Check to see if access has been granted.
                        
                        if (status == PHAuthorizationStatus.authorized) {
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                            
                        else {
                            self.displayAlert("Error", alertMessage: "You have not granted access to your photo library.")
                        }
                    })
                }
                    
                else if (check == PHAuthorizationStatus.restricted) {
                    self.displayAlert("Error", alertMessage: "You have not granted access to your photo library.")
                }
            }
                
            else {
                self.displayAlert("Error", alertMessage: "Your device does not have a photo library")
            }
        }
        let buttonOne = UIAlertAction(title: "Library", style: .default, handler: libraryPicture)
        
        // Take a picture button.
        let cameraPicture = { (action:UIAlertAction!) -> Void in
            
            // Check if the device has a camera.
            
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
                
                // Access the camera (not the photo library).
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                
                // Request access to the camera.
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (success) -> Void in
                    
                    if (success) {
                        self.present(imagePicker, animated: true, completion: nil)
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
        let buttonTwo = UIAlertAction(title: "Camera", style: .default, handler: cameraPicture)
        
        // Set to default picture button.
        let defaultPicture = { (action:UIAlertAction!) -> Void in
            
            // Check if we are editing the profile
            // picture or the background picture.
            
            if (mode == true) {
                
                // The user has not set an image.
                self.userSetImage = false
                
                // Set the image data to the default image.
                self.imageData = UIImageJPEGRepresentation(UIImage(named: "default_profile_pic.png")!, 1.0)
                
                // Set the profile picture to the default image.
                self.userPicture.image = UIImage(named: "default_profile_pic.png")
            }
            
            else {
                
                // The user has not set a background image.
                self.userBackgroundSetImage = false
                
                // Set the image data to clear.
                self.imageBackgroundData = nil
                
                // Set the background picture to clear.
                self.userBackgroundPicture.image = nil
            }
        }
        let buttonThree = UIAlertAction(title: "Reset picture", style: .default, handler: defaultPicture)
        
        // Cancel button.
        let buttonFour = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert.
        imageAlert.addAction(buttonOne)
        imageAlert.addAction(buttonTwo)
        
        if (mode == true) {
            
            if (self.userSetImage == true) {
                imageAlert.addAction(buttonThree)
            }
            
        } else {
            
            if (self.userBackgroundSetImage == true) {
                imageAlert.addAction(buttonThree)
            }
        }
        
        imageAlert.addAction(buttonFour)
        
        // Present the alert on screen.
        self.present(imageAlert, animated: true, completion: nil)
    }
    
    func loadCurrentData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        changeUIAccess(false)
        
        // Setup the user object.
        var currentUser:PFUser!
        
        // Show the currently logged in user.
        currentUser = PFUser.current()
        
        // Get the current user details.
        self.userFullName.text = currentUser?.object(forKey: "fullName") as? String
        self.userDescription.text = currentUser?.object(forKey: "userBio") as? String
        self.userEmail.text = currentUser?.object(forKey: "email") as? String
        let lockCheck = currentUser?.object(forKey: "privateProfile") as? Bool
        
        // Update the private profile switch.
        privateSwitch.setOn(lockCheck!, animated: true)
        
        // Update the description placeholder view.
        setPlaceholderAlpha()
        
        // Set the username label text.
        let userString = "\(currentUser.username!)"
        self.userName.text = userString as String
        
        // Check the website URL link.
        userWebsite.text = currentUser?.object(forKey: "website") as? String
        
        // Check if the user has a background picture.
        
        if (currentUser.object(forKey: "backgroundImage") != nil) {
            
            let userImageFile = currentUser["backgroundImage"] as! PFFile
            userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileBackgroundImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileBackgroundImage != nil)) {
                        self.userBackgroundPicture.image = profileBackgroundImage
                    }
                }
            })
        }
            
        else {
            self.userBackgroundPicture.image = nil
        }
        
        // Check if the user has a profile image.
        
        if (currentUser.object(forKey: "profileImage") == nil) {
            self.userPicture.image = UIImage(named: "default_profile_pic.png")
        }
            
        else {
            
            // Check for an image.
            let userImageFile = currentUser!["profileImage"] as! PFFile
            
            // Download the user image.
            userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                
                if (error == nil) {
                    
                    // Check the profile image data first.
                    let profileImage = UIImage(data:imageData!)
                    
                    if ((imageData != nil) && (profileImage != nil)) {
                        self.userPicture.image = profileImage
                    } else {
                        self.userPicture.image = UIImage(named: "default_profile_pic.png")
                    }
                } else {
                    self.userPicture.image = UIImage(named: "default_profile_pic.png")
                }
            })
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
            
            for loop in 0..<5 {
                
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
            let capitalresult = textData.evaluate(with: self.userName.text)
            
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
        currentUser = PFUser.current()
        
        // Set the user data in the Parse object.
        currentUser["fullName"] = self.userFullName.text
        currentUser["username"] = self.userName.text
        currentUser["email"] = self.userEmail.text
        currentUser["userBio"] = self.userDescription.text
        currentUser["website"] = self.userWebsite.text
        
        // Set the private profile property.
        
        if (privateSwitch.isOn == true) {
            currentUser["privateProfile"] = true
        }
        
        else {
            currentUser["privateProfile"] = false
        }
        
        // Store current username is NSUserDefults so it can be used later to follow a user.
        let defaults = UserDefaults.standard
        defaults.set(self.userName.text, forKey: "username")
        defaults.synchronize()
        
        // Set the user password if a new 
        // one has been created by the user.
        let passCheck = (userPassword.text)!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if ((userPassword.hasText == true) && (passCheck.characters.count > 0)) {
            currentUser.password = self.userPassword.text
        }
        
        // Only upload a profile picture if a
        // new picture has been set by the user.
        
        if (self.userSetImage == true) {
            
            // Add the profile image in the form of a
            // PFFile object to the update profile api request.
            let imageFile = PFFile(name: "prof.jpg", data: imageData!)
            currentUser["profileImage"] = imageFile
        }
        
        // Only upload a profile background picture
        // if a new picture has been set by the user.
        
        if (self.userBackgroundSetImage == true) {
            
            // Add the profile image in the form of a
            // PFFile object to the update profile api request.
            let imageFile = PFFile(name: "profBackground.jpg", data: imageBackgroundData!)
            currentUser["backgroundImage"] = imageFile
        }
        
        // Upload the changes to the Parse servers.
        currentUser.saveInBackground { (success, error) -> Void in
            
            // Enable access to the UI and
            // hide the loading indicator view.
            self.changeUIAccess(true)
            
            // Check if the data has been saved.
            
            if (success) {
                self.dismiss(animated: true, completion: nil)
            }
                
            else {
                
                // Display the error alert.
                self.displayAlert("Error", alertMessage: "\(error?.localizedDescription)")
            }
        }
    }
    
    // UI access methods.
    
    func changeUIAccess(_ mode : Bool) {
        
        // True means we should enable access to the UI
        // objects and false means we should disable access.
        self.userEmail.isUserInteractionEnabled = mode
        self.userName.isUserInteractionEnabled = mode
        self.userPassword.isUserInteractionEnabled = mode
        self.userReEnterPassword.isUserInteractionEnabled = mode
        self.userDescription.isUserInteractionEnabled = mode
        self.userFullName.isUserInteractionEnabled = mode
        self.userWebsite.isUserInteractionEnabled = mode
        self.containerView.isUserInteractionEnabled = mode
        self.saveButton.isEnabled = mode
        self.backButton.isEnabled = mode
        
        // Show or hide the loading indicator views.
        
        if (mode == true) {
            
            loadingView.alpha = 0.0
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
            
        else if (mode == false) {
            
            loadingView.alpha = 1.0
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Dismiss the keyboard.
        self.currentlyEditing = false
        self.view.resignFirstResponder()
    }
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        // Dismiss the image picker view controller.
        self.dismiss(animated: true, completion: { () -> Void in
            
            // New edits have been made.
            self.editSavedCheck = false
            
            // Set the user profile or background
            // picture depending on the current mode.
            
            if (self.currentImageMode == true) {
                
                // The user has set an image.
                self.userSetImage = true
                
                // Store the image for use in the registration.
                self.imageData = UIImageJPEGRepresentation(image, 1.0)
                
                // Set the profile picture view.
                self.userPicture.image = image
            }
            
            else {
                
                // The user has set an image.
                self.userBackgroundSetImage = true
                
                // Store the image for use in the registration.
                self.imageBackgroundData = UIImageJPEGRepresentation(image, 1.0)
                
                // Set the profile background picture view.
                self.userBackgroundPicture.image = image
            }
        })
    }
    
    func setPlaceholderAlpha() {
        
        if (self.userDescription.hasText) {
            self.userDescriptionPlaceholder.alpha = 0.0
        }
            
        else {
            self.userDescriptionPlaceholder.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        self.editSavedCheck = false
        self.currentlyEditing = false
        self.setPlaceholderAlpha()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.editSavedCheck = false
        self.currentlyEditing = false
        self.setPlaceholderAlpha()
    }
    
    func textViewDismissKeyboard() {
        
        self.editSavedCheck = false
        self.currentlyEditing = false
        self.userDescription.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Set the current edit state.
        self.currentlyEditing = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.editSavedCheck = false
        self.currentlyEditing = false
        textField.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
