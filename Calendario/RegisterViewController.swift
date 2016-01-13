//
//  RegisterViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 14/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

/*

IMPORTANT NOTE

THIS CODE HAS NOT BEEN FINISHED YET. I AM WORKING
TO GET IT FINISHED IN MULTIPLE COMMITS. PLEASE LEAVE
IT ALONE UNLESS YOU ABSOLUTELY HAVE TO CHANGE SOMETHING.

THANKS - DANIEL SADJADIAN

*/

import UIKit
import Parse
import Photos
import QuartzCore

class RegisterViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Setup the data input text fields and other objects.
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var rePassField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var descFieldPlaceholder: UITextView!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var webField: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileScroll: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var privateSwitch: UISwitch!
    
    // Store the selected profile image data.
    var imageData : NSData!
    
    // Profile image set by user check.
    var userSetImage = false
    
    // Setup the on screen button actions.
    
    @IBAction func createUser(sender: UIButton) {
        
        // Check the entered data is present.
        checkData()
    }
    
    @IBAction func openTos(sender: UIButton) {
        
        // Open the register view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("tos") as! TosViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    @IBAction func openPrivacyPolicy(sender: UIButton) {
        
        // Open the register view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("privacypolicy") as! PrivacyPolicyViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    @IBAction func cancel(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Go back to the login page.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImage(sender: UIButton) {
    
        // Setup the image picker view controller.
        var imagePicker = UIImagePickerController()
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
            self.profilePicture.image = UIImage(named: "default_profile_pic.png")
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
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the loading view background colour.
        loadingView.backgroundColor = UIColor.clearColor()
        
        // Add a blur view to the loading view.
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = loadingView.bounds
        loadingView.insertSubview(visualEffectView, atIndex: 0)
        
        // Hide the loading view to beign with.
        self.loadingView.alpha = 0.0
        
        // Turn the profile picture into a cirlce.
        self.profilePicture.layer.cornerRadius = (self.profilePicture.frame.size.width / 2)
        self.profilePicture.clipsToBounds = true
        
        // Curve the edges of the loading view.
        self.loadingView.layer.cornerRadius = 12
        self.loadingView.clipsToBounds = true
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        editToolbar.barStyle = UIBarStyle.Default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewDismissKeyboard")
        ]
        
        editToolbar.sizeToFit()
        descField.inputAccessoryView = editToolbar
    }
    
    // View Did Layout Subviews method.
    
    override func viewDidLayoutSubviews() {
        
        // Calculate the appropriate scroll height.
        var scrollHeight: CGFloat = 0.0
        
        if (self.profileScroll.bounds.height > 880) {
            scrollHeight = self.profileScroll.bounds.height
        }
        
        else {
            scrollHeight = 880
        }
        
        // Setup the profile scroll view.
        self.profileScroll.scrollEnabled = true
        self.profileScroll.contentSize = CGSizeMake(self.view.bounds.width, scrollHeight)
    }
    
    // Data check methods.
    
    func checkData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        changeUIAccess(false)
        
        // Get the relevant user data.
        let userData = [self.emailField.text, self.userField.text, self.passField.text, self.rePassField.text, self.descField.text, self.fullNameField.text]
        
        // Setup the errors array.
        let errorStrings: [String] = ["email", "username", "password", "re-enter password", "description", "full name"]
        
        for (var loop = 0; loop < 6; loop++) {
            
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
        let capitalresult = textData.evaluateWithObject(self.userField.text)
        
        if (capitalresult == true) {
            
            // Enable access to the UI and
            // hide the loading indicator view.
            changeUIAccess(true)
            
            // Alert the user that there are 
            // capital letters in the username.
            self.displayAlert("Error", alertMessage: "Calendario usernames cannot include capital letters.")
        }
        
        else {
            
            // Notify the user that the app is loading.
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            // The data meets all the requirements
            // go on to the actual registration.
            registerUser()
        }
    }
    
    // Create user method.
    
    func registerUser() {
        
        // Get the relevat data.
        let email = self.emailField.text
        let username = self.userField.text
        let password = self.passField.text
        
        // Setup the new user details.
        var newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        // Set the other user data fields.
        newUser["userBio"] = self.descField.text
        newUser["website"] = self.webField.text
        newUser["fullName"] = self.fullNameField.text
        
        // Set the private profile property.
        
        if (privateSwitch.on == true) {
            newUser["privateProfile"] = true
        }
            
        else {
            newUser["privateProfile"] = false
        }
        
        // Set the user profile picture if one has been 
        // set otherwise upload the standard profile picture.
        
        if (userSetImage == false) {
            
            if (self.imageData == nil) {
                self.imageData = UIImageJPEGRepresentation(UIImage(named: "default_profile_pic.png")!, 1.0)
            }
        }
        
        // Add the profile image in the form of a 
        // PFFile object to the sign up api request.
        let imageFile = PFFile(name: "prof.jpg", data: imageData!)
        newUser["profileImage"] = imageFile
    
        // Pass the details to the Parse API.
        newUser.signUpInBackgroundWithBlock { (succed, error) -> Void in
            
            // Run the alert code on the main thread.
            dispatch_async(dispatch_get_main_queue(),{
                
                // Notify the user that the app has stopped loading.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if (error != nil) {
                    
                    // Enable access to the UI and
                    // hide the loading indicator view.
                    self.changeUIAccess(true)
                    
                    // Display the error message.
                    self.displayAlert("Error", alertMessage: "\(error)")
                }
                    
                else {
                    
                    // Create the user entry in the
                    // FollowersAndFollowing Parse class.
                    var userFollowData:PFObject!
                    userFollowData = PFObject(className:"FollowersAndFollowing")
                    userFollowData["userFollowing"] = []
                    userFollowData["userFollowers"] = []
                    userFollowData["userLink"] = PFUser.currentUser()
                    
                    // Save the follow data on Parse.
                    userFollowData.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        
                        // Create the user entry in the
                        // userNotifications Parse class.
                        var userNotificationData:PFObject!
                        userNotificationData = PFObject(className:"userNotifications")
                        userNotificationData["fromUser"] = []
                        userNotificationData["notificationStrings"] = []
                        userNotificationData["userLink"] = PFUser.currentUser()
                        
                        // Save the notification data on Parse.
                        userNotificationData.saveInBackgroundWithBlock({ (notificationSuccess, notificationError) -> Void in
                            
                            if (notificationSuccess) {
                                
                                // Hide the loading indicator view.
                                self.loadingView.alpha = 0.0
                                
                                // Setup the alert controller.
                                let registerAlert = UIAlertController(title: "Welcome to Calendario", message: "You have successfully created a Calendario account.", preferredStyle: .Alert)
                                
                                // Setup the alert actions.
                                let nextHandler = { (action:UIAlertAction!) -> Void in
                                    self.GotoNewsfeed()
                                }
                                let next = UIAlertAction(title: "Continue", style: .Default, handler: nextHandler)
                                
                                // Add the actions to the alert.
                                registerAlert.addAction(next)
                                
                                // Present the alert on screen.
                                self.presentViewController(registerAlert, animated: true, completion: nil)
                            }
                                
                            else {
                                
                                // An error has occured.
                                self.displayAlert("Error", alertMessage: "\(notificationError)")
                            }
                        })
                    }
                }
            })
        }
    }
    
    // News feed methods.
    
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
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
            
            // The user has set an image.
            self.userSetImage = true
            
            // Store the image for use in the registration.
            self.imageData = UIImageJPEGRepresentation(image, 1.0)
            
            // Set the profile picture view.
            self.profilePicture.image = image
        })
    }
    
    func setPlaceholderAlpha() {
        
        if (self.descField.hasText()) {
            self.descFieldPlaceholder.alpha = 0.0
        }
            
        else {
            self.descFieldPlaceholder.alpha = 1.0
        }
    }
    
    func changeUIAccess(mode : Bool) {
        
        // True means we should enable access to the UI
        // objects and false means we should disable access.
        emailField.userInteractionEnabled = mode
        userField.userInteractionEnabled = mode
        passField.userInteractionEnabled = mode
        rePassField.userInteractionEnabled = mode
        descField.userInteractionEnabled = mode
        fullNameField.userInteractionEnabled = mode
        webField.userInteractionEnabled = mode
        profileScroll.userInteractionEnabled = mode
        backButton.enabled = mode
        privacyPolicyButton.userInteractionEnabled = mode
        tosButton.userInteractionEnabled = mode
        submitButton.userInteractionEnabled = mode
        
        // Show or hide the loading indicator view.
        
        if (mode == true) {
            loadingView.alpha = 0.0
        }
        
        else if (mode == false) {
            loadingView.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.setPlaceholderAlpha()
    }
    
    func textViewDidChange(textView: UITextView) {
        self.setPlaceholderAlpha()
    }
    
    func textViewDismissKeyboard() {
        descField.resignFirstResponder()
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