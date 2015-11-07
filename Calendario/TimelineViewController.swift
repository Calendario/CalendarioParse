//
//  TimelineViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/6/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.scrollDirection = .Vertical
        
        calendar.selectDate(NSDate())

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
        
        
        getdates.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            if error == nil
            {
                // print(objects!.count)
                for object in objects!
                {
                    let statusupdate:PFObject = object as! PFObject
                    print(statusupdate.objectId)
                    

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
}
}
}