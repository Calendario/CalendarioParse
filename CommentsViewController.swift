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
    
    // See More subview controller.
    var seeMoreSubview:SeeMoreHeaderView!
    var passedInObjectForSeeMoreView: PFObject!
    var passedInImage: UIImage?
    
    // Tableview header set check.
    var headerSetCheck = false
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    @IBOutlet weak var sendbutton: UIButton!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.PostComment()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the status bar to white.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Get the keyboard height when the comment text field is pressed - needed
        // in order to move the comment container view to the correct postion.
     
        NotificationCenter.default.addObserver(self, selector: #selector(CommentsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.commentTextView.delegate = self
        self.commentTextView.autocapitalizationType = .sentences
        
        // Do any additional setup after loading the view.
    
        //let defaults = NSUserDefaults.standardUserDefaults()
        //savedobjectID = defaults.objectForKey("objectid") as! String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LoadCommentData()
        
        // Check if the header view has been set.
        
        if (self.headerSetCheck == false) {
            
            // Setup the see more header view.
            let story_file = UIStoryboard(name: "SeeMoreHeaderUI", bundle: nil)
            self.seeMoreSubview = story_file.instantiateViewController(withIdentifier: "SeeMoreHeaderUI") as! SeeMoreHeaderView
            
            // Create the header view height value.
            var customHeight:CGFloat = 220
            
            // Set the header view height and image.
            
            if (self.passedInImage != nil) {
                customHeight = 440
                self.seeMoreSubview.passedImageOne = self.passedInImage!
            }
            
            // Setup the header container view.
            var headerView:UIView!
            headerView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:customHeight))
            headerView.clipsToBounds = true
            
            // Insert the see more subview as the table header view.
            self.seeMoreSubview.passedInObject = self.passedInObjectForSeeMoreView
            self.addChildViewController(self.seeMoreSubview)
            self.seeMoreSubview.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: customHeight)
            headerView.addSubview(self.seeMoreSubview.view)
            self.tableView.tableHeaderView = headerView
            
            // The header view has been set.
            self.headerSetCheck = true
        }
        
        self.view.bringSubview(toFront: self.commentsContainerView)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title  = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.sendbutton.layer.cornerRadius = 4.0
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        self.navigationItem.leftBarButtonItem = backbutton
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 98.0;
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        // Get the keyboard height.
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        // Raise the comments container view.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.commentsContainerView.transform = CGAffineTransform(translationX: 0.0, y: -keyboardHeight)
        }, completion:nil)
    }
    
    func dismissKeyboard() {
        
        // Hide the keyboard.
        self.commentTextView.resignFirstResponder()
        
        // Lower the comments container view.
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.commentsContainerView.transform = CGAffineTransform(translationX: 0.0, y: 0.0)
        }, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshData() {
        LoadCommentData()
    }
    
    func LoadCommentData()
    {
        commentdata.removeAllObjects()
        
        var getcomments:PFQuery<PFObject>!
        getcomments = PFQuery(className: "comment")
        getcomments.whereKey("statusOBJID", equalTo: savedobjectID!)
        
        getcomments.findObjectsInBackground { (comments: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                if ((comments != nil) && (comments!.count > 0)) {
                    
                    for comment in comments! {
                        self.commentdata.add(comment)
                    }
                    
                    let array:NSArray = self.commentdata.reverseObjectEnumerator().allObjects as NSArray
                    let reverseArray = array.reversed()
                    self.commentdata = NSMutableArray(array: reverseArray)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func bacbuttontapped(_ sender: AnyObject) {
        
        // Hide the keybaord if it has not
        // already been hidden from the view.
        self.dismissKeyboard()
        
        // Close the comments view.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Sendtapped(_ sender: AnyObject) {
        
        self.PostComment()
        // self.refreshData()
    }
    
    func PostComment() {
        
        // Hide the keyboard.
        self.dismissKeyboard()
        
        if (self.commentTextView .hasText) {
            
            // Make sure the commenttext contains all
            // the @user mentions in lowercase.
            ManageUser.correctStringWithUsernames(self.commentTextView.text!, completion: { (correctString) -> Void in
                
                // Setup the comment object.
                var comment: PFObject!
                comment = PFObject(className: "comment")
                comment["postedby"] = PFUser.current()
                comment["statusOBJID"] = String(self.savedobjectID)
                comment["commenttext"] = correctString
                
                // Submit the user comment.
                
                comment.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    // Clear the text field for the next comment.
                    self.commentTextView.text = nil
                    
                    if success {
                        
                        var query: PFQuery<PFObject>!
                        query = PFQuery(className: "StatusUpdate")
                        query.includeKey("user")
                        query.getObjectInBackground(withId: self.savedobjectID, block: { (object, error) -> Void in
                            
                            if error == nil {
                                
                                // Only save the notification if the user recieving
                                // the notification is NOT the same as the logged in user.
                                
                                if (PFUser.current()!.objectId! != (object?.object(forKey: "user") as! PFUser).objectId!) {
                                    
                                    // create push notifcation
                                    let message = "\(PFUser.current()!.username!) has commented on your post"
                                    
                                    // Send the notification.
                                    PFCloud.callFunction(inBackground: "comment", withParameters: ["message" : message, "user" : "\((object!.value(forKey: "user") as! PFUser).objectId!)"])
                                    
                                    // Save the user notification.
                                    ManageUser.saveUserNotification(message, fromUser: PFUser.current()!, toUser: object!.value(forKey: "user") as! PFUser, extType: "comment", extObjectID: String(self.savedobjectID))
                                }
                                
                                // Reload the comments table view.
                                self.refreshData()
                            }
                        })
                    }
                        
                    else {
                        print(error?.localizedDescription)
                    }
                })
            })
        }
            
        else {
            
            // Setup the alert controller.
            let alertController = UIAlertController(title: "No comment", message: "Please type a comment before pressing send.", preferredStyle: .alert)
            
            // Setup the alert actions.
            let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alertController.addAction(cancel)
            
            // Present the alert on screen.
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Table view methods.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentdata.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Prepare the reusable cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentsTableViewCell
        
        // Set the profile picture to a circle.
        cell.userProfileImage.layer.cornerRadius = (cell.userProfileImage.frame.size.width / 2)
        cell.userProfileImage.clipsToBounds = true
        
        // Get the current index news item object.
        let comment:PFObject = self.commentdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
        // Set the comment data objects.
        cell.parentViewController = self
        cell.passedInObject = comment
        
        // Load the username and profile picture.
        cell.loadUserData()
        
        // Set the comment createdAt label.
        DateManager.createDateDifferenceString(comment.createdAt!) { (difference) -> Void in
            cell.createdAtLabel.text = difference
        }
        
        // If the status contains hashtags then highlight them.
        
        if ((cell.commentTextView.text?.hasPrefix("#")) != nil) {
            
            // Highlight the status hashtags.
            cell.commentTextView.hashtagLinkTapHandler = {label, hashtag, range in
                
                // Load in the hashtag data.
                var defaults = UserDefaults.standard
                var hashtagData: NSMutableArray = []
                hashtagData = (((defaults.object(forKey: "HashtagData")) as! NSArray).mutableCopy()) as! NSMutableArray
                
                // Set the correct index number.
                var hashtagIndex = hashtagData[0] as! Int
                hashtagIndex = hashtagIndex + 1
                
                // Add the new hashtag index number/string.
                hashtagData.replaceObject(at: 0, with: hashtagIndex)
                hashtagData.add(hashtag)
                
                // Save the hashtag data.
                defaults = UserDefaults.standard
                defaults.set(hashtagData, forKey: "HashtagData")
                defaults.synchronize()
                
                // Open the hashtag view with status
                // posts containing the selected #hashtag.
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let hashView = sb.instantiateViewController(withIdentifier: "HashtagNav") as! UINavigationController
                self.present(hashView, animated: true, completion: nil)
            }
        }
        
        // If the status contains @mentions then highligh
        // and link them to the open profile view action.
        
        if ((cell.commentTextView.text?.hasPrefix("@")) != nil) {
            
            // Highlight the @username label.
            cell.commentTextView.userHandleLinkTapHandler = {label2, mention, range in
                
                // Remove the '@' symbol from the username
                let userMention = mention.replacingOccurrences(of: "@", with: "")
                
                // Setup the user query.
                var query:PFQuery<PFObject>!
                query = PFUser.query()
                query.whereKey("username", equalTo: userMention)
                
                // Get the user data object.
                query.getFirstObjectInBackground(block: { (userObject, error) -> Void in
                    
                    // Check for errors before passing
                    // the user object to the profile view.
                    
                    if ((error == nil) && (userObject != nil)) {
                        
                        // Open the selected users profile.
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let profView = sb.instantiateViewController(withIdentifier: "My Profile") as! MyProfileViewController
                        profView.passedUser = userObject as? PFUser
                        self.present(profView, animated: true, completion: nil)
                    }
                })
            }
        }
        
        // Set the comment label.
        let commentString = comment.object(forKey: "commenttext") as! String
        cell.commentTextView.text = commentString
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 103.0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Get the current comment data.
        let commentObject:PFObject = self.commentdata.object(at: (indexPath as NSIndexPath).row) as! PFObject
        
        // Setup the delete comment button.
        let deletestatus = UITableViewRowAction(style: .normal, title: "Delete") { (actiom, indexPath) -> Void in
            
            commentObject.deleteInBackground(block: { (success, error) -> Void in
                
                if (success) {
                    
                    // Remove the comment from the array.
                    self.commentdata.removeObject(at: (indexPath as NSIndexPath).row)
                    
                    // Remove the cell from the table view.
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                }
                
                else {
                    
                    let alert = UIAlertController(title: "Error", message: "The comment has not been deleted (Error: \(error?.localizedDescription))", preferredStyle: .alert)
                    alert.view.tintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
                    let next = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alert.addAction(next)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        // Setup the mention comment button.
        let mentioncomment = UITableViewRowAction(style: .normal, title: "Mention") { (actiom, indexPath) -> Void in
            
            // Get the username string.
            var userObject: PFUser!
            userObject = commentObject.object(forKey: "postedby") as! PFUser!
            userObject.fetchIfNeededInBackground(block: { (object, error) -> Void in
                
                if ((object != nil) && (error == nil)) {
                    
                    // Set the comment text view label
                    // with the @user reply + a space.
                    
                    if (self.commentTextView.hasText == true) {
                        self.commentTextView.text = "\(self.commentTextView.text!) @\((object as! PFUser).username!) "
                    }
                        
                    else {
                        self.commentTextView.text = "@\((object as! PFUser).username!) "
                    }
                    
                    // Show the on screen keyboard.
                    self.commentTextView.becomeFirstResponder()
                }
                
                // Hide the swipe from right cell animation.
                self.perform(#selector(CommentsViewController.hideCellButton(_:)), with: nil, afterDelay: 0.1)
            })
        }
        
        // Set the button backgrond colour.
        deletestatus.backgroundColor = UIColor(red: 255/255.0, green: 80/255.0, blue: 79/255.0, alpha: 1.0)
        mentioncomment.backgroundColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
        // Only show the delete button if the comment belongs to the 
        // currently logged in user and conversly, only show the mention
        // button if the comment does not belong to the logged in user.
        
        if ((commentObject.object(forKey: "postedby") as! PFUser!).objectId! == PFUser.current()?.objectId!) {
            return [deletestatus]
        }
            
        else {
            return [mentioncomment ]
        }
    }
    
    func hideCellButton(_ obj: AnyObject) {
        self.tableView.setEditing(false, animated: true)
    }
}
