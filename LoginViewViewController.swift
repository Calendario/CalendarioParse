//
//  LoginViewViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class LoginViewViewController: UIViewController, PFLogInViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var loginView = PFLogInViewController()
        
        loginView.delegate = self
        self.presentViewController(loginView, animated: true, completion: nil)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // present welcome screen
        print("user logged in")
        GotoNewsfeed()
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        print("cancelled")
    }
    
    func GotoNewsfeed()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let NFVC = sb.instantiateViewControllerWithIdentifier("newsfeed") as! NewsfeedViewController
        let NC = UINavigationController(rootViewController: NFVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


}