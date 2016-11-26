//
//  PrivateMessages.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 17/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

class PrivateMessages: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: UI OBJECTS.
    @IBOutlet weak var threadList: UITableView!
    
    //MAKR: DATA OBJECTS.
    var messageData:NSMutableArray = NSMutableArray()
    var messageUsers:NSMutableArray = NSMutableArray()
    
    //MARK: BUTTONS.
    
    @IBAction func goBack(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // View Did Appear method.
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the private messages.
        self.loadPrivateMessages()
    }
    
    //MARK: DATA METHODS.
    
    func loadPrivateMessages() {
        
        // Setup the private message query.
        var queryPM:PFQuery<PFObject>!
        queryPM = PFQuery(className: "privateMessages")
        queryPM.whereKey("groupUsers", contains: PFUser.current()?.objectId!)
        queryPM.addAscendingOrder("updatedAt")
        
        // Load in the user's private message threads.
        queryPM.findObjectsInBackground { (threadObjects, error: Error?) in
            
            if (error == nil) {
                
                var groupMessages:NSMutableArray!
                groupMessages = NSMutableArray()
                
                var groupUsers:NSMutableArray!
                groupUsers = NSMutableArray()
                
                for object in threadObjects! {
                    
                    print(object)
                    
                    self.messageData.add(threadObjects)
                    groupMessages.add((object.value(forKey: "groupMessages") as! NSArray).lastObject!)
                    
                    for user in (object.value(forKey: "groupUsers") as! NSArray) {
                        
                        // Only add other users.
                        
                        if ((user as! String).contains((PFUser.current()?.objectId!)!) == false) {
                            groupUsers.add(user as! String)
                        }
                    }
                }
                
                // Reset the data/message arrays.
                self.messageData.removeAllObjects()
                self.messageUsers.removeAllObjects()
                
                // Copy in the new data to the arrays.
                self.messageData = groupMessages.mutableCopy() as! NSMutableArray
                self.messageUsers = groupUsers.mutableCopy() as! NSMutableArray
                
                // Refresh the table view.
                self.threadList.reloadData()
            }
        }
    }
    
    //MARK: TABLEVIEW METHODS.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a new table view message thread cell.
        let cell:ThreadCell = self.threadList.dequeueReusableCell(withIdentifier: "ThreadCell") as! ThreadCell!
        
        var userQuery:PFQuery<PFObject>!
        userQuery = PFUser.query()!
        userQuery.whereKey("objectId", equalTo: "\(self.messageUsers[indexPath.row])")
        
        print("\(self.messageUsers[indexPath.row])")
        
        userQuery.getFirstObjectInBackground { (userData, error: Error?) in
            
            if (error == nil) {
                
                cell.profileName.text = userData?.value(forKey: "username") as! String?
                
                if (userData?.object(forKey: "profileImage") == nil) {
                    cell.profileImage.image = UIImage(named: "default_profile_pic.png")
                }
                    
                else {
                    
                    let userImageFile = userData?["profileImage"] as! PFFile
                    userImageFile.getDataInBackground(block: { (imageData: Data?, error: Error?) in
                        
                        if (error == nil) {
                            
                            // Check the profile image data first.
                            let profileImage = UIImage(data:imageData!)
                            
                            if ((imageData != nil) && (profileImage != nil)) {
                                cell.profileImage.image = profileImage
                            } else {
                                cell.profileImage.image = UIImage(named: "default_profile_pic.png")
                            }
                            
                        } else {
                            cell.profileImage.image = UIImage(named: "default_profile_pic.png")
                        }
                    })
                }
            }
        }
        
        var queryLatestMessage:PFQuery<PFObject>!
        queryLatestMessage = PFQuery(className: "privateMessagesMedia")
        queryLatestMessage.whereKey("objectId", equalTo: self.messageData[indexPath.row])
        
        queryLatestMessage.getFirstObjectInBackground { (messageData, error: Error?) in
            
            if (error == nil) {
                
                if (messageData?.value(forKey: "messageText") != nil) {
                    cell.latestMessage.text = messageData?.value(forKey: "messageText") as! String!
                } else {
                    cell.latestMessage.text = "Attachment - Photo"
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
