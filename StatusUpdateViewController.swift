//
//  StatusUpdateViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import CoreLocation

class StatusUpdateViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var PostButton: UIBarButtonItem!
    @IBOutlet var dateTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var dateContainer: UIView!
    
    @IBOutlet weak var containerView: UIView!
  //  @IBOutlet weak var checkinbutton: UIButton!
    
    @IBOutlet weak var datepicker: UIDatePicker!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    @IBOutlet weak var charlabel: UILabel!
    
    
    @IBOutlet weak var TenseControl: UISegmentedControl!
    
    @IBOutlet weak var statusUpdateTextField: UITextView!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var backbutton: UIBarButtonItem!
    
    @IBOutlet weak var statusImageview: UIImageView?
    @IBOutlet weak var rsvpSwitch: UISwitch!
    
    // Image upload check.
    var imageCheck = false
    
    let deafaults = NSUserDefaults()
    // tense
    var tensenum:Int!
    
    enum Tense: String
    {
        case going = "Going"
        case went = "Went"
        case currently = "Currently"
        
    }
    
    var currenttense: String! = "Currently"
    
    var viewGestureRecognizer: UITapGestureRecognizer!
    
    var locationtapReconizer:UITapGestureRecognizer!
    
    var shortStyleDateToBeSaved: String = ""
    
    //creates a id number for each status update
    var statusID = arc4random()
    
    
    // location
    let locationManager = CLLocationManager()
    var imagedata:NSData?
    var postingImage = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        editToolbar.barStyle = UIBarStyle.Default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "textViewDismissKeyboard")
        ]
        
        editToolbar.sizeToFit()
        self.statusUpdateTextField.inputAccessoryView = editToolbar
        
        statusUpdateTextField.layer.borderColor = UIColor.blackColor().CGColor
        TenseControl.selectedSegmentIndex = 2
        
        // Do any additional setup after loading the view.
        statusUpdateTextField.delegate = self
        dateLabel.hidden = false
        datepicker.hidden = true
        datePickerContainer.hidden = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.TenseControl.tintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha:1)
        self.datePickerContainer.layer.cornerRadius = 10.0
        self.datepicker.layer.cornerRadius = 10.0
        self.visualEffectView.layer.cornerRadius = 10.0
        self.datePickerContainer.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.datePickerContainer.layer.borderWidth = 1.0
        self.datePickerContainer.layoutIfNeeded()
        
        statusImageview!.layer.cornerRadius = 4.0
        statusImageview!.clipsToBounds = true
        
        // save current status id in NSUserDefaults incase its going to be used for a comment
        
        // gesture reconizer for date picker
        
        let tapgesture = UITapGestureRecognizer(target: self, action: "DatePickerAppear")
        
        dateLabel.userInteractionEnabled = true
        
        dateLabel.addGestureRecognizer(tapgesture)
        
        viewGestureRecognizer = UITapGestureRecognizer(target: self, action: "setDate")
        containerView.addGestureRecognizer(viewGestureRecognizer)
        viewGestureRecognizer.enabled = false
        
        
        locationtapReconizer = UITapGestureRecognizer(target: self, action: "LocationlabelTapped")
        
        LocationLabel.userInteractionEnabled = true
        
        LocationLabel.addGestureRecognizer(locationtapReconizer)
        
        
        // dismisses keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        deafaults.synchronize()
        
        var location = deafaults.valueForKey("location") as? String
        print(location)
        
        if location == nil
        {
            //LocationLabel.text = "No Location"
            //LocationLabel.textColor = UIColor.lightGrayColor()
        }
        else
        {
            LocationLabel.text = location
            //checkinbutton.hidden = true
            //LocationLabel.text = location as! String
            //LocationLabel.textColor = UIColor.darkGrayColor()
        }
        
        
        
    }
    
    func textViewDismissKeyboard() {
        self.statusUpdateTextField.resignFirstResponder()
    }

    func setDate()
    {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateformatter.dateFormat = "M/d/yy"
        dateformatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let dateformatter2 = NSDateFormatter()
        dateformatter2.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformatter2.timeZone = NSTimeZone(abbreviation: "UTC")
        
        shortStyleDateToBeSaved = dateformatter.stringFromDate(datepicker.date)
        dateLabel.hidden = false
        dateLabel.text = dateformatter2.stringFromDate(datepicker.date)
        print(dateLabel)
        datepicker.hidden = true
        datePickerContainer.hidden = true
        dateLabel.textColor = UIColor.darkGrayColor()
        
        changeSegmentControl(datepicker.date)
        
        viewGestureRecognizer.enabled = false
    }
    
    func changeSegmentControl (dateSelected: NSDate) {
        
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateformatter.dateFormat = "M/d/yy"
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        timeFormatter.dateFormat = "HH"
        
        let currentDate = NSDate()
        let currentDateString = dateformatter.stringFromDate(currentDate)
        let currentTimeString = timeFormatter.stringFromDate(currentDate)
        let dateSelectedString = dateformatter.stringFromDate(dateSelected)
        let selectedTimeString = timeFormatter.stringFromDate(dateSelected)
        
        if (currentDateString == dateSelectedString) && (currentTimeString == selectedTimeString) {
            TenseControl.selectedSegmentIndex = 2
        }
        else if currentDate.compare(dateSelected) == NSComparisonResult.OrderedDescending {
            TenseControl.selectedSegmentIndex = 1
        }
        else if currentDate.compare(dateSelected) == NSComparisonResult.OrderedAscending{
            TenseControl.selectedSegmentIndex = 0
        }
        
        tenseControlchanged()

    }
    
    
    @IBAction func datePickerChanged(sender: AnyObject) {
        changeSegmentControl(datepicker.date)
    }
    
    func DatePickerAppear()
    {
        // gesture reconizer for date picker
        viewGestureRecognizer.enabled = true

        datepicker.hidden = false
        dateLabel.hidden = true
        datePickerContainer.hidden = false
    }
    
    func LocationlabelTapped()
    {
        //checkinbutton.hidden = false
        
        let locationReference =  self.storyboard!.instantiateViewControllerWithIdentifier("LocationVC") as UIViewController!
        self.presentViewController(locationReference, animated: true, completion: nil)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func PostStatusUpdate() {
        
        var dateformatter = NSDateFormatter()
        
        // Make sure the updatetext contains all
        // the @user mentions in lowercase.
        ManageUser.correctStringWithUsernames(self.statusUpdateTextField.text!, completion: { (correctString) -> Void in
            
            if ((self.statusImageview?.image != nil) && (self.imageCheck == true)) {
                
                self.postingImage = true
                
                var statusupdatewithimage: PFObject!
                statusupdatewithimage = PFObject(className: "StatusUpdate")
                statusupdatewithimage["updatetext"] = correctString
                statusupdatewithimage["user"] = PFUser.currentUser()
                statusupdatewithimage["dateofevent"] = self.shortStyleDateToBeSaved
                statusupdatewithimage["ID"] = Int(self.statusID)
                statusupdatewithimage["tense"] = self.currenttense
                statusupdatewithimage["location"] = self.LocationLabel.text
                statusupdatewithimage["likesarray"] = []
                
                if (self.rsvpSwitch.on == true) {
                    statusupdatewithimage["privateRsvp"] = true
                }
                    
                else if (self.rsvpSwitch.on == false){
                    statusupdatewithimage["privateRsvp"] = false
                }

                
                // image posting
                self.imagedata = UIImageJPEGRepresentation(((self.statusImageview?.image))!, 0.5)
                let imagefile = PFFile(name: "image.jpg", data: self.imagedata!)
                statusupdatewithimage["image"] = imagefile!
                // saves object in background
                statusupdatewithimage.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                    
                    if success {
                        print("Update saved")
                    }
                        
                    else {
                        // prints error
                        print(error?.localizedDescription)
                    }
                }
            }
                
            else {
                
                var statusupdate: PFObject!
                statusupdate = PFObject(className: "StatusUpdate")
                statusupdate["updatetext"] = correctString
                statusupdate["user"] = PFUser.currentUser()
                statusupdate["dateofevent"] = self.shortStyleDateToBeSaved
                statusupdate["ID"] = Int(self.statusID)
                statusupdate["tense"] = self.currenttense
                statusupdate["location"] = self.LocationLabel.text
                statusupdate["likesarray"] = []
                
                if (self.rsvpSwitch.on == true) {
                    statusupdate["privateRsvp"] = true
                }
                    
                else if (self.rsvpSwitch.on == false){
                    statusupdate["privateRsvp"] = false
                }
                

                
                statusupdate.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                    
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                        
                    else {
                        // prints error
                        print(error?.localizedDescription)
                    }
                }
            }
        })
    }
    
    func tenseControlchanged () {
        
        switch TenseControl.selectedSegmentIndex {
            
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
            currenttense = Tense.going.rawValue
            tensenum = 1
            TenseControl.selectedSegmentIndex = 0
        }
    }
    
    // posts update
    
    @IBAction func PostTapped(sender: AnyObject) {
        if statusUpdateTextField.text.isEmpty
        {
            let reportalert = UIAlertController(title: "Error", message: "You must enter a status update and/or a valid date ", preferredStyle: .Alert)
            let next = UIAlertAction(title: "OK", style: .Default, handler: nil)
            reportalert.addAction(next)
            
            self.presentViewController(reportalert, animated: true, completion: nil)
        }

        else
        {
            self.textViewDismissKeyboard()
            PostStatusUpdate()
            GotoNewsfeed()
            
            //reset userDefaults
            deafaults.removeObjectForKey("location")
            deafaults.synchronize()
        }
      
    }
    
    @IBAction func backbuttonTapped(sender: AnyObject) {
        self.textViewDismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.view.endEditing(true)
    }

    // camera controls
    
    
    @IBAction func CameraTapped(sender: AnyObject) {
        let camera = UIImagePickerController()
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.placeholderLabel.hidden = true
        
        
        
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
        statusImageview!.layer.cornerRadius = 4.0
        statusImageview!.clipsToBounds = true
        self.imageCheck = true
    }
}
