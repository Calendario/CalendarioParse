//
//  LoginViewViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
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

class LoginViewViewController: UIViewController, UITextFieldDelegate {
    
    // Setup the username and password text fields.
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
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
        let viewC = storyboard.instantiateViewControllerWithIdentifier("registerview") as! RegisterViewViewController
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
        // Do any additional setup after loading the view, typically from a nib.
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
                
                if (user != nil) {
                    
                    // Setup the alert controller.
                    let loginAlert = UIAlertController(title: "Success", message: "You have been logged into Calendario.", preferredStyle: .Alert)
                    
                    // Setup the alert actions.
                    let nextHandler = { (action:UIAlertAction!) -> Void in
                        self.GotoNewsfeed()
                    }
                    let next = UIAlertAction(title: "Continue", style: .Default, handler: nextHandler)
                    
                    // Add the actions to the alert.
                    loginAlert.addAction(next)
                    
                    // Present the alert on screen.
                    self.presentViewController(loginAlert, animated: true, completion: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
