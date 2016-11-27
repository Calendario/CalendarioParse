//
//  AllInOneSignUpAndLoginViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 24/08/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse
import Photos
import QuartzCore

class AllInOneSignUpAndLoginViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    //MARK: UI OBJECTS.
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var profilePictureButton: UIButton!
    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var userFullNameField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var alreadyAccountButton: UIButton!
    @IBOutlet weak var blockViewOne: UIView!
    @IBOutlet weak var blockViewTwo: UIView!
    @IBOutlet weak var blockViewThree: UIView!
    @IBOutlet weak var blockViewFour: UIView!
    @IBOutlet weak var blockViewFive: UIView!
    @IBOutlet weak var blockViewSix: UIView!
    @IBOutlet weak var signUpUserButton: UIButton!
    @IBOutlet weak var agreementLabelOne: UILabel!
    @IBOutlet weak var resetPassButton: UIButton!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var ppButton: UIButton!
    
    //MARK: DATA OBJECTS.
    var displayState:Bool = false
    var blockViews = [] as NSArray
    var imageData : Data!
    var userSetImage = false
    var scrollHeightIncrease:Array <CGFloat> = []
    var bigScreenCheck:Bool = false
    var currentlyEditing:Bool = false
    internal var transitionType:Bool = false
    
    //MARK: BUTTONS.
    
    @IBAction func setProfilePicture(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Setup the image picker view controller.
        var imagePicker:UIImagePickerController!
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // Setup the alert controller.
        let imageAlert = UIAlertController(title: "Profile Picture", message: "Add a photo from your library or take a picture with the camera.", preferredStyle: .actionSheet)
        
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
            
            // The user has not set an image.
            self.userSetImage = false
            
            // Set the image data to the default image.
            self.imageData = UIImageJPEGRepresentation(UIImage(named: "default_profile_pic.png")!, 1.0)
            
            // Set the profile picture to the default image.
            self.profilePictureButton.setImage(UIImage(named: "camera_icon.png"), for: UIControlState())
        }
        let buttonThree = UIAlertAction(title: "Remove picture", style: .destructive, handler: defaultPicture)
        
        // Cancel button.
        let buttonFour = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add the actions to the alert.
        imageAlert.addAction(buttonOne)
        imageAlert.addAction(buttonTwo)
        
        if (userSetImage == true) {
            imageAlert.addAction(buttonThree)
        }
        
        imageAlert.addAction(buttonFour)
        
        // Present the alert on screen.
        self.present(imageAlert, animated: true, completion: nil)
    }
    
    @IBAction func registerUserDetails(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()

        // Check the inputted data.
        self.checkUserData()
    }
    
    @IBAction func viewPrivacyPolicy(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()

        // Show the privacy policy view.
        PresentingViews.ViewPrivacyPolicy(self)
    }
    
    @IBAction func viewToS(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()

        // Show the ToS view.
        PresentingViews.ViewTermsOfService(self)
    }
    
    @IBAction func loginWithExistingAccount(_ sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Update the UI appropriately.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
        
            // Clear the text fields.
            self.userFullNameField.text = nil
            self.userNameField.text = nil
            self.passwordField.text = nil
            self.emailField.text = nil
            
            // Reset the profile image button.
            self.profilePictureButton.setImage(UIImage(named: "camera_icon.png"), for: UIControlState())
            
            // Perform the correct UI animations
            // depending on the current display state.
            
            if (self.displayState == true) {
                
                // Set the agreement label.
                self.agreementLabelOne.text = "By signing up you have agreed to the"
                
                // Set the top label.
                self.topLabel.text = "SIGN UP"
                
                // Set the sign up button text.
                self.signUpUserButton.setTitle("Sign up", for: UIControlState())
                
                // Set the existing button text.
                self.alreadyAccountButton.setTitle("Already have an account? Login.", for: UIControlState())
                
                // Move the appropriate block views down.
                (self.blockViews[1] as! UIView).frame = (self.blockViews[1] as! UIView).frame.offsetBy(dx: 0, dy: 62.0)
                (self.blockViews[2] as! UIView).frame = (self.blockViews[2] as! UIView).frame.offsetBy(dx: 0, dy: 62.0)
                (self.blockViews[4] as! UIView).frame = (self.blockViews[4] as! UIView).frame.offsetBy(dx: 0, dy: 62.0)
                (self.blockViews[5] as! UIView).frame = (self.blockViews[5] as! UIView).frame.offsetBy(dx: 0, dy: 62.0)
                
                // Move the top section block up.
                (self.blockViews[7] as! UIView).frame = (self.blockViews[7] as! UIView).frame.offsetBy(dx: 0, dy: -11.0)
                
                // Show the appropriate block views.
                (self.blockViews[0] as! UIView).alpha = 1.0
                (self.blockViews[3] as! UIView).alpha = 1.0
                
                // Show the profile photo button.
                self.profilePictureButton.alpha = 1.0
                
                // Hide the reset button.
                (self.blockViews[6] as! UIView).alpha = 0.0
                
                // Set the keyboard return button to 'Next'.
                self.passwordField.returnKeyType = .next
                
            } else {
                
                // Set the agreement label.
                self.agreementLabelOne.text = "By signing in you have agreed to the"
                
                // Set the top label.
                self.topLabel.text = "SIGN IN"
                
                // Set the sign up button text.
                self.signUpUserButton.setTitle("Sign in", for: UIControlState())
                
                // Set the existing button text.
                self.alreadyAccountButton.setTitle("Create a new account.", for: UIControlState())
                
                // Move the appropriate block views up.
                (self.blockViews[1] as! UIView).frame = (self.blockViews[1] as! UIView).frame.offsetBy(dx: 0, dy: -62.0)
                (self.blockViews[2] as! UIView).frame = (self.blockViews[2] as! UIView).frame.offsetBy(dx: 0, dy: -62.0)
                (self.blockViews[4] as! UIView).frame = (self.blockViews[4] as! UIView).frame.offsetBy(dx: 0, dy: -62.0)
                (self.blockViews[5] as! UIView).frame = (self.blockViews[5] as! UIView).frame.offsetBy(dx: 0, dy: -62.0)
                
                // Move the top section block down.
                (self.blockViews[7] as! UIView).frame = (self.blockViews[7] as! UIView).frame.offsetBy(dx: 0, dy: 11.0)
                
                // Hide the appropriate block views.
                (self.blockViews[0] as! UIView).alpha = 0.0
                (self.blockViews[3] as! UIView).alpha = 0.0
                
                // Hide the profile photo button.
                self.profilePictureButton.alpha = 0.0
                
                // Show the reset button.
                (self.blockViews[6] as! UIView).alpha = 1.0
                
                // Set the keyboard return button to 'Done'.
                self.passwordField.returnKeyType = .done
            }
            
        }, completion:nil)
        
        // Inverse the display state value.
        self.displayState = !self.displayState
    }
    
    @IBAction func resetUserPassword(_ sender: AnyObject) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Open the reset password view.
        let storyboard = UIStoryboard(name: "ResetPassUI", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "resetpassword") as! ResetPasswordViewController
        self.present(viewC, animated: true, completion: nil)
    }
    
    //MARK: VIEW DID LOAD METHOD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
                
        // Hide the view to begin with and check
        // if the user is already logged in.
        self.view.alpha = 0.0
        
        if (PFUser.current() != nil) {
            
            // Show the news feed.
            self.transitionToNewsFeed()
        }
        
        // Setup the UI objects.
        self.setupUI()
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Set the keyboard dismiss handler.
        let followgesturereconizer = UITapGestureRecognizer(target: self, action: #selector(AllInOneSignUpAndLoginViewController.tapOnScreen))
        self.view.addGestureRecognizer(followgesturereconizer)
        
        // Set the block view array.
        self.blockViews = [self.blockViewOne, self.blockViewTwo, self.blockViewThree, self.blockViewFour, self.signUpUserButton, self.blockViewFive, self.resetPassButton, self.blockViewSix, self.loadingView]

        for loop in 0..<blockViews.count {
            
            // Curve the edges of the block views.
            (self.blockViews[loop] as! UIView).layer.cornerRadius = 4
            (self.blockViews[loop] as! UIView).clipsToBounds = true
        }
        
        // Add the blur view to the loading view.
        let blurEffect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.loadingView.bounds
        self.loadingView!.insertSubview(effectView, at: 0)
        
        // Hide the loading view.
        self.loadingView.alpha = 0.0
        
        // Set the already registered button border.
        self.alreadyAccountButton.layer.borderColor = UIColor.init(colorLiteralRed: (230.0/255), green: (230.0/255), blue: (230.0/255), alpha: 1.0).cgColor
        self.alreadyAccountButton.layer.borderWidth = 1.0
        
        // Setup the detail scroll view.
        self.detailScrollView.isScrollEnabled = true
        
        // Calculate the custom size width.
        let screenWidth = self.view.bounds.size.width
        let blockWidth = (screenWidth - 40)
        
        // Perfrom the UI size corrections.
        self.headerImageView.frame = CGRect(x: 0 , y: 0, width: screenWidth, height: self.headerImageView.frame.size.height)
        self.blockViewOne.frame = CGRect(x: 20 , y: self.blockViewOne.frame.origin.y, width: blockWidth, height: self.blockViewOne.frame.size.height)
        self.blockViewTwo.frame = CGRect(x: 20 , y: self.blockViewTwo.frame.origin.y, width: blockWidth, height: self.blockViewTwo.frame.size.height)
        self.blockViewThree.frame = CGRect(x: 20 , y: self.blockViewThree.frame.origin.y, width: blockWidth, height: self.blockViewThree.frame.size.height)
        self.blockViewFour.frame = CGRect(x: 20 , y: self.blockViewFour.frame.origin.y, width: blockWidth, height: self.blockViewFour.frame.size.height)
        self.blockViewFive.frame = CGRect(x: 20 , y: self.blockViewFive.frame.origin.y, width: blockWidth, height: self.blockViewFive.frame.size.height)
        self.signUpUserButton.frame = CGRect(x: 20 , y: self.signUpUserButton.frame.origin.y, width: blockWidth, height: self.signUpUserButton.frame.size.height)
        self.resetPassButton.frame = CGRect(x: 20 , y: self.resetPassButton.frame.origin.y, width: blockWidth, height: self.resetPassButton.frame.size.height)
        self.profilePictureButton.frame  = CGRect(x: ((screenWidth / 2) - (self.profilePictureButton.frame.size.width / 2)), y: self.profilePictureButton.frame.origin.y, width: self.profilePictureButton.frame.size.width, height: self.profilePictureButton.frame.size.height)
        self.loadingView.frame = CGRect(x: ((screenWidth / 2) - (self.loadingView.frame.size.width / 2)), y: self.loadingView.frame.origin.y, width: self.loadingView.frame.size.width, height: self.loadingView.frame.size.height)
        self.view.bringSubview(toFront: self.loadingView)
        
        // Get the screen size values.
        let result = UIScreen.main.bounds.size
        
        // Set the scroll view content size
        // depending on the device screen size.
        
        if (result.height == 480) {
            
            // 3.5 inch display - iPhone 4S & below.
            self.detailScrollView.contentSize = CGSize(width: result.width, height: 700)
            self.scrollHeightIncrease = [2, 3, 4, 5]
            self.bigScreenCheck = false
        }
            
        else if (result.height == 568) {
            
            // 4 inch display - iPhone 5/5s.
            self.detailScrollView.contentSize = CGSize(width: result.width, height: 650)
            self.scrollHeightIncrease = [2, 3, 4, 5]
            self.bigScreenCheck = false
        }
            
        else if (result.height == 667) {
            
            // 4.7 inch display - iPhone 6.
            self.detailScrollView.contentSize = CGSize(width: result.width, height: 300)
            self.scrollHeightIncrease = [1, 2, 3]
            self.bigScreenCheck = true
        }
            
        else if (result.height >= 736) {
            
            // 5.5 inch display - iPhone 6 Plus.
            self.detailScrollView.contentSize = CGSize(width: result.width, height: 300)
            self.scrollHeightIncrease = [1, 2, 3]
            self.bigScreenCheck = true
        }
        
        // Turn the profile picture button into a cirlce.
        self.profilePictureButton.layer.cornerRadius = (self.profilePictureButton.frame.size.width / 2)
        self.profilePictureButton.clipsToBounds = true
        
        // Show the main view.
        self.view.alpha = 1.0
    }
    
    func transitionToNewsFeed() {
        
        // Transition to the news feed by either intialising the tab bar controller
        // or by dismissing the current view depending on the transition type.
        
        if (self.transitionType == false) {
            
            PresentingViews.presentNewsFeed(self, completion: {
                self.clearUpUI()
            })
        }
        
        else {
            
            self.dismiss(animated: true, completion: {
                self.clearUpUI()
            })
        }
    }
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: {
            
            // Enable access to the UI and
            // hide the loading indicator view.
            self.changeUIAccess(true)
        })
    }
    
    func changeUIAccess(_ mode : Bool) {
        
        // True means we should enable access to the UI
        // objects and false means we should disable access.
        self.userFullNameField.isUserInteractionEnabled = mode
        self.userNameField.isUserInteractionEnabled = mode
        self.passwordField.isUserInteractionEnabled = mode
        self.emailField.isUserInteractionEnabled = mode
        self.detailScrollView.isUserInteractionEnabled = mode
        self.resetPassButton.isEnabled = mode
        self.signUpUserButton.isUserInteractionEnabled = mode
        self.ppButton.isUserInteractionEnabled = mode
        self.tosButton.isUserInteractionEnabled = mode
        self.alreadyAccountButton.isUserInteractionEnabled = mode
        self.profilePictureButton.isUserInteractionEnabled = mode
        
        // Show or hide the loading indicator view.
        
        if (mode == true) {
            self.loadingView.alpha = 0.0
        }
            
        else if (mode == false) {
            self.loadingView.alpha = 1.0
        }
    }
    
    func tapOnScreen() {
        self.view.endEditing(true)
        self.currentlyEditing = false
    }
    
    func clearUpUI() {
        
        // Clear the text fields.
        self.userFullNameField.text = nil
        self.userNameField.text = nil
        self.passwordField.text = nil
        self.emailField.text = nil
        
        // Reset the profile image button.
        self.profilePictureButton.setImage(UIImage(named: "camera_icon.png"), for: UIControlState())
    }
    
    //MARK: DATA METHODS.
    
    func checkUserData() {
        
        // Disable access to the UI and
        // show the loading indicator view.
        self.changeUIAccess(false)
        
        if (self.displayState == true) {
            
            // Get the entered username and password.
            
            if (!self.userNameField.hasText) {
                self.displayAlert("Error", alertMessage: "Please enter your username before logging in.")
            }
                
            else {
                
                if (!self.passwordField.hasText) {
                    self.displayAlert("Error", alertMessage: "Please enter your password before logging in.")
                }
                    
                else {
                    
                    // Log in the user account.
                    self.loginUser()
                }
            }
        }
        
        else {
            
            // Get the relevant user data.
            let userData = [self.userFullNameField.text, self.userNameField.text?.lowercased(), self.passwordField.text, self.emailField.text]
            
            // Setup the errors array.
            let errorStrings: [String] = ["full name", "username", "password", "email"]
            
            for loop in 0..<userData.count {
                
                // Get the current string.
                let data = userData[loop]
                
                // Setup the data string check.
                let dataCheck: String = data!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                // Ensure the string is not nill and
                // actually contains multiple characters.
                
                if ((data == nil) || (dataCheck.characters.count <= 0)) {
                    
                    // Create the error message.
                    let errorMessage = "Please ensure you have completed the '\(errorStrings[loop])' field before continuing."
                    
                    // Display the error alert.
                    self.displayAlert("Error", alertMessage: errorMessage)
                    
                    // Exit out of the for-loop/method.
                    return
                }
            }
            
            // Check the username to ensure that there
            // are no capital letters in the string.
            let capitalLetterRegEx  = ".*[A-Z]+.*"
            let textData = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
            let capitalresult = textData.evaluate(with: self.userNameField.text)
            
            if (capitalresult == true) {
                
                // Alert the user that there are
                // capital letters in the username.
                self.displayAlert("Error", alertMessage: "Calendario usernames must not include capital letters.")
            }
                
            else {
                
                // Check the username to make sure it only
                // contains dots, underscores, letters and numbers.
                var allowedSet: NSMutableCharacterSet!
                allowedSet = NSMutableCharacterSet(charactersIn: "._")
                allowedSet.formUnion(with: CharacterSet.alphanumerics)
                let forbiddenSet: CharacterSet = allowedSet.inverted
                let r: NSRange = (self.userNameField.text! as NSString).rangeOfCharacter(from: forbiddenSet)
                
                // Check the username against the character set.
                
                if (r.location != NSNotFound) {
                    
                    // Alert the user that there are
                    // illegal characters in the username.
                    self.displayAlert("Error", alertMessage: "Calendario usernames must only contain lower case letters, numbers, dots and underscore characters.")
                }
                    
                else {
                    
                    // Setup the terms and conditions reminder alert.
                    let alertController = UIAlertController(title: "Terms of Service", message: "In order to use this service, you must first accept the Terms of Service.", preferredStyle: .actionSheet)
                    
                    // Setup the alert actions.
                    let termsHandler = { (action:UIAlertAction!) -> Void in
                        
                        // Enable access to the UI and
                        // hide the loading indicator view.
                        self.changeUIAccess(true)
                        
                        // Show the Terms and Conditions view.
                        PresentingViews.ViewTermsOfService(self)
                    }
                    let viewTandCs = UIAlertAction(title: "View Terms of Service", style: .default, handler: termsHandler)
                    
                    let continueHandler = { (action:UIAlertAction!) -> Void in
                        
                        // The data meets all the requirements
                        // go on to the actual registration.
                        self.registerUser()
                    }
                    let accept = UIAlertAction(title: "Accept and Continue", style: .default, handler: continueHandler)
                    
                    let cancelHandler = { (action:UIAlertAction!) -> Void in
                        
                        // Enable access to the UI and
                        // hide the loading indicator view.
                        self.changeUIAccess(true)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelHandler)
                    
                    alertController.addAction(viewTandCs)
                    alertController.addAction(accept)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func loginUser() {
        
        // Get the entered username and password.
        let dataUser = self.userNameField.text
        let dataPass = self.passwordField.text
        
        // Login the user via the Parse API.
        PFUser.logInWithUsername(inBackground: dataUser!, password: dataPass!) { (user, error) -> Void in
            
            // Run the alert code on the main thread.
            DispatchQueue.main.async(execute: {
                                
                if (user != nil) {
                    
                    // Ensure that the recomendations view is not shown
                    // as the user has already seen the view before.
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "recoCheck")
                    defaults.synchronize()
                    
                    // Enable access to the UI and
                    // hide the loading indicator view.
                    self.changeUIAccess(true)
                    
                    // Show the news feed.
                    self.transitionToNewsFeed()
                }
                    
                else {
                    self.displayAlert("Error", alertMessage: "An error has occured, please ensure you have entered the correct username and password and then try again.")
                }
            })
        }
    }
    
    func registerUser() {
        
        // Get the relevat data.
        let email = self.emailField.text
        let username = self.userNameField.text?.lowercased()
        let password = self.passwordField.text
        
        // Setup the new user details.
        var newUser:PFUser!
        newUser = PFUser()
        newUser.username = username
        newUser.password = password
        newUser.email = email
        
        // Set the other user data fields.
        newUser["userBio"] = ""
        newUser["website"] = ""
        newUser["fullName"] = self.userFullNameField.text
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
        newUser.signUpInBackground { (succed, error) -> Void in
            
            // Run the alert code on the main thread.
            DispatchQueue.main.async(execute: {
                
                if (error != nil) {
                    
                    // Display the error message.
                    self.displayAlert("Error", alertMessage: "\((error?.localizedDescription)!)")
                }
                    
                else {
                    
                    // Create the user entry in the
                    // FollowersAndFollowing Parse class.
                    var userFollowData:PFObject!
                    userFollowData = PFObject(className:"FollowersAndFollowing")
                    userFollowData["userFollowing"] = []
                    userFollowData["userFollowers"] = []
                    userFollowData["userLink"] = PFUser.current()
                    
                    // Save the follow data on Parse.
                    userFollowData.saveInBackground(block: { (success: Bool, error: Error?) in
                        
                        // Create the user entry in the
                        // userNotifications Parse class.
                        var userNotificationData:PFObject!
                        userNotificationData = PFObject(className:"userNotifications")
                        userNotificationData["fromUser"] = []
                        userNotificationData["notificationStrings"] = []
                        userNotificationData["extLink"] = []
                        userNotificationData["notificationDate"] = []
                        userNotificationData["userLink"] = PFUser.current()
                        
                        // Save the notification data on Parse.
                        userNotificationData.saveInBackground(block: { (notificationSuccess, notificationError) -> Void in
                            
                            if (notificationSuccess) {
                                
                                // Ensure that the recomendations view is shown.
                                let defaults = UserDefaults.standard
                                defaults.set(true, forKey: "recoCheck")
                                defaults.synchronize()
                                
                                // Enable access to the UI and
                                // hide the loading indicator view.
                                self.changeUIAccess(true)
                                
                                // Show the news feed.
                                self.transitionToNewsFeed()
                            }
                                
                            else {
                                
                                // An error has occured.
                                self.displayAlert("Error", alertMessage: "\((notificationError?.localizedDescription)!)")
                            }
                        })
                    })
                }
            })
        }
    }
    
    //MARK: TEXT FIELD DELEGATE METHODS.
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Set the current edit state.
        self.currentlyEditing = true
        
        // Scroll to the text field so that it is
        // not hidden by the keyboard during editing.
        
        if (self.userFullNameField.isFirstResponder) {
            self.detailScrollView.setContentOffset(CGPoint(x: 0, y: (textField.bounds.size.height * self.scrollHeightIncrease[0])), animated: true)
        }
        
        else if (self.userNameField.isFirstResponder) {
            self.detailScrollView.setContentOffset(CGPoint(x: 0, y: (textField.bounds.size.height * self.scrollHeightIncrease[1])), animated: true)
        }
            
        else if (self.bigScreenCheck == false) {
            
            if (self.passwordField.isFirstResponder) {
                self.detailScrollView.setContentOffset(CGPoint(x: 0, y: (textField.bounds.size.height * self.scrollHeightIncrease[2])), animated: true)
            }
                
            else if (self.emailField.isFirstResponder) {
                self.detailScrollView.setContentOffset(CGPoint(x: 0, y: (textField.bounds.size.height * self.scrollHeightIncrease[3])), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Remove any content offset from the scroll
        // view otherwise the scroll view will look odd.
        
        if (self.currentlyEditing == false) {
            self.detailScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Set the current edit state.
        self.currentlyEditing = true
        
        // Move the keyboard to the next input text
        // field depending on the current selection
        // and the current display state bool value.
        
        if (self.displayState == true) {
            
            if (self.userNameField.isFirstResponder) {
                self.userNameField.text = self.userNameField.text?.lowercased()
                self.passwordField.becomeFirstResponder()
            }
                
            else if (self.passwordField.isFirstResponder) {
                self.currentlyEditing = false
                textField.resignFirstResponder()
            }
        }
        
        else {
            
            if (self.userFullNameField.isFirstResponder) {
                self.userNameField.becomeFirstResponder()
            }
                
            else if (self.userNameField.isFirstResponder) {
                self.userNameField.text = self.userNameField.text?.lowercased()
                self.passwordField.becomeFirstResponder()
            }
                
            else if (self.passwordField.isFirstResponder) {
                self.emailField.becomeFirstResponder()
            }
                
            else {
                self.currentlyEditing = false
                textField.resignFirstResponder()
            }
        }
        
        return true
    }
    
    //MARK: SCROLL VIEW DELEGATE METHODS.
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Dismiss the keyboard.
        self.currentlyEditing = false
        self.view.resignFirstResponder()
    }
    
    //MARK: IMAGE PICKER DELEGATE METHODS.
    
    func imagePickerController(_ picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        // Dismiss the image picker view controller.
        self.dismiss(animated: true, completion: { () -> Void in
            
            // The user has set an image.
            self.userSetImage = true
            
            // Store the image for use in the registration.
            self.imageData = UIImageJPEGRepresentation(image, 1.0)
            
            // Set the profile picture view.
            self.profilePictureButton.setImage(image, for: UIControlState())
        })
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
