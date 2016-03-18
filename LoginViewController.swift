//
//  LoginViewViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Setup the username and password text fields.
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // Setup the on screen button actions.
    
    @IBAction func loginUser(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Check that the user has entered the
        // username/password and login the user.
        checkUsernameAndPassword()
    }
    
    @IBAction func registerUser(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Open the register view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("registerview") as! RegisterViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.view.resignFirstResponder()
        
        // Open the reset password view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("resetpassword") as! ResetPasswordViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkForExistingUser()
    }
    
    private func setupUI() {
        signInButton.layer.cornerRadius = 6.0
        signInButton.clipsToBounds = true
        signInButton.layer.borderColor = UIColor.whiteColor().CGColor
        signInButton.layer.borderWidth = 1.0
        
        userField.clipsToBounds = true
        passField.clipsToBounds = true
        usernameView.layer.borderWidth = 1.0
        usernameView.layer.borderColor = UIColor.whiteColor().CGColor
        usernameView.layer.cornerRadius = 6.0
        usernameView.clipsToBounds = true
        passwordView.layer.borderWidth = 1.0
        passwordView.layer.borderColor = UIColor.whiteColor().CGColor
        passwordView.layer.cornerRadius = 6.0
        passwordView.clipsToBounds = true
        
        createBackgroundOverlay()
    }
    
    private func checkForExistingUser() {
        var currentUser:PFUser!
        currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            self.GotoNewsfeed()
        }
    }
    
    private func createBackgroundOverlay() {
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.backgroundImage.frame.size.width, height: self.backgroundImage.frame.size.height))
        overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.15)
        self.backgroundImage.addSubview(overlay)
    }
    
    // Login methods.
    
    func loginUser() {
        
        // Get the entered username and password.
        let dataUser = self.userField.text
        let dataPass = self.passField.text
        
        // Login the user via the Parse API.
        PFUser.logInWithUsernameInBackground(dataUser!, password: dataPass!) { (user, error) -> Void in
            
            // Run the alert code on the main thread.
            dispatch_async(dispatch_get_main_queue(),{
                
                // Notify the user that the app has stopped loading.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if (user != nil) {
                    
                    // Ensure that the recomendations view is not shown
                    // as the user has already seen the view before.
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(false, forKey: "recoCheck")
                    defaults.synchronize()
                    
                    // Show the home view.
                    self.GotoNewsfeed()
                }
                    
                else {
                    self.displayAlert("Error", alertMessage: "An error has occured, please ensure you have entered the correct username and password and then try again.")
                }
            })
        }
    }
    
    func checkUsernameAndPassword() {
        
        // Get the entered username and password.
        let dataUser = self.userField.text
        let dataPass = self.passField.text
        
        if (dataUser == nil) {
            displayAlert("Errpr", alertMessage: "Please enter your username before logging in.")
        }
            
        else {
            
            if (dataPass == nil) {
                displayAlert("Errpr", alertMessage: "Please enter your password before logging in.")
            }
                
            else {
                
                // Notify the user that the app is loading.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
                // Log in the user account.
                loginUser()
            }
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
