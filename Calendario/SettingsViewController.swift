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
    var followRequestLabel: UILabel!
    
    // Setup the on screen button actions.
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOutUser(_ sender: UIButton) {
        
        // Log the user out of Calendario.
        PFUser.logOutInBackground { (error) -> Void in
            
            // Check if the log out has
            // been completed or not.
            
            if (error == nil) {
                
                // Remove the push notifications channel.
                PFInstallation.current().remove(forKey: "user")
                PFInstallation.current().saveInBackground()
                
                // Go back to the login view controller.
                let storyboard = UIStoryboard(name: "LoginSignUpUI", bundle: nil)
                let loginView = storyboard.instantiateViewController(withIdentifier: "SignUpLoginUI") as! AllInOneSignUpAndLoginViewController
                loginView.transitionType = true
                self.present(loginView, animated: true, completion: {
                    
                    // Reset the follow request label.
                    
                    if (self.followRequestLabel != nil) {
                        self.followRequestLabel.text = "0"
                    }
                    
                    // Reset the 4 main tab views.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RESET_TAB_1"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RESET_TAB_2"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RESET_TAB_3"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RESET_TAB_4"), object: nil)
                })
            }
                
            else {
                
                // Display the error message.
                self.displayAlert("Error", alertMessage: "\(error?.localizedDescription)")
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
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: TABLEVIEW METHODS
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicesarray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Setup the settings cell.
        let cell = tableview.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        // Set the setting name.
        cell.textLabel?.text = choicesarray[(indexPath as NSIndexPath).row]
        
        if ((indexPath as NSIndexPath).row == 1) {
            
            // Update the follow requests badge.
            var followQuery:PFQuery<PFObject>!
            followQuery = PFQuery(className: "FollowRequest")
            followQuery.whereKey("desiredfollower", equalTo: PFUser.current()!)
            followQuery.findObjectsInBackground { (object, error) -> Void in
                
                DispatchQueue.main.async(execute: {
                    
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
                    label.textColor = UIColor.black
                    label.textAlignment = .center
                    label.textColor = UIColor.white
                    label.backgroundColor = UIColor.red
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
                    
                    self.followRequestLabel = label
                })
            }
        }
        
        else {
            
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableview.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath as NSIndexPath).row {
            
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
