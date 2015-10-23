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

class RegisterViewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    // Store the selected profile image data.
    var imageData : NSData!
    
    // Setup the on screen button actions.
    
    @IBAction func createUser(sender: UIButton) {
        
        // Check the entered data is present.
        checkData()
    }
    
    @IBAction func cancel(sender: UIButton) {
        
        // Go back to the login page.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("LoginPage") as! LoginViewViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    @IBAction func addImage(sender: UIButton) {
    
        // Setup the image picker view controller.
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        // Setup the alert controller.
        let imageAlert = UIAlertController(title: "Profile Picture", message: "Add a photo from your library or take a picture with the camera.", preferredStyle: .Alert)
        
        // Setup the alert actions.
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
                            self.displayError("Error", alertMessage: "You have not granted access to your photo library.")
                        }
                    })
                }
                
                else if (check == PHAuthorizationStatus.Restricted) {
                    self.displayError("Error", alertMessage: "You have not granted access to your photo library.")
                }
            }
            
            else {
                self.displayError("Error", alertMessage: "Your device does not have a photo library")
            }
        }
        let buttonOne = UIAlertAction(title: "Library", style: .Default, handler: libraryPicture)
        
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
                        self.displayError("Error", alertMessage: "You have not granted access to your camera.")
                    }
                })
            }
            
            else {
                self.displayError("Error", alertMessage: "Your device does not have a camera.")
            }
        }
        let buttonTwo = UIAlertAction(title: "Camera", style: .Default, handler: cameraPicture)
        
        // Add the actions to the alert.
        imageAlert.addAction(buttonOne)
        imageAlert.addAction(buttonTwo)
        
        // Present the alert on screen.
        self.presentViewController(imageAlert, animated: true, completion: nil)
    }
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Turn the profile picture into a cirlce.
        self.profilePicture.layer.cornerRadius = (self.profilePicture.frame.size.width / 2)
        self.profilePicture.clipsToBounds = true
        
        // Setup the scroll view.
        profileScroll.scrollEnabled = true
        profileScroll.contentSize = CGSize(width:self.view.bounds.width, height: 880)
        
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
    
    // Data check methods.
    
    func checkData() {
        
        // Get the relevant user data.
        let userData = [self.emailField.text, self.userField.text, self.passField.text, self.rePassField.text, self.descField.text, self.fullNameField.text]
        
        // Setup the errors array.
        let errorStrings: [String] = ["Email", "Username", "Password", "Re-Enter Password", "Description", "Full name"]
        
        for (var loop = 0; loop < 6; loop++) {
            
            // Get the current string.
            let data = userData[loop]
            
            if (data == nil) {
                
                // Create the error message.
                let errorMessage = "Please ensure you have completed the \(errorStrings[loop]) field before continuing."
                
                // Display the error alert.
                displayError("Error", alertMessage: errorMessage)
                
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
            
            // Alert the user that there are 
            // capital letters in the username.
            self.displayError("Error", alertMessage: "Calendario usernames cannot include capital letters.")
        }
        
        else {
            
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
        
        // Set the user profile picture if
        // one has been set buy the user.
        
        if (imageData != nil) {
            
            let imageFile = PFFile(name: "prof.jpg", data: imageData!)
            newUser["profileImage"] = imageFile
        }
        
        // Pass the details to the Parse API.
        newUser.signUpInBackgroundWithBlock { (succed, error) -> Void in
            
            // Run the alert code on the main thread.
            dispatch_async(dispatch_get_main_queue(),{
                
                if (error != nil) {
                    self.displayError("Error", alertMessage: "\(error)")
                }
                    
                else {
                    
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
    
    func displayError(alertTitle: String, alertMessage: String) {
        
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