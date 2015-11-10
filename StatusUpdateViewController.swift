//
//  StatusUpdateViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import CoreLocation



class StatusUpdateViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UINavigationBarDelegate {

    @IBOutlet weak var PostButton: UIBarButtonItem!
    
    
    
    @IBOutlet weak var datepicker: UIDatePicker!
    
    
    
    @IBOutlet weak var charlabel: UILabel!
    
    
    @IBOutlet weak var TenseControl: UISegmentedControl!
    
    @IBOutlet weak var statusUpdateTextField: UITextView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    @IBOutlet weak var statusImageview: UIImageView?
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
    var imagedata:NSData?
    var postingImage = false

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationbar = UINavigationBar(frame:  CGRectMake(0, 0, self.view.frame.size.width, 55))
        navigationbar.backgroundColor = UIColor.whiteColor()
        navigationbar.delegate = self
        navigationbar.barTintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha: 1)
        navigationbar.tintColor = UIColor.whiteColor()
        
        // logo for nav title 
        
        let logo = UIImage(named: "navtext")
        let imageview = UIImageView(image: logo)
        
        
        // navigation items
        let navitems = UINavigationItem()
        navitems.titleView = imageview
        
        navitems.rightBarButtonItem = PostButton
        navitems.leftBarButtonItem = backbutton
        
        // set nav items in nav bar
        navigationbar.items = [navitems]
        self.view.addSubview(navigationbar)
        
        
        statusUpdateTextField.layer.borderColor = UIColor.blackColor().CGColor
        
    
    
        
    
        

        // Do any additional setup after loading the view.
        statusUpdateTextField.delegate = self
        dateLabel.hidden = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.TenseControl.tintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha:1)
        
        // save current status id in NSUserDefaults incase its going to be used for a comment
        
        
        
        // gesture reconizer for date picker
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "DatePickerAppear")
        
        dateLabel.userInteractionEnabled = true
        
        dateLabel.addGestureRecognizer(tapgesture)
        
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
    
    func DatePickerAppear()
    {
        print("tapped")
        datepicker.hidden = false
        dateLabel.hidden = true
   
    }
    
    
    
    
    
    func PostStatusUpdate()
    {
       var dateformatter = NSDateFormatter()
        
        
       
        
        
        if statusImageview?.image != nil
        {
            postingImage = true
            var statusupdatewithimage = PFObject(className: "StatusUpdate")
            statusupdatewithimage["updatetext"] = statusUpdateTextField.text
            statusupdatewithimage["user"] = PFUser.currentUser()
            statusupdatewithimage["dateofevent"] = dateLabel.text
            statusupdatewithimage["ID"] = Int(statusID)
            statusupdatewithimage["tense"] = currenttense
            statusupdatewithimage["location"] = LocationLabel.text
            // image posting
            imagedata = UIImageJPEGRepresentation(((statusImageview?.image))!, 0.5)
            let imagefile = PFFile(name: "image.jpg", data: imagedata!)
            statusupdatewithimage["image"] = imagefile!
            // saves object in background
            statusupdatewithimage.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
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
        else
        {
            var statusupdate = PFObject(className: "StatusUpdate")
            statusupdate["updatetext"] = statusUpdateTextField.text
            statusupdate["user"] = PFUser.currentUser()
            statusupdate["dateofevent"] = dateLabel.text
            statusupdate["ID"] = Int(statusID)
            statusupdate["tense"] = currenttense
            statusupdate["location"] = LocationLabel.text
            
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
    
    @IBAction func backbuttonTapped(sender: AnyObject) {
        GotoNewsfeed()
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
        var photo = UIImagePickerController()
        dispatch_async(dispatch_get_main_queue()) {
            photo.delegate = self
            photo.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            photo.allowsEditing = false
            self.presentViewController(photo, animated: true, completion: nil)
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
    
    
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }
    
    
    // image picker delegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        statusImageview?.image = image
        
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