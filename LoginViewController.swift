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

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Setup the username and password text fields.
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    // Background animation image view.
    @IBOutlet weak var backgroundImage: UIImageView!
    
    // Backgrond photo names array.
    var backgroundPhotos = Array<UIImage>()
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        // Get the screen dimensions.
        let height = UIScreen.mainScreen().bounds.size.height
        
        // Set the animation images depending on
        // the height of the iOS device screen.
        var imageName = "iphone4s"
        
        if (height == 480) {
            // 3.5 inch display - iPhone 4S & below.
            imageName = "iphone4s"
        }
        
        else if (height == 568) {
            // 4 inch display - iPhone 5/5s.
            imageName = "iphone5&5s"
        }
        
        else if (height == 667) {
            // 4.7 inch display - iPhone 6/6s.
            imageName = "iphone6"
        }
        
        else if (height >= 736) {
            // 5.5 inch display - iPhone 6/6s Plus.
            imageName = "iphone6+"
        }
        
        // Add the appropriate images to the photos array.
        
        for (var loop = 0; loop < 10; loop++) {
            
            if ((loop + 1) != 2) {
                backgroundPhotos.append(UIImage(named: "\(imageName)\(loop + 1).png")!)
            }
        }
        
        // Automatically take the user to the
        // news feed section if they are already
        // logged in to the Calendario app.
        var currentUser:PFUser!
        currentUser = PFUser.currentUser()
        
        if (currentUser != nil) {
            
            // The user is already logged in.
            self.GotoNewsfeed()
        }
        
        // Run the animation.
        self.runBackgroundAnim(0)
    }
    
    // Animation methods.
    
    func runBackgroundAnim(let num:Int) {
        
        // Set the array counter number.
        var count = num
        
        if ((count + 1) == backgroundPhotos.count) {
            count = 0
        }
        
        else {
            count = (count + 1)
        }
        
        UIView.transitionWithView(self.backgroundImage, duration:3.0, options:UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            
            // Set the background photo
            self.backgroundImage.image = self.backgroundPhotos[count]
            }, completion: {(Bool) in
                
                // Move on to the next photo animation
                // after a small transitional delay.
                let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.runBackgroundAnim(count)
                })
        })
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
