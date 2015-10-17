//
//  NewsfeedViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController, CLWeeklyCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    
    var statausData:NSMutableArray = NSMutableArray()
    var currentDate:NSDate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButtonItem(sharebutton, animated: true)

        // Do any additional setup after loading the view.
        
    let cal = CLWeeklyCalendarView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 125))
        cal.delegate = self
        
        self.view.addSubview(cal)
        
        self.navigationController?.hidesBarsOnTap = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadData()
    }
    
    
    func dailyCalendarViewDidSelect(date: NSDate!) {
        
        currentDate = date
        print(currentDate)
        //getUpdatesbasedOnTense()
        
        
        
    }
    
    func CLCalendarBehaviorAttributes() -> [NSObject : AnyObject]! {
     
        return [CLCalendarWeekStartDay: 1]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // this method loads the data from parse
    
    func LoadData()
    {
        statausData.removeAllObjects()
        
        var getstatus:PFQuery = PFQuery(className: "StatusUpdate")
        getstatus.whereKey("tense", equalTo: "going")
        
        getstatus.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            if error == nil
            {
                for object in objects!
                {
                    let statusupdate:PFObject = object as! PFObject
                    
                    
                    
                    
                    
                    self.statausData.addObject(statusupdate)
                    
        }
                let array:NSArray = self.statausData.reverseObjectEnumerator().allObjects
                self.statausData = NSMutableArray(array: array)
                
                self.table.reloadData()
                
                
            }
        }
   }

    // Tableview delegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statausData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
        
        cell.statusTextView.text = statusupdate.objectForKey("updatetext") as! String
        
        
        
        var findUser:PFQuery = PFUser.query()!
        
        findUser.whereKey("objectId", equalTo: (statusupdate.objectForKey("user")?.objectId)!)
        
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if let aobject = objects
            {
                let puser = (aobject as NSArray).lastObject as? PFUser
                cell.UserNameLabel.text = puser?.username
            }
        }



        return cell
}
    
    // function that get statuses based on date selected in the calender 
    func getUpdatesbasedOnTense()
    {
        var query = PFQuery(className: "StatusUpdate")
        query.whereKey("tense", equalTo: "going")
        //query.whereKey("tense", equalTo: "currently")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            print("updates found")
            if let objects = objects as [PFObject]!
            {
                for object in objects
                {
                    print(object.createdAt)
                }
            }
        }

        
    }


}
