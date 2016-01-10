//
//  SettingsViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 21/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import Foundation
import UIKit
import Parse

class SettingsViewController : UIViewController {
    
    // Setup the various UI objects.
    
    // Setup the on screen button actions.
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signOutUser(sender: UIButton) {
        
        // Log the user out of Calendario.
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            
            // Check if the log out has 
            // been completed or not.
            
            if (error == nil) {
                
                // Remove the push notifications channel.
                PFInstallation.currentInstallation().removeObjectForKey("user")
                PFInstallation.currentInstallation().saveInBackground()
                
                // Go back to the login view controller.
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewC = storyboard.instantiateViewControllerWithIdentifier("LoginPage") as! LoginViewController
                self.presentViewController(viewC, animated: true, completion: nil)
            }
            
            else {
                
                // Display the error message.
                self.displayAlert("Error", alertMessage: "\(error!.description)")
            }
        }
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
