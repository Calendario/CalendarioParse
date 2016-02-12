//
//  ReportTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/26/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class ReportTableViewController: UITableViewController {
    
    @IBOutlet weak var leftbutton: UIBarButtonItem!
    
    var reasonsarray = ["Pornography", "Drugs", "Graphic Violence", "Privacy Invasion"]
    var selectedreason:String = ""
    
    enum Reasons: String {
        
        case Porn = "Pornography"
        case Drugs = "Drugs"
        case GrpahicVio = "Graphic Violence"
        case Privacy = "Privacy"
        case Other = "Other"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
        
        self.navigationItem.title = "Report Status"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Futura-Medium", size: 21.0)!]
        
        self.navigationItem.setLeftBarButtonItem(leftbutton, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasonsarray.count
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DataCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = reasonsarray[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get object id
        let defaults = NSUserDefaults.standardUserDefaults()
        let repotedID =  defaults.objectForKey("reported")
        
        
        switch indexPath.row {
            
            case 0: selectedreason = Reasons.Porn.rawValue
            
            // place objectid in repoted section of parse data
            // the object id will link to the approate update
        
            case 1: selectedreason = Reasons.Drugs.rawValue
            case 2: selectedreason = Reasons.GrpahicVio.rawValue
            case 3: selectedreason = Reasons.Privacy.rawValue
            
            default: selectedreason = Reasons.Other.rawValue
        }
        
        
        var query:PFQuery!
        query = PFQuery(className: "StatusUpdate")
        query.getObjectInBackgroundWithId(repotedID! as! String) { (statusupdate:PFObject?, error:NSError?) -> Void in
            
            if error == nil {
                
                statusupdate!["reported"] = true
                statusupdate!["reportedby"] = PFUser.currentUser()
                statusupdate!["reason"] = self.selectedreason
                statusupdate?.saveInBackground()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    // Setup the alert controller.
                    let alertController = UIAlertController(title: "Report Unsuccessful", message: "The status update has not been reported (\(error!.localizedDescription))", preferredStyle: .Alert)
                    
                    // Setup the alert actions.
                    let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    self.presentViewController(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func leftButtonTapped(sender: AnyObject) {
        
        // Dismiss the view instead of going back to the news feed;
        // SeeMore/Report views are called by other controllers too.
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }
    */
    
    /*
    // Orride to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
