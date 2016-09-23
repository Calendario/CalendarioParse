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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let navigationbar = UINavigationBar(frame:  CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64))
        navigationbar.backgroundColor = UIColor.white
        navigationbar.delegate = self
        navigationbar.barTintColor = UIColor(red: 33/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        navigationbar.isTranslucent = false
        navigationbar.tintColor = UIColor.white
        let navitems = UINavigationItem()
        navitems.titleView?.contentMode = UIViewContentMode.center
        navitems.titleView?.contentMode = UIViewContentMode.scaleAspectFit
        
        backButton.title = nil
        backButton.image = UIImage(named: "back_button.png")
        
        navitems.setRightBarButton(searchButton, animated: true)
        navitems.setLeftBarButton(backButton, animated: true)
         navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)
        
        self.googleMapsView = GMSMapView(frame: self.mapViewContainer.frame)
        self.view.addSubview(self.googleMapsView)
        searchResultsController = LocationSearchTableViewController()
        searchResultsController.delegate = self
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10)
            self.googleMapsView.camera = camera
            
            marker.title = title
            marker.map = self.googleMapsView
            
            // Save the location name/coordinates (for the search
            // filter view controller's location settings).
            let defaults = UserDefaults.standard
            defaults.set(title, forKey: "filterLocationName")
            defaults.set(lat, forKey: "filterLocationLat")
            defaults.set(lon, forKey: "filterLocationLon")
            defaults.synchronize()
            // Please do NOT delete the above code - Dan.
        }
    }
    
    @IBAction func ShowSearchBarController(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results: [GMSAutocompletePrediction]?, error:Error?) in
            
            self.resultsArray.removeAll()
            
            if (error == nil) {
                
                if results == nil {
                    return
                } else {
                    
                    for result in results! {
                        
                        var data: GMSAutocompletePrediction!
                        data = result
                        self.resultsArray.append(data.attributedFullText.string)
                    }
                }
            }
            
            self.searchResultsController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    @IBAction func Backtapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
