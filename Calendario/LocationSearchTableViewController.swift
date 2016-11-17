//
//  LocationSearchTableViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/5/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

protocol LocateOnTheMap {
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

        let correctedAddress = self.SearchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let url = URL(string:"https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
       
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            // 3
            do {
                if data != nil {
                    let dic:NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  NSDictionary
                    
                    // Create the custom dictionary parser class object.
                    var parseObject:locationDictParser!
                    parseObject = locationDictParser()
                    
                    // Parse the dictionary data for the latitude/longitude values.
                    parseObject.parseLocationSearchDict(dic as! [AnyHashable : Any], { (lat, lon) in
                        
                        // Save the selected location name/lat/long (for later usage).
                        let location = self.SearchResults[(indexPath as NSIndexPath).row] as String
                        let defaults = UserDefaults.standard
                        defaults.set(location, forKey: "location")
                        defaults.set(lat, forKey: "locationLat")
                        defaults.set(lon, forKey: "locationLon")
                        defaults.synchronize()
                        
                        // 4
                        self.delegate.locateWithLongitude(lon, andLatitude: lat, andTitle: self.SearchResults[(indexPath as NSIndexPath).row] )
                    })
                }
            } catch {
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
}
