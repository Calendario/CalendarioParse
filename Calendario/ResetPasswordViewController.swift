//
//  ResetPasswordViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 23/10/2015.
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

class ResetPasswordViewController : UIViewController, UITextFieldDelegate {
    
    // Setup the user email field.
    @IBOutlet weak var emailField: UITextField!
    
    // Setup the alert bool check.
    var checkAlertAction = false
    
    // Setup the on screen button actions.
    
    @IBAction func resetPassword(sender: UIButton) {
    
        // Check the entered email address.
        self.checkEmailAddress()
    }
    
    @IBAction func cancel(sender: UIButton) {
        
        // Dismiss the keyboard.
        self.emailField.resignFirstResponder()
        
        // Go back to the login page.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Force open the keyboard.
        self.emailField.becomeFirstResponder()
    }
    
    // Reset methods.
    
    func resetPassword() {
        
        // Get the entered email address.
        let dataEmail = self.emailField.text
        
        // Submit the password reset request.
        PFUser.requestPasswordResetForEmailInBackground(dataEmail!) { (success, error) -> Void in
            
            // Run the alert code on the main thread.
            dispatch_async(dispatch_get_main_queue(),{
                
                if (success && (error == nil)) {
                    
                    self.checkAlertAction = true
                    self.displayAlert("Success", alertMessage: "A password reset email has been sent to \(dataEmail)")
                }
                    
                else {
                    
                    self.emailField.becomeFirstResponder()
                    self.checkAlertAction = false
                    self.displayAlert("Error", alertMessage: error!.userInfo["error"] as! String)
                }
            })
        }
    }
    
    func checkEmailAddress() {
        
        // Check the entered email address.
        
        if (self.emailField.hasText()) {
            self.resetPassword()
        }
            
        else {
            self.displayAlert("Error", alertMessage: "Please enter your email address before submitting the password reset request.")
        }
    }
    
    // Alert methods.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        
        if (checkAlertAction == true) {
            
            let nextHandler = { (action:UIAlertAction!) -> Void in
                
                // Dismiss the keyboard.
                self.emailField.resignFirstResponder()
                
                // Go back to the login page.
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            let next = UIAlertAction(title: "Continue", style: .Default, handler: nextHandler)
            alertController.addAction(next)
        }
        
        else {
            
            let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alertController.addAction(cancel)
        }
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // Other methods.
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Check the entered email address.
        self.checkEmailAddress()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
