//
//  LocationSearchTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/5/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

protocol LocateOnTheMap
{
    func locateWithLongitude(_ lon:Double, andLatitude lat:Double, andTitle title: String)
}

class LocationSearchTableViewController: UITableViewController {
    
    var SearchResults:[String]!
    var delegate:LocateOnTheMap!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SearchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete implementation, return the number of rows
        return self.SearchResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = self.SearchResults[(indexPath as NSIndexPath).row]
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        
      let correctedAddress:String! = self.SearchResults[(indexPath as NSIndexPath).row].addingPercentEncoding(withAllowedCharacters: CharacterSet.symbols)
        let url = URL(string:  "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            // 3
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                    
                    let lat = ((((dic["results"] as AnyObject).value(forKey: "geometry") as AnyObject).value(forKey: "location") as AnyObject).value(forKey: "lat") as AnyObject).object(at: 0) as! Double
                    let lon = ((((dic["results"] as AnyObject).value(forKey: "geometry") as AnyObject).value(forKey: "location") as AnyObject).value(forKey: "lng") as AnyObject).object(at: 0) as! Double
                    
                    // Save the selected location name/lat/long (for later usage).
                    let location = self.SearchResults[(indexPath as NSIndexPath).row] as String
                    let defaults = UserDefaults.standard
                    defaults.set(location, forKey: "location")
                    defaults.set(lat, forKey: "locationLat")
                    defaults.set(lon, forKey: "locationLon")
                    defaults.synchronize()
                    
                    // 4
                    self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.SearchResults[(indexPath as NSIndexPath).row] )
                }
            }catch {
                print("Error")
            }
        }) 
        // 5
        task.resume()
    }
    
    func reloadDataWithArray(_ array:[String]){
        self.SearchResults = array
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
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
