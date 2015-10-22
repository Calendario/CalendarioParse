//
//  StatusUpdateViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import CoreLocation



class StatusUpdateViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var PostButton: UIBarButtonItem!
    
    
    
    @IBOutlet weak var datepicker: UIDatePicker!
    
    
    
    @IBOutlet weak var charlabel: UILabel!
    
    
    @IBOutlet weak var TenseControl: UISegmentedControl!
    
    @IBOutlet weak var statusUpdateTextField: UITextView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    
    // tense
    var tensenum:Int!

    enum Tense: String
    {
        case going = "going"
        case went = "went"
        case currently = "currently"
        
    }
    
    var currenttense: String! = " "
    
    
    
    
    
    
    
    //creates a id number for each status update
    var statusID = arc4random()
    
    
    // location 
    let locationManager = CLLocationManager()
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.setRightBarButtonItem(PostButton, animated: true)
        statusUpdateTextField.delegate = self
        dateLabel.hidden = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.TenseControl.tintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha:1)

      
        
     
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func setDate()
    {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateLabel.hidden = false
        dateLabel.text = dateformatter.stringFromDate(datepicker.date)
        datepicker.hidden = true
        
    }
    
    @IBAction func datePickerChanged(sender: AnyObject) {
        
        setDate()
    }
    
    
    
    
    func PostStatusUpdate()
    {
       var dateformatter = NSDateFormatter()
        
        var statusupdate = PFObject(className: "StatusUpdate")
        statusupdate["updatetext"] = statusUpdateTextField.text
        statusupdate["user"] = PFUser.currentUser()
        statusupdate["dateofevent"] = dateLabel.text
        statusupdate["ID"] = Int(statusID)
        statusupdate["tense"] = currenttense
        statusupdate["location"] = LocationLabel.text
        
        
        
        
        // saves object in background
        statusupdate.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if success
            {
                print("Update saved")
            }
            else
            {
                // prints error
                print(error?.localizedDescription)
            }
        }
    }
    
    
    @IBAction func tenseControlchanged(sender: UISegmentedControl) {
        switch TenseControl.selectedSegmentIndex
        {
        case 0:
            currenttense = Tense.going.rawValue
            tensenum = 1
        case 1:
            currenttense = Tense.went.rawValue
            tensenum = 2
        case 2:
           currenttense = Tense.currently.rawValue
            tensenum = 3
        default:
            print("error")
        }
    }
    
    
    
    // posts update
    
    
    @IBAction func PostTapped(sender: AnyObject) {
        PostStatusUpdate()
    }
    
    
    
    
    // camera controls
    
    
    @IBAction func CameraTapped(sender: AnyObject) {
        var camera = UIImagePickerController()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            camera.delegate = self
            camera.sourceType = UIImagePickerControllerSourceType.Camera
            camera.allowsEditing = false
            self.presentViewController(camera, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func VideoTapped(sender: AnyObject) {
        var camera = UIImagePickerController()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            camera.delegate = self
            
        }
    }
   
    
    
    
    
    
    // UITextfield delegate methods
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newLength:Int = (statusUpdateTextField.text as NSString).length + (text as NSString).length - range.length
        var remainingchars:Int = 400 - newLength
        charlabel.text = "\(remainingchars)"
        return (newLength > 400) ? false:true
    }
    
    // core location delegate methods
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error:NSError?) -> Void in
            if error != nil
            {
                if let pm = placemarks?.first
                {
                    self.DisplayLocationInfo(pm)
                }
                else
                {
                    print("error with data")
                }
            }
        }
    }
    
    
    func DisplayLocationInfo(placemark:CLPlacemark)
    {
        self.locationManager.stopUpdatingLocation()
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
        
        LocationLabel.text = placemark.country
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
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
