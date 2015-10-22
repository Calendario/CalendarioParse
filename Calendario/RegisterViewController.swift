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

class RegisterViewViewController: UIViewController {
    
    // Setup the data input text fields and other objects.
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var rePassField: UITextField!
    @IBOutlet weak var descField: UITextView!
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var webField: UITextField!
    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet weak var profileScroll: UIScrollView!
    
    // Setup the on screen button actions.
    
    @IBAction func createUser(sender: UIButton) {
        
        // Check the entered data is present.
        checkData()
    }
    
    @IBAction func cancel(sender: UIButton) {
        
        // Go back to the login page.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let NFVC = sb.instantiateViewControllerWithIdentifier("LoginPage") as! LoginViewViewController
        let NC = UINavigationController(rootViewController: NFVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    @IBAction func addImage(sender: UIButton) {
        
        // Open the image gallary.
    }
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup the scroll view.
        profileScroll.scrollEnabled = true
        profileScroll.contentSize = CGSize(width:self.view.bounds.width, height: 880)
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
        
        // The data meets all the requirements
        // go on to the actual registration.
        registerUser()
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
        newUser.setObject(self.descField.text, forKey: "userBio")
        newUser.setObject(self.webField.text!, forKey: "website")
        
        // Pass the details to the Parse API.
        newUser.signUpInBackgroundWithBlock { (succed, error) -> Void in
            
            // Run the alert code on the main thread.
            dispatch_async(dispatch_get_main_queue(),{
                
                if (error != nil) {
                    self.displayError("Error", alertMessage: "\(error)")
                }
                    
                else {
                    
                    // Setup the alert controller.
                    let registerAlert = UIAlertController(title: "Welcome :)", message: "You have successfully created a Calendario account.", preferredStyle: .Alert)
                    
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
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let NFVC = sb.instantiateViewControllerWithIdentifier("newsfeed") as! NewsfeedViewController
        let NC = UINavigationController(rootViewController: NFVC)
        self.presentViewController(NC, animated: true, completion: nil)
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
    
    // Other metods.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}