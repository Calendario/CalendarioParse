//
//  CommentsViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/27/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextField!
    @IBOutlet weak var commentsContainerView: UIView!
    
    var commentdata:NSMutableArray = NSMutableArray()
    
    var savedobjectID:String!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    @IBOutlet weak var sendbutton: UIButton!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.PostComment()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the keyboard height when the comment text field is pressed - needed
        // in order to move the comment container view to the correct postion.
        self.view.bringSubviewToFront(self.commentsContainerView)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.commentTextView.delegate = self
      
        self.navigationItem.leftBarButtonItem = backbutton
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 98.0;

        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        //savedobjectID = defaults.objectForKey("objectid") as! String
        
        print(savedobjectID!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadCommentData()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = "Comments"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.sendbutton.layer.cornerRadius = 4.0
        let font = UIFont(name: "Futura-Medium", size: 21)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
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
    
    func keyboardWillShow(notification:NSNotification) {
        
        // Get the keyboard height.
        let userInfo:NSDictionary = notification.userInfo!
        let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.CGRectValue()
        var keyboardHeight = keyboardRectangle.height
        
        // Raise the comments container view.
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.commentsContainerView.transform = CGAffineTransformMakeTranslation(0.0, -keyboardHeight)
        }, completion:nil)
    }
    
    func dismissKeyboard() {
        
        // Hide the keyboard.
        self.commentTextView.resignFirstResponder()
        
        // Lower the comments container view.
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.commentsContainerView.transform = CGAffineTransformMakeTranslation(0.0, 0.0)
            }, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        LoadCommentData()
        self.tableView.reloadData()
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
        
        // Hide the keybaord if it has not
        // already been hidden from the view.
        self.dismissKeyboard()
        
        // Close the comments view.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func Sendtapped(sender: AnyObject) {
        
        self.PostComment()
        // self.refreshData()
    }
    
    func PostComment()
    {
        
        // Hide the keyboard.
        self.dismissKeyboard()
        
        if (self.commentTextView .hasText()) {
            
            var comment = PFObject(className: "comment")
            comment["commenttext"] = commentTextView.text
            comment["postedby"] = PFUser.currentUser()
            comment["statusOBJID"] = String(savedobjectID)
            
            
            comment.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                
                // Clear the text field for the next comment.
                self.commentTextView.text = nil
                
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
                            
                            // Reload the comments table view.
                            self.refreshData()
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
            
        else {
            
            // Setup the alert controller.
            let alertController = UIAlertController(title: "No comment", message: "Please type a comment before pressing send.", preferredStyle: .Alert)
            
            // Setup the alert actions.
            let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
            alertController.addAction(cancel)
            
            // Present the alert on screen.
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    // table view methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentdata.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentsTableViewCell
        
        cell.userProfileImage.layer.cornerRadius = (cell.userProfileImage.frame.size.width / 2)
        cell.userProfileImage.clipsToBounds = true
        
        let comment:PFObject = self.commentdata.objectAtIndex(indexPath.row) as! PFObject
        
        print(comment.valueForKey("postedby")?.objectId!)
        
        
        var usernamequery = PFUser.query()
        usernamequery?.getObjectInBackgroundWithId((comment.valueForKey("postedby")?.objectId!)!, block: { (object, error) -> Void in
            if error == nil
            {
                cell.UserLabel.text = object?.valueForKey("username") as! String
                
                if let image = object!["profileImage"] as! PFFile? {
                    
                    image.getDataInBackgroundWithBlock({ (ImageData, error) -> Void in
                        
                        if error == nil {
                            let image = UIImage(data: ImageData!)
                            cell.userProfileImage.image = image
                        }
                            
                        else {
                            cell.userProfileImage.image = UIImage(named: "default_profile_pic.png")
                        }
                    })
                }
            }
            
            else {
                cell.userProfileImage.image = UIImage(named: "default_profile_pic.png")
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
