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
    }
    
    
    func dailyCalendarViewDidSelect(date: NSDate!) {
        print(date)
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
        getstatus.findObjectsInBackgroundWithBlock { (objects:[PFObject]? , error:NSError?) -> Void in
            if error == nil
            {
            }
        }
    }

    // Tableview delegate methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // add array later
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        return cell
    }
}
