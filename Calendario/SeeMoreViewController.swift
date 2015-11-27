//
//  SeeMoreViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/22/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class SeeMoreViewController: UIViewController {

    @IBOutlet weak var UserLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var PostImage: UIImageView!
    
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var CommentButton: UIButton!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    

    override func viewDidLoad() {
        
        let likebuttonfilled = UIImage(named: "like button filled")
        
       
        
        
        super.viewDidLoad()
        
        self.navigationItem.setLeftBarButtonItem(backbutton, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.38, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.title = "More Info"
        
        
        var objectid = defaults.objectForKey("objectId") as? String

        

        // Do any additional setup after loading the view.
        
        
        contentTextView.text = defaults.objectForKey("updatetext") as? String
        
        
        print(objectid!)
        
        var query = PFQuery(className: "StatusUpdate")
        query.whereKey("objectId", equalTo: objectid!)
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                print(objects!.count)
                
                if let objects = objects
                {
                    for object in objects
                    {
                        print(object)
                        
                        var user = object.valueForKey("user")?.username!
                        print(user!)
                        self.UserLabel.text = user!
                        
                        var likes = object.valueForKey("likes") as? Int
                        
                        
                        self.defaults.setObject(object.objectId, forKey: "fromseemore")
                        
                        
                        print(likes)
                        
                        if likes >= 1
                        {
                            self.LikeButton.setImage(likebuttonfilled, forState: .Normal)
                        }
                        
                        
                        
                       
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        //print(defaults.objectForKey("username") as? String)

}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        GotoNewsfeed()
    }
   
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "seemore"
        {
            let vc = segue.destinationViewController as! CommentsViewController
            
              var objectid = defaults.objectForKey("objectId") as? String
            
            vc.savedobjectID = objectid

        }
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
