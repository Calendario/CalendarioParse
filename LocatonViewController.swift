//
//  LocatonViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/5/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import GoogleMaps

class LocatonViewController: UIViewController, UINavigationBarDelegate, LocateOnTheMap, UISearchBarDelegate {
    
    var searchResultsController:LocationSearchTableViewController!
    var resultsArray = [String]()
    var googleMapsView:GMSMapView!

    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigationbar = UINavigationBar(frame:  CGRectMake(0, 0, self.view.frame.size.width, 64))
        navigationbar.backgroundColor = UIColor.whiteColor()
        navigationbar.delegate = self
        navigationbar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        navigationbar.translucent = false
        navigationbar.tintColor = UIColor.whiteColor()
        let navitems = UINavigationItem()
        navitems.titleView?.contentMode = UIViewContentMode.Center
        navitems.titleView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        
        navitems.setRightBarButtonItem(searchButton, animated: true)
        navitems.setLeftBarButtonItem(backButton, animated: true)
         navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)
        
        self.googleMapsView = GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultsController = LocationSearchTableViewController()
        searchResultsController.delegate = self
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 10)
            self.googleMapsView.camera = camera
            
            marker.title = title
            marker.map = self.googleMapsView
        }
    }
    
    @IBAction func ShowSearchBarController(sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:NSError?) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            for result in results! {
                
                if let result = result as? GMSAutocompletePrediction {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultsController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    @IBAction func Backtapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
