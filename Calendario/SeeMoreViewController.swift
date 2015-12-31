//
//  SeeMoreViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/22/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import ActiveLabel


class SeeMoreViewController: UIViewController {

    @IBOutlet weak var UserLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var PostImage: UIImageView!
    
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var CommentButton: UIButton!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    @IBOutlet weak var TenseLabel: UILabel!
    
    @IBOutlet weak var locationlabel: UILabel!
    
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    

    override func viewDidLoad() {
        
        let likebuttonfilled = UIImage(named: "like button filled")
        
       
        
        
        super.viewDidLoad()
        
        self.navigationItem.setLeftBarButtonItem(backbutton, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.38, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.title = "see more"
        
        
        var objectid = defaults.objectForKey("objectId") as? String

        

        // Do any additional setup after loading the view.
        
        
        contentTextView.text = defaults.objectForKey("updatetext") as? String
        
        
        
        
    // check hashtags and mentions 
        
        if contentTextView.text.hasPrefix("#")
        {
            let label = ActiveLabel()
            
            label.numberOfLines = 0
            label.text = contentTextView.text
            label.hashtagColor = UIColor.greenColor()
            label.handleHashtagTap { hashtag in
                print("Success. You just tapped the \(hashtag) hashtag")
            }
            label.frame = CGRect(x: 85, y: 75, width: view.frame.width - 30, height: 325)
            self.view.addSubview(label)
        }
        
        if contentTextView.text.hasPrefix("@")
        {
            let label = ActiveLabel()
            label.numberOfLines = 0
            label.text = contentTextView.text
            label.mentionColor = UIColor.greenColor()
            label.handleHashtagTap({ (handle) -> () in
                print("tapped")
                
                var userquery = PFUser.query()
                userquery?.whereKey("username", equalTo: handle)
                userquery?.includeKey("user")
                userquery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                    if error == nil
                    {
                        print(objects?.count)
                        if let objects = objects
                        {
                            for object in objects
                            {
                                var userid = object.objectId
                                print(userid)
                                
                                var query2 = PFUser.query()
                                query2?.includeKey("user")
                                query2?.getObjectInBackgroundWithId(userid!, block: { (objects, error) -> Void in
                                    var user:PFUser = object as! PFUser
                                    print(user)
                                    self.GotoProfile(user)
                                })
                            }
                        }
                    }
                })
            })
            label.frame = CGRect(x: 85, y: 75, width: view.frame.width - 30, height: 500)
            self.view.addSubview(label)

        }
    
        
        
        
        
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
                        
                        
                        
                        var tense = object.valueForKey("tense") as! String
                        
                        self.TenseLabel.text = tense
                        
                        
                        var location = object.valueForKey("location") as! String
                        
                        self.locationlabel.text = location
                        
                        
                        
                        let image = object["image"] as? PFFile
                        image?.getDataInBackgroundWithBlock({ (imagedata, error) -> Void in
                            if error == nil
                            {
                                let image = UIImage(data: imagedata!)
                                
                                let defaults = NSUserDefaults.standardUserDefaults()
                                defaults.setObject(UIImagePNGRepresentation(image!), forKey: "image")
                                
                                
                                let tapgesture = UITapGestureRecognizer(target: self, action: "imageTapped")
                                
                                self.PostImage.image = image
                                
                                self.PostImage.addGestureRecognizer(tapgesture)
                            }
                        })
                        
                        
                        
                        
                        
                        
                       
                    }
                }
            }
        }
        
        
        
        
        
        
        
        
        //print(defaults.objectForKey("username") as? String)

}
    
    func imageTapped()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("photoviewer") as! CalPhotoViewerViewController
        let NC = UINavigationController(rootViewController: PVC)
        self.presentViewController(NC, animated: true, completion: nil)

    }
    
    
    func GotoProfile(user:PFUser)
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var profile = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        profile.passedUser = user
        self.presentViewController(profile, animated: true, completion: nil)
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
