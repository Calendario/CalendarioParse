//
//  CommentsViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/27/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentTextView: UITextField!
    
    var commentdata:NSMutableArray = NSMutableArray()
    
    var savedobjectID:AnyObject!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        savedobjectID = defaults.objectForKey("objectid")
        
        print(savedobjectID!)
        
     
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadCommentData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func LoadCommentData()
    {
        commentdata.removeAllObjects()
        
        var getcomments:PFQuery = PFQuery(className: "comment")
        //getcomments.whereKey("statusOBJD", equalTo: String(savedobjectID))
        
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
    
    
    
    
    
    
    @IBAction func SendTapped(sender: AnyObject) {
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
                print("comment posted")
            }
            else
            {
                print(error?.localizedDescription)
            }
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
        
        let comment:PFObject = self.commentdata.objectAtIndex(indexPath.row) as! PFObject
        
        cell.commentTextView.text = comment.objectForKey("commenttext") as! String
        cell.UserLabel.text = comment.objectForKey("postedby") as? String
        
   
        return cell
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
