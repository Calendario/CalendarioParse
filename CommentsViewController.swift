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
     
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.commentTextView.delegate = self
        self.commentTextView.autocapitalizationType = .Sentences
      
        // Do any additional setup after loading the view.
    
        //let defaults = NSUserDefaults.standardUserDefaults()
        //savedobjectID = defaults.objectForKey("objectid") as! String
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LoadCommentData()
        
        self.view.bringSubviewToFront(self.commentsContainerView)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = "Comments"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        self.sendbutton.layer.cornerRadius = 4.0
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        self.navigationItem.leftBarButtonItem = backbutton
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 98.0;

        
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
        let keyboardHeight = keyboardRectangle.height
        
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
        
        var getcomments:PFQuery!
        getcomments = PFQuery(className: "comment")
        getcomments.whereKey("statusOBJID", equalTo: savedobjectID!)
        
        getcomments.findObjectsInBackgroundWithBlock { (comments:[PFObject]?, error:NSError?) -> Void in
            if error == nil
            {
                
                if ((comments != nil) && (comments!.count > 0)) {
                    
                    for comment in comments!
                    {
                        self.commentdata.addObject(comment)
                    }
                    
                    let array:NSArray = self.commentdata.reverseObjectEnumerator().allObjects
                    let reverseArray = array.reverse()
                    self.commentdata = NSMutableArray(array: reverseArray)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
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
    
    func PostComment() {
        
        // Hide the keyboard.
        self.dismissKeyboard()
        
        if (self.commentTextView .hasText()) {
            
            // Make sure the commenttext contains all
            // the @user mentions in lowercase.
            ManageUser.correctStringWithUsernames(self.commentTextView.text!, completion: { (correctString) -> Void in
                
                // Setup the comment object.
                var comment: PFObject!
                comment = PFObject(className: "comment")
                comment["postedby"] = PFUser.currentUser()
                comment["statusOBJID"] = String(self.savedobjectID)
                comment["commenttext"] = correctString
                
                // Submit the user comment.
                comment.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                    
                    // Clear the text field for the next comment.
                    self.commentTextView.text = nil
                    
                    if success {
                        
                        var query: PFQuery!
                        query = PFQuery(className: "StatusUpdate")
                        query.includeKey("user")
                        query.getObjectInBackgroundWithId(self.savedobjectID, block: { (object, error) -> Void in
                            
                            if error == nil {
                                
                                // Only save the notification if the user recieving
                                // the notification is NOT the same as the logged in user.
                                
                                if (PFUser.currentUser()!.objectId! != (object?.objectForKey("user") as! PFUser).objectId!) {
                                    
                                    // create push notifcation
                                    let message = "\(PFUser.currentUser()!.username!) has commented on your post"
                                    
                                    // Send the notification.
                                    PFCloud.callFunctionInBackground("comment", withParameters: ["message" : message, "user" : "\((object!.valueForKey("user") as! PFUser).username!)"])
                                    
                                    // Save the user notification.
                                    ManageUser.saveUserNotification(message, fromUser: PFUser.currentUser()!, toUser: object!.valueForKey("user") as! PFUser, extType: "comment", extObjectID: String(self.savedobjectID))
                                }
                                
                                // Reload the comments table view.
                                self.refreshData()
                            }
                        })
                    }
                        
                    else {
                        print(error?.localizedDescription)
                    }
                }
            })
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
    
    // Table view methods.
    
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
        
        // Set the comment createdAt label.
        DateManager.createDateDifferenceString(comment.createdAt!) { (difference) -> Void in
            cell.createdAtLabel.text = difference
        }
        
        // If the status contains hashtags then highlight them.
        
        if ((cell.commentTextView.text?.hasPrefix("#")) != nil) {
            
            // Highlight the status hashtags.
            cell.commentTextView.hashtagLinkTapHandler = {label, hashtag, range in
                
                // Load in the hashtag data.
                var defaults = NSUserDefaults.standardUserDefaults()
                var hashtagData: NSMutableArray = []
                hashtagData = ((defaults.objectForKey("HashtagData"))?.mutableCopy())! as! NSMutableArray
                
                // Set the correct index number.
                var hashtagIndex = hashtagData[0] as! Int
                hashtagIndex = hashtagIndex + 1
                
                // Add the new hashtag index number/string.
                hashtagData.replaceObjectAtIndex(0, withObject: hashtagIndex)
                hashtagData.addObject(hashtag)
                
                // Save the hashtag data.
                defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(hashtagData, forKey: "HashtagData")
                defaults.synchronize()
                
                // Open the hashtag view with status
                // posts containing the selected #hashtag.
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let hashView = sb.instantiateViewControllerWithIdentifier("HashtagNav") as! UINavigationController
                self.presentViewController(hashView, animated: true, completion: nil)
            }
        }
        
        // If the status contains @mentions then highligh
        // and link them to the open profile view action.
        
        if ((cell.commentTextView.text?.hasPrefix("@")) != nil) {
            
            // Highlight the @username label.
            cell.commentTextView.userHandleLinkTapHandler = {label2, mention, range in
                
                // Remove the '@' symbol from the username
                let userMention = mention.stringByReplacingOccurrencesOfString("@", withString: "")
                
                // Setup the user query.
                var query:PFQuery!
                query = PFUser.query()
                query.whereKey("username", equalTo: userMention)
                
                // Get the user data object.
                query.getFirstObjectInBackgroundWithBlock({ (userObject, error) -> Void in
                    
                    // Check for errors before passing
                    // the user object to the profile view.
                    
                    if ((error == nil) && (userObject != nil)) {
                        
                        // Open the selected users profile.
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let profView = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
                        profView.passedUser = userObject as? PFUser
                        self.presentViewController(profView, animated: true, completion: nil)
                    }
                })
            }
        }
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 103.0
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // Get the current comment data.
        let commentObject:PFObject = self.commentdata.objectAtIndex(indexPath.row) as! PFObject
        
        // Setup the delete comment button.
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            commentObject.deleteInBackgroundWithBlock({ (success, error) -> Void in
                
                if (success) {
                    
                    // Remove the comment from the array.
                    self.commentdata.removeObjectAtIndex(indexPath.row)
                    
                    // Remove the cell from the table view.
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                
                else {
                    
                    let alert = UIAlertController(title: "Error", message: "The comment has not been deleted (Error: \(error?.localizedDescription))", preferredStyle: .Alert)
                    alert.view.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
                    let next = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alert.addAction(next)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }
        
        // Setup the mention comment button.
        let mentioncomment = UITableViewRowAction(style: .Normal, title: "Mention") { (actiom, indexPath) -> Void in
            
            // Get the username string.
            var userObject: PFUser!
            userObject = commentObject.objectForKey("postedby") as! PFUser!
            userObject.fetchIfNeededInBackgroundWithBlock({ (object, error) -> Void in
                
                if ((object != nil) && (error == nil)) {
                    
                    // Set the comment text view label
                    // with the @user reply + a space.
                    
                    if (self.commentTextView.hasText() == true) {
                        self.commentTextView.text = "\(self.commentTextView.text!) @\((object as! PFUser).username!) "
                    }
                        
                    else {
                        self.commentTextView.text = "@\((object as! PFUser).username!) "
                    }
                    
                    // Show the on screen keyboard.
                    self.commentTextView.becomeFirstResponder()
                }
                
                // Hide the swipe from right cell animation.
                self.performSelector("hideCellButton:", withObject: nil, afterDelay: 0.1)
            })
        }
        
        // Set the button backgrond colour.
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)

        mentioncomment.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)

        
        // Only show the delete button if the comment belongs to the 
        // currently logged in user and conversly, only show the mention
        // button if the comment does not belong to the logged in user.
        
        if ((commentObject.objectForKey("postedby") as! PFUser!).objectId! == PFUser.currentUser()?.objectId!) {
            return [deletestatus]
        }
            
        else {
            return [mentioncomment ]
        }
    }
    
    func hideCellButton(obj: AnyObject) {
        self.tableView.setEditing(false, animated: true)
    }
}
