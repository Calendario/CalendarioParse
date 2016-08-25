//
//  ResetPasswordViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 23/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

class ResetPasswordViewController : UIViewController, UITextFieldDelegate {
    
    //MARK: UI OBJECTS.
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailBlockView: UIView!
    @IBOutlet weak var resetButton: UIView!
    
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
        
        // Curve the edges of the block views.
        emailBlockView.layer.cornerRadius = 4
        emailBlockView.clipsToBounds = true
        resetButton.layer.cornerRadius = 4
        resetButton.clipsToBounds = true
        
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
                
                // Notify the user that the app has stopped loading.
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if (success && (error == nil)) {
                    
                    self.checkAlertAction = true
                    self.displayAlert("Success", alertMessage: "A password reset email has been sent to \(dataEmail!)")
                }
                    
                else {
                    
                    self.emailField.becomeFirstResponder()
                    self.checkAlertAction = false
                    self.displayAlert("Error", alertMessage: (error?.localizedDescription)!)
                }
            })
        }
    }
    
    func checkEmailAddress() {
        
        // Check the entered email address.
        
        if (self.emailField.hasText()) {
            
            // Notify the user that the app is loading.
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            // Reset the user password.
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
}
