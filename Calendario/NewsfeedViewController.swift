//
//  NewsfeedViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class NewsfeedViewController: UIViewController, CLWeeklyCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate{

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    
  
    
    
    var statausData:NSMutableArray = NSMutableArray()
    var currentDate = NSDate()
    var statustext:String!
    var selecteddate:NSDate!
    
    var updateText:String!
    
    var currentobjectID:String!
    
    let greenColor =  UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    //self.navigationItem.setRightBarButtonItem(sharebutton, animated: true)

        // Do any additional setup after loading the view.
        
    let cal = CLWeeklyCalendarView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 120))
        cal.delegate = self
        
        self.view.addSubview(cal)
        
        print(statausData.count)
        
        
        
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //LoadData()
    }
    
    
    func dailyCalendarViewDidSelect(date: NSDate!) {
        statausData.removeAllObjects()
        
       let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yy"
        var newdate = dateformatter.stringFromDate(date)
        
        
        
        var getdates:PFQuery = PFQuery(className: "StatusUpdate")
        getdates.whereKey("dateofevent", equalTo: newdate)
        print("passed date is \(String(newdate))")
        
        
        getdates.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            if error == nil
            {
               // print(objects!.count)
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
        currentDate = NSDate()
        print("the current date is \(currentDate)")
        
    
        
        
        statausData.removeAllObjects()
        
      
        
        var getstatus:PFQuery = PFQuery(className: "StatusUpdate")
        //getstatus.whereKey("tense", equalTo: "going")
        
        
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


        StartDectingHastags(cell.statusTextView.text)
        
       isDatePassed(statusupdate.createdAt!, date2: NSDate(), ParseID: statusupdate.objectId!)
        
        return cell
}
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
        
        print(statusupdate.objectId!)
        currentobjectID = statusupdate.objectId
        print("the current object id is \(currentobjectID)")
        
        // storing the object id in NSUserDefaults 
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(statusupdate.objectId, forKey: "objectid")
    }

    // function that dectects hastags 
    
    func StartDectingHastags(text:String)
    {
        let dector = CalHashTagDetector()
        
        dector.decorateTags(text)
    }
    
    
    
    func isDatePassed(date1:NSDate, date2:NSDate, ParseID: String)
    {
        if date1.timeIntervalSince1970 < date2.timeIntervalSince1970
        {
            print("Date1 has passed")
            
            var query = PFQuery(className: "StatusUpdate")
            query.getObjectInBackgroundWithId(ParseID, block: { (updates:PFObject?, error:NSError?) -> Void in
                if error == nil
                {
                    var aobject:PFObject = updates!
                    
                    print(error)
                    
                    print("tense is going to change")
                    aobject["tense"] = "went"
                    aobject.saveInBackground()
                }
            })

                    
                }
        
        
        
    

    
    
    
    
    
    
    

}
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // jdhdh
    }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            print("report was tapped")
         
        
        }
        report.backgroundColor = UIColor.grayColor()
        return [report]
    }
}
