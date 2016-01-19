//
//  SeeMoreViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/22/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import KILabel
import DOFavoriteButton


class SeeMoreViewController: UIViewController {

    @IBOutlet weak var UserLabel: UILabel!

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet var likeButton: DOFavoriteButton!
    @IBOutlet weak var statusDateLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var PostImage: UIImageView!
    
    @IBOutlet weak var CommentButton: UIButton!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    @IBOutlet weak var TenseLabel: UILabel!
    
    @IBOutlet weak var locationlabel: UILabel!
    
    
    @IBOutlet weak var kilabel: KILabel!
    
    var propertyid:String!
    
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    

    override func viewDidLoad() {
       
        
        
        super.viewDidLoad()
        
        // Turn the profile picture into a cirlce.
        self.userProfileImage.layer.cornerRadius = (self.userProfileImage.frame.size.width / 2)
        self.userProfileImage.clipsToBounds = true
        
        self.navigationItem.setLeftBarButtonItem(backbutton, animated: true)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.38, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationItem.title = "see more"
        
        
        var objectid = defaults.objectForKey("objectId") as? String
        
        if objectid == nil
        {
            objectid = propertyid
        }

        

        // Do any additional setup after loading the view.
        
        contentTextView.textAlignment = .Center
        
        
        contentTextView.text = defaults.objectForKey("updatetext") as? String
        
        
        
        
        
    // check hashtags and mentions 
        if contentTextView.text.hasPrefix("#")
        {
            kilabel.text = contentTextView.text
            kilabel.hashtagLinkTapHandler = { label,hashtag,range in
                print(hashtag)
                
            }
        }
        else if contentTextView.text.hasPrefix("@")
        {
            kilabel.text = contentTextView.text
            kilabel.userHandleLinkTapHandler = {label,mention,range in
                var userquery = PFUser.query()
                print("mentiion is \(mention)")
                let editedtext = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                print(editedtext)
                userquery?.whereKey("username", equalTo: editedtext)
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
                                query2?.getObjectInBackgroundWithId(userid!, block: { (object, error) -> Void in
                                    var user:PFUser = object as! PFUser
                                    print(user)
                                    self.GotoProfile(user)
                                })
                            }
                        }
                    }
                })
            }
        }
        
        else if contentTextView.text.hasSuffix(".com")
        {
            kilabel.text = contentTextView.text
            kilabel.urlLinkTapHandler = {label,url,range in
                let nsurl = NSURL(string: "http://\(url)")
                print(nsurl)
                UIApplication.sharedApplication().openURL(nsurl!)
            
                
                
            }
            
            
            
        }
            
        else if contentTextView.text.hasSuffix(".org")
        {
            kilabel.text = contentTextView.text
            kilabel.urlLinkTapHandler = {label,url,range in
                let nsurl = NSURL(string: "http://\(url)")
                print(nsurl)
                UIApplication.sharedApplication().openURL(nsurl!)
                
                
                
            }

        }
            
            
        else if contentTextView.text.hasSuffix(".co.uk")
        {
            kilabel.text = contentTextView.text
            kilabel.urlLinkTapHandler = {label,url,range in
                let nsurl = NSURL(string: "http://\(url)")
                print(nsurl)
                UIApplication.sharedApplication().openURL(nsurl!)
                
                
                
            }

        }
        else
        {
            kilabel.hidden = true
        }
        
        if contentTextView.text.containsString("#")
        {
            kilabel.hidden = false
            kilabel.text = contentTextView.text
            kilabel.hashtagLinkTapHandler = { label,hashtag,range in
                print(hashtag)
                
            }

            
        }
        
         if contentTextView.text.containsString("@")
        {
            kilabel.hidden = false
            kilabel.text = contentTextView.text
            kilabel.userHandleLinkTapHandler = {label,mention,range in
                var userquery = PFUser.query()
                print("mentiion is \(mention)")
                let editedtext = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                print(editedtext)
                userquery?.whereKey("username", equalTo: editedtext)
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
                                query2?.getObjectInBackgroundWithId(userid!, block: { (object, error) -> Void in
                                    var user:PFUser = object as! PFUser
                                    print(user)
                                    self.GotoProfile(user)
                                })
                            }
                        }
                    }
                })
            }

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
                        
                        
                        
                        // Get the user object from Parse.
                        var imageQuery:PFQuery!
                        imageQuery = PFUser.query()
                        imageQuery.whereKey("objectId", equalTo: (object.valueForKey("user")?.objectId!)!)
                        imageQuery.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                            
                            // Check if the user has a profile image.
                            
                            if (userObject!.objectForKey("profileImage") == nil) {
                                
                                // No profile image use the basic one.
                                self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                            }
                                
                            else {
                                
                                // Profile image is available for use.
                                let userImageFile = userObject!["profileImage"] as! PFFile
                                
                                // Download the profile image data.
                                userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                                    
                                    if (error == nil) {
                                        
                                        // Check the profile image data first.
                                        let profileImage = UIImage(data:imageData!)
                                        
                                        if ((imageData != nil) && (profileImage != nil)) {
                                            
                                            // Set the downloaded profile image.
                                            self.userProfileImage.image = profileImage
                                        }
                                            
                                        else {
                                            
                                            // No profile picture set the standard image.
                                            self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                                        }
                                    }
                                        
                                    else {
                                        
                                        // Error has occured show the standard image.
                                        self.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                                    }
                                }
                            }
                        })
                        
                        
                        
                        
                        
                        
                        if let likes = object.valueForKey("likes") as? Int {
                            self.likeCountLabel.text = "\(likes)"
                            
                            if likes >= 1
                            {
                                self.likeButton.setImage(UIImage(named: "like button filled"), forState: .Normal)
                            }
                        }
                        
                        else {
                            self.likeCountLabel.text = "0"
                        }
                        
                        
                        self.defaults.setObject(object.objectId, forKey: "fromseemore")
                        
                        
                        
                        var tense = object.valueForKey("tense") as! String
                        
                        self.TenseLabel.text = tense
                        
                        
                        var location = object.valueForKey("location") as! String
                        
                        self.locationlabel.text = location
                        
                        var dateofevent = object.valueForKey("dateofevent") as! String
                        
                        self.statusDateLabel.text = dateofevent
                        
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
        
        
        
        // getting the number of comments
        
        
        
        
        
        
        
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
        
        // Dismiss the view instead of going back to the news feed;
        // SeeMore/Report views are called by other controllers too.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    /*
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }
    */
    
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
