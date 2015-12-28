//
//  NewsfeedViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import Social
import ActiveLabel

class NewsfeedViewController: UITableViewController, CLWeeklyCalendarViewDelegate, UINavigationBarDelegate, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var activity: UIRefreshControl!
    
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
        // Do any additional setup after loading the view.
        
        // Set all items in the navigation bar
        // to appear in the white tint colour.
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // Create the post "+" button.
        let rightButton: UIButton = UIButton(type: UIButtonType.Custom)
        rightButton.setImage(UIImage(named: "plus"), forState: UIControlState.Normal)
        rightButton.addTarget(self, action: "openPostSection", forControlEvents: UIControlEvents.TouchUpInside)
        rightButton.frame = CGRectMake(0, 0, 53, 31)
                
        // Set the navigation bar background colour.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
        // Add the button to the right section.
        let barButton = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = barButton
        
        // Logo for nav title.
        let logo = UIImage(named: "newsFeedTitle")
        let imageview = UIImageView(image: logo)
        
        // Set the "Calendario" image int he navigation bar.
        self.navigationItem.titleView = imageview
        self.navigationItem.titleView?.contentMode = UIViewContentMode.Center
        self.navigationItem.titleView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Setup the pull to refresh indicator.
        //activity = UIRefreshControl()
        activity.attributedTitle = NSAttributedString(string: "Pull to refresh")
        activity.addTarget(self, action: "LoadData", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        LoadData()
    }
    
    func openPostSection() {
        
        // Open the post section view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("PostView") as! StatusUpdateViewController
        self.presentViewController(viewC, animated: true, completion: nil)
    }
    
    func setRefreshIndicators(state: Bool) {
        
        if (state == true) {
            activity.beginRefreshing()
        }
        
        else {
            activity.endRefreshing()
        }
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
        
        // Start the pull to refresh indicator.
        self.setRefreshIndicators(true)
        
        currentDate = NSDate()
        print("the current date is \(currentDate)")
        
    
        
        
        statausData.removeAllObjects()
        
      
        
        var getstatus:PFQuery = PFQuery(className: "StatusUpdate")
        //getstatus.whereKey("tense", equalTo: "going")
        
        
        getstatus.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            
            // Stop the pull to refresh indicator.
            self.setRefreshIndicators(false)
            
            if error == nil {
                
                for object in objects! {
                    let statusupdate:PFObject = object as! PFObject
                    
                    
                    
                    
                    
                    
                    self.statausData.addObject(statusupdate)
                    
        }
                let array:NSArray = self.statausData.reverseObjectEnumerator().allObjects
                self.statausData = NSMutableArray(array: array)
                
                self.table.reloadData()
                
                
            }
            
            else {
                
            }
        }
   }

    // Tableview delegate methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statausData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 238
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NewsfeedTableViewCell
        
        let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
        
        isDatePassed(statusupdate.createdAt!, date2: NSDate(), ParseID: statusupdate.objectId!)

        
        cell.statusTextView.text = statusupdate.objectForKey("updatetext") as! String
        
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        
        cell.uploaddatelabel.text = statusupdate.objectForKey("dateofevent") as! String
        cell.tenselabel.text = statusupdate.objectForKey("tense") as! String
        cell.locationLabel.text = statusupdate.objectForKey("location") as! String
                
        
        
   
        

        
        
        
        currentobjectID = statusupdate.objectId
        
        
        
        
        
        
        
        
        
        
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
        
        
        
        
        
        
        

        // hastag dectection
        if cell.statusTextView.text.hasPrefix("#")
        {
            print("hastag found")
            
            cell.hashlabel.text = cell.statusTextView.text
            cell.hashlabel.numberOfLines = 0
            cell.hashlabel.hashtagColor = UIColor.flatBlueColor()
            cell.hashlabel.handleHashtagTap({ (hastag) -> () in
                print("hello from cell class")
            })
            
               cell.hashlabel.frame = CGRect(x: 85, y: 75, width: view.frame.width - 30, height: 500)
            cell.addSubview(cell.hashlabel)
        }
        
        else if cell.statusTextView.text.hasPrefix("@")
        {
            print("mention found")
            
            cell.hashlabel.text = cell.statusTextView.text
            cell.hashlabel.numberOfLines = 0
            cell.hashlabel.mentionColor = UIColor.flatGreenColor()
            cell.hashlabel.handleHashtagTap({ (hastag) -> () in
                print("hello from cell class")
            })
            
            cell.hashlabel.frame = CGRect(x: 85, y: 75, width: view.frame.width - 30, height: 500)
            cell.addSubview(cell.hashlabel)

        }
        
            
            
            
                  
        
        
        
        
        
    

        //StartDectingHastags(cell.statusTextView.text)
        
        
        
        
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
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
        
        let label = ActiveLabel()
        
        if text.hasPrefix("#" )
        {
            //dector.decorateTags(text)
           
            
            label.numberOfLines = 0
            label.text = text
            label.textColor = UIColor.orangeColor()
            label.mentionColor = UIColor.greenColor()
            
            label.frame = CGRect(x: 85, y: 75, width: view.frame.width - 30, height: 500)
            
            self.view.addSubview(label)
        }
        else
        {
            label.hidden = true
        }
        
        
        
        
    }
    
    
    
    func isDatePassed(date1:NSDate, date2:NSDate, ParseID: String)
    {
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/d/yy"
        var newdate = dateformatter.stringFromDate(date2)

        
        if date1.timeIntervalSince1970 < date2.timeIntervalSince1970
        {
            print("Date2 has passed")
            
            var query = PFQuery(className: "StatusUpdate")
            query.getObjectInBackgroundWithId(ParseID, block: { (updates:PFObject?, error:NSError?) -> Void in
                if error == nil
                {
                    var aobject:PFObject = updates!
                    
                    print(error)
                    
                    print(aobject.objectForKey("dateofevent") as! String)
                    print(newdate)
                    
                    if aobject.objectForKey("dateofevent") as! String == newdate
                    {
                        print("tense stays")
                        aobject["tense"] = "Currently"
                        aobject.saveInBackground()
                     
                        
                    }
                        
                    if aobject.objectForKey("dateofevent") as! String > newdate
                    {
                        print("going tense")
                        aobject["tense"] = "Going"
                        aobject.saveInBackground()
                    }
                    
                        
                    else
                    {
                        
                    print("tense is going to change")
                    aobject["tense"] = "went"
                    aobject.saveInBackground()
                        
                    }
                    
                }
            })

                    
                }
        
        

        
        
        
    

    
    
    
    
    
    
    

}
    
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // jdhdh
    }
    
    
    func ReportView()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        self.presentViewController(NC, animated: true, completion: nil)
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
            
            
            
        
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
        

        
        let deletestatus = UITableViewRowAction(style: .Normal, title: "Delete") { (actiom, indexPath) -> Void in
              let statusupdate:PFObject = self.statausData.objectAtIndex(indexPath.row) as! PFObject
            
            statusupdate.deleteInBackgroundWithBlock({ (sucess, error) -> Void in
                self.statausData.removeObjectAtIndex(indexPath.row)
                statusupdate.saveInBackground()
                print("deleted")
                self.LoadData()
                
            })
        }
        
        
        
        
        report.backgroundColor = UIColor.flatWhiteColorDark()
        seemore.backgroundColor = UIColor.flatGrayColor()
        deletestatus.backgroundColor = UIColor.flatRedColor()
        
        return [report, seemore, deletestatus]
    }
    
    func Seemore()
    {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
        let NC = UINavigationController(rootViewController: SMVC)
        self.presentViewController(NC, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "comments"
        {
            let vc = segue.destinationViewController as! CommentsViewController
            vc.savedobjectID = currentobjectID
            
        }
    }

}

