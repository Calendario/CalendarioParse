//
//  NewsfeedViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Social

class NewsfeedViewController: UIViewController, CLWeeklyCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, FSCalendarDelegate, FSCalendarDataSource{

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sharebutton: UIBarButtonItem!
    
  
    
    
    var statausData:NSMutableArray = NSMutableArray()
    var currentDate = NSDate()
    var statustext:String!
    var selecteddate:NSDate!
    
    var updateText:String!
    
    var currentobjectID:String!
    
    let greenColor =  UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
    
    var reportedID:String!
    
    var likesobjid:String!
    
    var likecount = 0
    
    var likeduser:String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //self.navigationItem.setRightBarButtonItem(sharebutton, animated: true)

        // Do any additional setup after loading the view.
        
        
        let navigationbar = UINavigationBar(frame:  CGRectMake(0, 0, self.view.frame.size.width, 80))
        navigationbar.backgroundColor = UIColor.whiteColor()
        navigationbar.delegate = self
        navigationbar.barTintColor =  UIColor(red:0.17, green:0.58, blue:0.38, alpha:1.0)
        navigationbar.tintColor = UIColor.whiteColor()
        
        // logo for nav title
        
        let logo = UIImage(named: "navtext")
        let imageview = UIImageView(image: logo)
        
        
        // navigation items
        let navitems = UINavigationItem()
        navitems.titleView = imageview
        
        navitems.rightBarButtonItem = sharebutton
        navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)

        
        
        
        
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadData()
    }
    
    
    func dailyCalendarViewDidSelect(date: NSDate!) {
        /*statausData.removeAllObjects()
        
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
            */
        
        
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
        
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        
        
        
        
        
        
        
        
        var findUser:PFQuery = PFUser.query()!
        
        findUser.whereKey("objectId", equalTo: (statusupdate.objectForKey("user")?.objectId)!)
        
        findUser.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error:NSError?) -> Void in
            if let aobject = objects
            {
                let puser = (aobject as NSArray).lastObject as? PFUser
                cell.UserNameLabel.text = puser?.username
                
            }
        }
        
        var getImages:PFQuery = PFUser.query()!
        getImages.whereKey("objectId", equalTo: (statusupdate.objectForKey("user")?.objectId)!)
        getImages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                self.getImageData(objects!, imageview: cell.profileimageview)
            }
            else
            {
                print("error")
            }
        }
        
        
        
        // like button
        
        var getlikes = PFQuery(className: "StatusUpdate")
        
        getlikes.whereKey("likedBy", equalTo: PFUser.currentUser()!)
        getlikes.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects as [PFObject]!
                {
                    for object in objects
                    {
                      print(object.objectId!)
                    if statusupdate.objectId == object.objectId
                    {
                        let filledlikebutton = UIImage(named: "like button filled")
                        cell.LikeButton.setImage(filledlikebutton, forState: .Normal)
                    }
                }
                

                    
                }
            }
        }
        
        

        
        
        
        
        
        
        
        
        
    

        StartDectingHastags(cell.statusTextView.text)
        
       isDatePassed(NSDate(), date2: statusupdate.createdAt!, ParseID: statusupdate.objectId!)
        
        return cell
}
    
    
    
    
    func getImageData(objects:[PFObject], imageview:UIImageView)
    {
        for object in objects
        {
           if let image = object["profileImage"] as! PFFile?
           {
            image.getDataInBackgroundWithBlock({ (ImageData, error) -> Void in
                if error == nil
                {
                    let image = UIImage(data: ImageData!)
                    imageview.image = image
                }
                else
                {
                    imageview.image = UIImage(named: "profile_icon")
                }
            })
            }

            }
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
    
    
    func ReportView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
        
        
    }
    
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
            
            
            
        
        var report = UITableViewRowAction(style: .Normal, title: "Report") { (action, index) -> Void in
            print("report was tapped")
            
            
            
            
            
            

            let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setObject(statusupdate.objectId, forKey: "reported")
            
            self.ReportView()
            
            
            var reportquery = PFQuery(className: "StatusUpdate")
            reportquery.whereKey("updatetext", equalTo: statusupdate.objectForKey("updatetext")!)
            reportquery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                if error == nil
                {
                    print("objects found")
                    
                    if let objects = objects as [PFObject]!
                    {
                        for object in objects
                        {
                            var objID = object.objectId
                            self.reportedID = objID
                        }
                        
                        
                        var reportstatus = PFQuery(className: "StatusUpdate")
                        reportstatus.getObjectInBackgroundWithId(self.reportedID, block: { (status:PFObject?, error:NSError?) -> Void in
                            if error == nil
                            {
                                status!["reported"] = true
                                print("reported")
                                status?.saveInBackground()
                            }
                        })
                        
                        
                        
                        
                        
                        
                    }
                }
            })
            
            
            
            

            
            
            
            
         
        
        }
        let seemore = UITableViewRowAction(style: .Normal, title: "See More") { (action, index) -> Void in
            print("see more was tapped")
            let defaults = NSUserDefaults.standardUserDefaults()
            
            let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
            print(statusupdate)
            
            
            var updatetext = statusupdate.objectForKey("updatetext") as! String
            
            var currentobjectID = statusupdate.objectId
            
            
            print(updatetext)
                        
            
              defaults.setObject(updatetext, forKey: "updatetext")
            defaults.setObject(currentobjectID, forKey: "objectId")
            
            self.Seemore()
            
            
            

        }
        report.backgroundColor = UIColor.flatWhiteColorDark()
        seemore.backgroundColor = UIColor.flatGrayColor()
        
        return [report, seemore]
    }
    
    func Seemore()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
        let NC = UINavigationController(rootViewController: SMVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }

}

