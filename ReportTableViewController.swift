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
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
        
        self.navigationItem.title = "Report Status"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "SFUIDisplay-Regular", size: 20)!]
        
        self.navigationItem.setLeftBarButton(leftbutton, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasonsarray.count
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = reasonsarray[(indexPath as NSIndexPath).row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // get object id
        let defaults = UserDefaults.standard
        let repotedID =  defaults.object(forKey: "reported")
        
        
        switch (indexPath as NSIndexPath).row {
            
            case 0: selectedreason = Reasons.Porn.rawValue
            
            // place objectid in repoted section of parse data
            // the object id will link to the approate update
        
            case 1: selectedreason = Reasons.Drugs.rawValue
            case 2: selectedreason = Reasons.GrpahicVio.rawValue
            case 3: selectedreason = Reasons.Privacy.rawValue
            
            default: selectedreason = Reasons.Other.rawValue
        }
        
        
        var query:PFQuery<PFObject>!
        query = PFQuery(className: "StatusUpdate")
        
        query.getObjectInBackground(withId: repotedID! as! String) { (statusupdate: PFObject?, error: Error?) in
            
            if error == nil {
                
                statusupdate!["reported"] = true
                statusupdate!["reportedby"] = PFUser.current()
                statusupdate!["reason"] = self.selectedreason
                statusupdate?.saveInBackground()
                
                self.dismiss(animated: true, completion: nil)
            }
                
            else {
                
                DispatchQueue.main.async(execute: {
                    
                    // Setup the alert controller.
                    let alertController = UIAlertController(title: "Report Unsuccessful", message: "The status update has not been reported (\(error!.localizedDescription))", preferredStyle: .alert)
                    
                    // Setup the alert actions.
                    let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    alertController.addAction(cancel)
                    
                    // Present the alert on screen.
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func leftButtonTapped(_ sender: AnyObject) {
        
        // Dismiss the view instead of going back to the news feed;
        // SeeMore/Report views are called by other controllers too.
        self.dismiss(animated: true, completion: nil)
    }
}
