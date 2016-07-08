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
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileScroll: UIScrollView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var emailIconImageView: UIImageView!
    @IBOutlet weak var usernameIconImageView: UIImageView!
    @IBOutlet weak var passwordIconImageView: UIImageView!
    @IBOutlet weak var reEnterPasswordIconImageView: UIImageView!
    @IBOutlet weak var fullNameIconImageView: UIImageView!
    
    var usernameLowerCase: String = ""
    
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
        PresentingViews.ViewTermsOfService(self)
    }
    
    @IBAction func openPrivacyPolicy(sender: UIButton) {
        PresentingViews.ViewPrivacyPolicy(self)
    }
    
    @IBAction func cancel(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Go back to the login page.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addImage(sender: UIButton) {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setIconRenderingModes()
        setIconColors()
    }
    
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
    
    private func setupUI() {
        // Set the loading view background colour.
        loadingView.backgroundColor = UIColor.clearColor()
        
        // Add a blur view to the loading view.
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
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
    }
    
    private func setIconRenderingModes() {
        usernameIconImageView.image? = (usernameIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate))!
        emailIconImageView.image? = (emailIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate))!
        passwordIconImageView.image? = (passwordIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate))!
        reEnterPasswordIconImageView.image? = (reEnterPasswordIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate))!
        fullNameIconImageView.image? = (fullNameIconImageView.image?.imageWithRenderingMode(.AlwaysTemplate))!
        profilePicture.image? = (profilePicture.image?.imageWithRenderingMode(.AlwaysTemplate))!
    }
    
    private func setIconColors() {
        usernameIconImageView.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        emailIconImageView.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        passwordIconImageView.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        reEnterPasswordIconImageView.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        fullNameIconImageView.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
        profilePicture.tintColor = UIColor(red: 163/255.0, green: 163/255.0, blue: 163/255.0, alpha: 1.0)
    }
    
    // Data check methods.
    
    func checkData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        changeUIAccess(false)
        
        // Get the relevant user data.
        let userData = [self.emailField.text, self.userField.text?.lowercaseString, self.passField.text, self.rePassField.text, self.fullNameField.text]
        
        // Setup the errors array.
        let errorStrings: [String] = ["email", "username", "password", "re-enter password", "full name"]
        
        for loop in 0..<userData.count {
            
            // Get the current string.
            let data = userData[loop]

            // Setup the data string check.
            let dataCheck: String = data!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            // Ensure the string is not nill and
            // actually contains multiple characters.
            
            if ((data == nil) || (dataCheck.characters.count <= 0)) {
                
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
            self.displayAlert("Error", alertMessage: "Calendario usernames must not include capital letters.")
        }
        
        else {
            
            // Check the username to make sure it only
            // contains dots, underscores, letters and numbers.
            var allowedSet: NSMutableCharacterSet!
            allowedSet = NSMutableCharacterSet(charactersInString: "._")
            allowedSet.formUnionWithCharacterSet(NSCharacterSet.alphanumericCharacterSet())
            let forbiddenSet: NSCharacterSet = allowedSet.invertedSet
            let r: NSRange = (self.userField.text! as NSString).rangeOfCharacterFromSet(forbiddenSet)
            
            // Check the username against the character set.
            
            if (r.location != NSNotFound) {
                
                // Enable access to the UI and
                // hide the loading indicator view.
                changeUIAccess(true)
                
                // Alert the user that there are
                // illegal characters in the username.
                self.displayAlert("Error", alertMessage: "Calendario usernames must only contain lower case letters, numbers, dots and underscore characters.")
            }
            
            else {
                
                // Setup the terms and conditions reminder alert.
                let alertController = UIAlertController(title: "Terms of Service", message: "In order to use this service, you must first accept the Terms of Service.", preferredStyle: .ActionSheet)
                
                // Setup the alert actions.
                let termsHandler = { (action:UIAlertAction!) -> Void in
                    
                    // Enable access to the UI and
                    // hide the loading indicator view.
                    self.changeUIAccess(true)
                    
                    // Show the Terms and Conditions view.
                    PresentingViews.ViewTermsOfService(self)
                }
                let viewTandCs = UIAlertAction(title: "View Terms of Service", style: .Default, handler: termsHandler)
                
                let continueHandler = { (action:UIAlertAction!) -> Void in
                    
                    // The data meets all the requirements
                    // go on to the actual registration.
                    self.registerUser()
                }
                let accept = UIAlertAction(title: "Accept and Continue", style: .Default, handler: continueHandler)
                
                let cancelHandler = { (action:UIAlertAction!) -> Void in
                    
                    // Enable access to the UI and
                    // hide the loading indicator view.
                    self.changeUIAccess(true)
                }
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: cancelHandler)
                
                alertController.addAction(viewTandCs)
                alertController.addAction(accept)
                alertController.addAction(cancel)
                
                // Present the alert on screen.
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // Create user method.
    
    func registerUser() {
        
        // Get the relevat data.
        let email = self.emailField.text
        let username = self.userField.text?.lowercaseString
        let password = self.passField.text
        
        // Setup the new user details.
        var newUser:PFUser!
        newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        // Set the other user data fields.
        newUser["userBio"] = ""
        newUser["website"] = ""
        newUser["fullName"] = self.fullNameField.text
        newUser["privateProfile"] = false
        
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
                        userNotificationData["extLink"] = []
                        userNotificationData["userLink"] = PFUser.currentUser()
                        
                        // Save the notification data on Parse.
                        userNotificationData.saveInBackgroundWithBlock({ (notificationSuccess, notificationError) -> Void in
                            
                            if (notificationSuccess) {
                                
                                // Hide the loading indicator view.
                                self.loadingView.alpha = 0.0
                                
                                // Show the news feed.
                                self.checkRecommendationsStatus()
                                PresentingViews.presentNewsFeed(self)
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
    
    private func checkRecommendationsStatus() {
        // Ensure that the recomendations view is shown.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(true, forKey: "recoCheck")
        defaults.synchronize()
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
    
    func changeUIAccess(mode : Bool) {
        
        // True means we should enable access to the UI
        // objects and false means we should disable access.
        emailField.userInteractionEnabled = mode
        userField.userInteractionEnabled = mode
        passField.userInteractionEnabled = mode
        rePassField.userInteractionEnabled = mode
        fullNameField.userInteractionEnabled = mode
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
    
    // Force lowercase textfields.
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField == self.userField {
            self.userField.text = self.userField.text?.lowercaseString
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
