//
//  PrivateMessages.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 17/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse

class PrivateMessages: UITableViewController {
    
    //MAKR: DATA OBJECTS.
    var messageData:NSMutableArray = NSMutableArray()
    var messageTitles:NSMutableArray = NSMutableArray()
    
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
        
        // Load in the user's private message threads.
        queryPM.findObjectsInBackground { (object, error: Error?) in
            
            if (error == nil) {
                
                if (object!.count > 0) {
                    
                    
                }
            }
        }
    }
    
    func loadMessageTitles() {
        
        
    }
    
    //MARK: TABLEVIEW METHODS.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a new table view message thread cell.
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "ThreadCell") as UITableViewCell!
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
