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
    
    let choicesarray = ["Edit Profile", "View Follow Requests", "Report Bug", "Privacy Policy", "Terms of Service", "Acknowledgments", "Recommended Users"]
    
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
                let storyboard = UIStoryboard(name: "LoginSignUpUI", bundle: nil)
                let loginView = storyboard.instantiateViewControllerWithIdentifier("SignUpLoginUI") as! AllInOneSignUpAndLoginViewController
                loginView.transitionType = true
                self.presentViewController(loginView, animated: true, completion:nil)
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
        
        if (indexPath.row == 1) {
            
            // Update the follow requests badge.
            var followQuery:PFQuery!
            followQuery = PFQuery(className: "FollowRequest")
            followQuery.whereKey("desiredfollower", equalTo: PFUser.currentUser()!)
            followQuery.findObjectsInBackgroundWithBlock { (object, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
                    label.textColor = UIColor.blackColor()
                    label.textAlignment = .Center
                    label.textColor = UIColor.whiteColor()
                    label.backgroundColor = UIColor.redColor()
                    label.layer.cornerRadius = label.frame.size.height / 2.0
                    label.clipsToBounds = true
                    cell.accessoryView = label
                    
                    if (error == nil) {
                        
                        if (object!.count > 0) {
                            label.text = "\(object!.count)"
                        }
                            
                        else {
                            label.text = "0"
                        }
                    }
                    
                    else {
                        label.text = "0"
                    }
                })
            }
        }
        
        else {
            
            cell.accessoryView = nil
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableview.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
            
            case 0: PresentingViews.ShowUserEditController(self); break;
            case 1: PresentingViews.ShowFollowRequestsView(self); break;
            case 2: PresentingViews.ViewReportBug(self); break;
            case 3: PresentingViews.ViewPrivacyPolicy(self); break;
            case 4: PresentingViews.ViewTermsOfService(self); break;
            case 5: PresentingViews.viewAcknowledgments(self); break;
            case 6: PresentingViews.viewRecommendations(self); break;
            default: break;
        }
    }
}
