//
//  CommentsViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/27/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextField!
    
    var commentdata:NSMutableArray = NSMutableArray()
    
    var savedobjectID:String!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    @IBOutlet weak var sendbutton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
      self.navigationItem.rightBarButtonItem = sendbutton


        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
                
        
        savedobjectID = defaults.objectForKey("objectid") as! String
        
        print(savedobjectID!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadCommentData()
        
        
       /* let navigationbar = UINavigationBar(frame:  CGRectMake(0, 0, self.view.frame.size.width, 53))
        navigationbar.backgroundColor = UIColor.whiteColor()
        navigationbar.delegate = self
        navigationbar.barTintColor = UIColor(hexString: "#2c9560")
        navigationbar.tintColor = UIColor.whiteColor()
        
        let navitems = UINavigationItem()
        
        navitems.rightBarButtonItem = sendbutton
        navitems.leftBarButtonItem = backbutton
        
        // set nav items in nav bar
        navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)
        
        */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func LoadCommentData()
    {
        commentdata.removeAllObjects()
        
        var getcomments:PFQuery = PFQuery(className: "comment")
        getcomments.whereKey("statusOBJID", equalTo: savedobjectID)
        
        getcomments.findObjectsInBackgroundWithBlock { (comments:[PFObject]?, error:NSError?) -> Void in
            if error == nil
            {
                for comment in comments!
                {
                    let comments:PFObject = comment as! PFObject
                    self.commentdata.addObject(comment)
                }
                
                let array:NSArray = self.commentdata.reverseObjectEnumerator().allObjects
                self.commentdata = NSMutableArray(array: array)
                self.tableView.reloadData()
            }
        }
        
    }
    
    /*
    func GotoNewsfeed() {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
    appDelegate.window.makeKeyAndVisible()
    appDelegate.window.rootViewController = tabBarController
    }*/
    
    
    @IBAction func bacbuttontapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func Sendtapped(sender: AnyObject) {
        PostComment()
    }

    
    func PostComment()
    {
        var comment = PFObject(className: "comment")
        comment["commenttext"] = commentTextView.text
        comment["postedby"] = PFUser.currentUser()
        comment["statusOBJID"] = String(savedobjectID)
        
        
        comment.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success
            {
              
                
                var query = PFQuery(className: "StatusUpdate")
                query.includeKey("user")
                query.getObjectInBackgroundWithId(self.savedobjectID, block: { (object, error) -> Void in
                    if error == nil
                    {
                        print(object!.valueForKey("user")!.username!)
                        
                        // create push notifcation
                        let message = "\(PFUser.currentUser()!.username!) has commented on your post"
                        
                        // Send the notification.
                        PFCloud.callFunctionInBackground("comment", withParameters: ["message" : message, "user" : "\((object!.valueForKey("user") as! PFUser).username!)"])
                        
                        // Save the user notification.
                        ManageUser.saveUserNotification(message, fromUser: PFUser.currentUser()!, toUser: object!.valueForKey("user") as! PFUser)
                        
                        // DONT use the "SavingNotifacations" method it doesnt work.
                    }
                })
                
                
                
                
                
                print("comment posted")
                
                
            }
            else
            {
                print(error?.localizedDescription)
            }
        }
    }
    
    /*
    func SavingNotifacations(notifcation:String)
    {
        var userviewed:PFUser = PFUser.currentUser()!
        var notiQuery = PFUser.query()
        notiQuery?.whereKey("objectId", equalTo: userviewed.objectId!)
        notiQuery?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if error == nil
            {
                let retreveduser:PFUser = object as! PFUser
                var notifications:NSMutableArray = NSMutableArray()
                notifications.addObjectsFromArray([retreveduser.objectForKey("notifications")!]) // bug here 
                notifications.addObject(notifcation)
                
                if notifications.count > 29
                {
                    notifications.removeObjectAtIndex(0)
                    
                }
                
                retreveduser["notifications"] = notifications
                retreveduser.saveInBackground()
            }
        })
    }*/
    

    
    
    
    // table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentdata.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentsTableViewCell
        
        
        let comment:PFObject = self.commentdata.objectAtIndex(indexPath.row) as! PFObject

        print(comment.valueForKey("postedby")?.objectId!)
        
        
        var usernamequery = PFUser.query()
        usernamequery?.getObjectInBackgroundWithId((comment.valueForKey("postedby")?.objectId!)!, block: { (object, error) -> Void in
            if error == nil
            {
                cell.UserLabel.text = object?.valueForKey("username") as! String
            }
        })
        

        
        cell.commentTextView.text = comment.objectForKey("commenttext") as! String

   
        return cell
    }
    
     func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
