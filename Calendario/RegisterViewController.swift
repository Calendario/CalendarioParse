//
//  RegisterViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 14/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class RegisterViewViewController: UIViewController, PFLogInViewControllerDelegate {
    
    // Setup the on screen button actions.
    @IBAction func loginUser(sender: UIButton) {
        
    }
    
    @IBAction func registerUser(sender: UIButton) {
        
    }
    
    @IBAction func resetPassword(sender: UIButton) {
        
    }
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var loginView = PFLogInViewController()
        
        loginView.delegate = self
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    // Login methods.
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // present welcome screen
        print("user logged in")
        GotoNewsfeed()
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        print("cancelled")
    }
    
    // News feed methods.
    func GotoNewsfeed() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let NFVC = sb.instantiateViewControllerWithIdentifier("newsfeed") as! NewsfeedViewController
        let NC = UINavigationController(rootViewController: NFVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    // Other metods.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}