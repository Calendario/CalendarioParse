//
//  PrivateMessageChatView.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 26/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class PrivateMessageChatView: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: UI OBJECTS.
    @IBOutlet weak var chatList:UITableView!
    
    //MARK: DATA OBJECTS.
    internal var passedChatID:String!
    var messageData:NSMutableArray = NSMutableArray()
    
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: TABLEVIEW METHODS.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a new table view message thread cell.
        let cell:ChatCell = self.chatList.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell!
        
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
