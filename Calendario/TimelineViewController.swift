//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var postsdata:NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableview: UITableView!
    var user:String!
    
  

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.scrollDirection = .Vertical
        
        calendar.selectDate(NSDate())
        
        self.tableview.delegate = self
        self.tableview.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        print("the date is \(date)")
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MM/dd/yy"
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
}