//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    var postsdata:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableview: UITableView!
    
    var currentObjectid:String!
    
     let likebuttonfilled = UIImage(named: "like button filled")
    
    var dateofevent:String!
    
    var b:Bool = false
    var eventsarray = [String]()
    
    
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.scrollDirection = .Horizontal
        
    
        
        self.tableview.delegate = self
        self.tableview.dataSource = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        
       



        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        print("the date is \(date)")
        

        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/d/yy"
        var newdate = dateformatter.stringFromDate(date)
        
        
        
        var getdates:PFQuery = PFQuery(className: "StatusUpdate")
        getdates.whereKey("dateofevent", equalTo: newdate)
        print("passed date is \(String(newdate))")
        getdates.includeKey("user")

        
        postsdata.removeAllObjects()
        
        getdates.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
                        if error == nil
            {
                // print(objects!.count)
                for object in objects!
                {
                    let statusupdate:PFObject = object as! PFObject
                    self.postsdata.addObject(statusupdate)
                    self.b = true
                    
                
                
                    
                    
                }
                
                let array:NSArray = self.postsdata.reverseObjectEnumerator().allObjects
                self.postsdata = NSMutableArray(array: array)
                self.tableview.reloadData()
                
    }
        }
    }
    
    func getImageData(objects:[PFObject], imageView:UIImageView)
    {
        for object in objects
        {
            if let image = object["profileImage"] as! PFFile?
            {
                image.getDataInBackgroundWithBlock({ (imagedata, error) -> Void in
                    if error == nil
                    {
                        let image = UIImage(data: imagedata!)
                        imageView.image = image
                    }
                    else
                    {
                        imageView.image = UIImage(named: "profile_icon")
                    }
                })
            }
        }
    }
    
    func calendar(calendar: FSCalendar!, hasEventForDate date: NSDate!) -> Bool {
        
        var datesArray:[NSDate]!
        var eventdate:String!
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/d/yy"
        var newdate = dateformatter.stringFromDate(date)
        var query = PFQuery(className: "StatusUpdate")
        query.whereKey("dateofevent", equalTo: newdate)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                if let objects = objects
                {
                    for object in objects
                    {
                        //print(object.valueForKey("dateofevent") as! String)
                        
                        eventdate = object.valueForKey("dateofevent") as! String
                        print(eventdate)
                        
                        datesArray = [dateformatter.dateFromString(eventdate)!]
                        print(datesArray)
                        
                        calendar.selectDate(dateformatter.dateFromString(eventdate))
                        
                        
                        if datesArray.contains(calendar.selectedDate)
                        {
                            //self.b = true
                            print(self.b)
                            
                        }
                        else
                        {
                            self.b = false

                        }
                            
                        
                        
                        
                        
                    }
                    
                }
                
                    
                    
                    
                }
                print(self.b)
            }
        
        return b
        
    }
    

    
        
    





    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsdata.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("TimelineCell") as! TimeLineTableViewCell
        let status:PFObject = self.postsdata.objectAtIndex(indexPath.row) as! PFObject
        cell.userLabel.text = status.valueForKey("user")?.username!
        cell.tenseLabel.text = status.valueForKey("tense") as! String
        cell.updateTextView.text = status.valueForKey("updatetext") as! String
        currentObjectid = status.objectId
          dateofevent = status.valueForKey("dateofevent") as! String
        

        
        var likes = status.valueForKey("likes") as? Int
        
        if likes >= 1
        {
            cell.likeButton.setImage(likebuttonfilled, forState: .Normal)
        }
        
        cell.profileimageview.layer.cornerRadius = (cell.profileimageview.frame.size.width / 2)
        cell.profileimageview.clipsToBounds = true
        
        var getimages:PFQuery = PFUser.query()!
        getimages.whereKey("objectId", equalTo: (status.objectForKey("user")?.objectId)!)
        getimages.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil
            {
                self.getImageData(objects!, imageView: cell.profileimageview)
            }
            else
            {
                print("error")
            }
        }
        
        
        
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "timelineComments"
        {
            let vc = segue.destinationViewController as! CommentsViewController
            vc.savedobjectID = currentObjectid
        }
    }
}