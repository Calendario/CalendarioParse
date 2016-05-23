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

class SettingsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let choicesarray = ["Edit Profile", "Report Bug", "Privacy Policy", "Terms of Service", "Acknowledgments", "Recommended Users"]
    
    // Setup the various UI objects.
    @IBOutlet weak var tableview: UITableView!
    
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
                self.presentViewController(viewC, animated: true, completion:nil)
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
        tableview.delegate = self
        tableview.dataSource = self
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
    
    //MARK: TABLEVIEW METHODS
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicesarray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Setup the settings cell.
        let cell = tableview.dequeueReusableCellWithIdentifier("settingsCell", forIndexPath: indexPath)
        
        // Set the setting name.
        cell.textLabel?.text = choicesarray[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableview.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
            
            case 0: PresentingViews.ShowUserEditController(self); break;
            case 1: PresentingViews.ViewReportBug(self); break;
            case 2: PresentingViews.ViewPrivacyPolicy(self); break;
            case 3: PresentingViews.ViewTermsOfService(self); break;
            case 4: PresentingViews.viewAcknowledgments(self); break;
            case 5: PresentingViews.viewRecommendations(self); break;
            default: break;
        }
    }
}
