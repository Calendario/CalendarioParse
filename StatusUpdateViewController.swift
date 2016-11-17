//
//  StatusUpdateViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import CoreLocation

class StatusUpdateViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var PostButton: UIBarButtonItem!
    @IBOutlet var dateTapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var dateContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    //@IBOutlet weak var checkinbutton: UIButton!
    @IBOutlet weak var datepicker: UIDatePicker!
    @IBOutlet weak var datePickerContainer: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var charlabel: UILabel!
    @IBOutlet weak var TenseControl: UISegmentedControl!
    @IBOutlet weak var statusUpdateTextField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var backbutton: UIBarButtonItem!
    @IBOutlet weak var rsvpSwitch: UISwitch!
    @IBOutlet weak var imageList: UICollectionView!
    
    // Media data array.
    var mediaDataArray: Array<UIImage> = []

    // Image upload check.
    var imageCheck = false
    
    let deafaults = UserDefaults()
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
    var dateSetCheck:Bool = false
    
    //creates a id number for each status update
    var statusID = arc4random()
    
    // location
    let locationManager = CLLocationManager()
    var imagedata:Data?
    var postingImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Allow the user to dismiss the keyboard with a toolabr.
        let editToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        editToolbar.barStyle = UIBarStyle.default
        
        editToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StatusUpdateViewController.textViewDismissKeyboard))
        ]
        
        editToolbar.sizeToFit()
        self.statusUpdateTextField.inputAccessoryView = editToolbar
        self.eventTitle.inputAccessoryView = editToolbar
        
        statusUpdateTextField.layer.borderColor = UIColor.black.cgColor
        TenseControl.selectedSegmentIndex = 2
        
        // Do any additional setup after loading the view.
        statusUpdateTextField.delegate = self
        dateLabel.isHidden = false
        datepicker.isHidden = true
        datePickerContainer.isHidden = true
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.TenseControl.tintColor = UIColor(red: 0.173, green: 0.584, blue: 0.376, alpha:1)
        self.datePickerContainer.layer.cornerRadius = 10.0
        self.datepicker.layer.cornerRadius = 10.0
        self.visualEffectView.layer.cornerRadius = 10.0
        self.datePickerContainer.layer.borderColor = UIColor.lightGray.cgColor
        self.datePickerContainer.layer.borderWidth = 1.0
        self.datePickerContainer.layoutIfNeeded()
        
        // save current status id in NSUserDefaults incase its going to be used for a comment
        
        // gesture reconizer for date picker
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(StatusUpdateViewController.DatePickerAppear))
        
        dateLabel.isUserInteractionEnabled = true
        
        dateLabel.addGestureRecognizer(tapgesture)
        
        viewGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StatusUpdateViewController.setDate))
        containerView.addGestureRecognizer(viewGestureRecognizer)
        viewGestureRecognizer.isEnabled = false
        
        
        locationtapReconizer = UITapGestureRecognizer(target: self, action: #selector(StatusUpdateViewController.LocationlabelTapped))
        
        LocationLabel.isUserInteractionEnabled = true
        
        LocationLabel.addGestureRecognizer(locationtapReconizer)
        
        
        // dismisses keyboard when background is tapped
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StatusUpdateViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        deafaults.synchronize()
        
        let location = deafaults.value(forKey: "location") as? String
        
        if location == nil
        {
            //LocationLabel.text = "No Location"
            //LocationLabel.textColor = UIColor.lightGrayColor()
        } else {
            LocationLabel.text = location
            //checkinbutton.hidden = true
            //LocationLabel.text = location as! String
            //LocationLabel.textColor = UIColor.darkGrayColor()
        }
    }
    
    func textViewDismissKeyboard() {
        self.statusUpdateTextField.resignFirstResponder()
        self.eventTitle.resignFirstResponder()
    }

    func setDate()
    {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.dateFormat = "M/d/yy"
        dateformatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dateformatter2 = DateFormatter()
        dateformatter2.dateStyle = DateFormatter.Style.medium
        dateformatter2.timeZone = TimeZone(abbreviation: "UTC")
        
        shortStyleDateToBeSaved = dateformatter.string(from: datepicker.date)
        self.dateSetCheck = true
        dateLabel.isHidden = false
        dateLabel.text = dateformatter2.string(from: datepicker.date)
        print(dateLabel)
        datepicker.isHidden = true
        datePickerContainer.isHidden = true
        dateLabel.textColor = UIColor.darkGray
        
        changeSegmentControl(datepicker.date)
        
        viewGestureRecognizer.isEnabled = false
    }
    
    func changeSegmentControl (_ dateSelected: Date) {
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.medium
        dateformatter.dateFormat = "M/d/yy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = DateFormatter.Style.long
        timeFormatter.dateFormat = "HH"
        
        let currentDate = Date()
        let currentDateString = dateformatter.string(from: currentDate)
        let currentTimeString = timeFormatter.string(from: currentDate)
        let dateSelectedString = dateformatter.string(from: dateSelected)
        let selectedTimeString = timeFormatter.string(from: dateSelected)
        
        if (currentDateString == dateSelectedString) && (currentTimeString == selectedTimeString) {
            TenseControl.selectedSegmentIndex = 2
        }
        else if currentDate.compare(dateSelected) == ComparisonResult.orderedDescending {
            TenseControl.selectedSegmentIndex = 1
        }
        else if currentDate.compare(dateSelected) == ComparisonResult.orderedAscending{
            TenseControl.selectedSegmentIndex = 0
        }
        
        tenseControlchanged()
    }
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        changeSegmentControl(datepicker.date)
    }
    
    func DatePickerAppear()
    {
        // gesture reconizer for date picker
        viewGestureRecognizer.isEnabled = true

        datepicker.isHidden = false
        dateLabel.isHidden = true
        datePickerContainer.isHidden = false
    }
    
    func LocationlabelTapped()
    {
        //checkinbutton.hidden = false
        
        let locationReference =  self.storyboard!.instantiateViewController(withIdentifier: "LocationVC") as UIViewController!
        self.present(locationReference!, animated: true, completion: nil)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func PostStatusUpdate() {
        
        // Get the latitude/longitude of the location
        // if one has been selected by the user.
        let locationLatitude = deafaults.value(forKey: "locationLat") as? Double
        let locationLongitude = deafaults.value(forKey: "locationLon") as? Double
        
        // Make sure the updatetext contains all
        // the @user mentions in lowercase.
        ManageUser.correctStringWithUsernames(self.statusUpdateTextField.text!, completion: { (correctString) -> Void in
            
            if ((self.mediaDataArray.count > 0) && (self.imageCheck == true)) {
                
                self.postingImage = true
                
                var statusupdatewithimage: PFObject!
                statusupdatewithimage = PFObject(className: "StatusUpdate")
                statusupdatewithimage["updatetext"] = correctString
                statusupdatewithimage["user"] = PFUser.current()
                statusupdatewithimage["dateofevent"] = self.shortStyleDateToBeSaved
                statusupdatewithimage["ID"] = Int(self.statusID)
                statusupdatewithimage["tense"] = self.currenttense
                statusupdatewithimage["location"] = self.LocationLabel.text!
                statusupdatewithimage["likesarray"] = []
                statusupdatewithimage["rsvpArray"] = []
                statusupdatewithimage["eventTitle"] = self.eventTitle.text!
                
                if (self.rsvpSwitch.isOn == true) {
                    statusupdatewithimage["privateRsvp"] = true
                }
                    
                else if (self.rsvpSwitch.isOn == false) {
                    statusupdatewithimage["privateRsvp"] = false
                }

                if ((self.LocationLabel.text?.contains("tap to select location")) == false) {
                    let point = PFGeoPoint(latitude:locationLatitude!, longitude:locationLongitude!)
                    statusupdatewithimage["placeGeoPoint"] = point
                }
                
                // image 1 posting
                self.imagedata = UIImageJPEGRepresentation(self.mediaDataArray[0], 0.5)
                let imagefile = PFFile(name: "image.jpg", data: self.imagedata!)
                statusupdatewithimage["image"] = imagefile!
                
                // saves object in background
                
                statusupdatewithimage.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    if success {
                        
                        // Setup the extra image query.
                        var extraMediaImage: PFObject!
                        extraMediaImage = PFObject(className: "statusMedia")
                        let imagedataTwo:Data = UIImageJPEGRepresentation(self.mediaDataArray[1], 0.5)!
                        let imagefileTwo = PFFile(name: "image2.jpg", data: imagedataTwo)
                        extraMediaImage["imageDataTwo"] = imagefileTwo!
                        
                        if (self.mediaDataArray.count > 2) {
                            
                            let imagedataThree:Data = UIImageJPEGRepresentation(self.mediaDataArray[2], 0.5)!
                            let imagefileThree = PFFile(name: "image3.jpg", data: imagedataThree)
                            extraMediaImage["imageDataThree"] = imagefileThree!
                        }
                        
                        extraMediaImage["statusUpdateID"] = statusupdatewithimage.objectId!
                        
                        // Save the extra images with status ID.
                        extraMediaImage.saveInBackground(block: { (success: Bool, errorExtra: Error?) in
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                        
                    else {
                        
                        // prints error
                        print(error?.localizedDescription)
                    }
                })
            }
                
            else {
                
                var statusupdate: PFObject!
                statusupdate = PFObject(className: "StatusUpdate")
                statusupdate["updatetext"] = correctString
                statusupdate["user"] = PFUser.current()
                statusupdate["dateofevent"] = self.shortStyleDateToBeSaved
                statusupdate["ID"] = Int(self.statusID)
                statusupdate["tense"] = self.currenttense
                statusupdate["location"] = self.LocationLabel.text!
                statusupdate["likesarray"] = []
                statusupdate["rsvpArray"] = []
                statusupdate["eventTitle"] = self.eventTitle.text!
                
                if (self.rsvpSwitch.isOn == true) {
                    statusupdate["privateRsvp"] = true
                }
                    
                else if (self.rsvpSwitch.isOn == false){
                    statusupdate["privateRsvp"] = false
                }
                
                if ((self.LocationLabel.text?.contains("tap to select location")) == false) {
                    let point = PFGeoPoint(latitude:locationLatitude!, longitude:locationLongitude!)
                    statusupdate["placeGeoPoint"] = point
                }
                
                statusupdate.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    }
                        
                    else {
                        // prints error
                        print(error?.localizedDescription)
                    }
                })
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
    
    @IBAction func PostTapped(_ sender: AnyObject) {
        
        if ((statusUpdateTextField.text.isEmpty) || (self.dateSetCheck == false)) {
            let reportalert = UIAlertController(title: "Error", message: "You must enter a status update and valid event date.", preferredStyle: .alert)
            let next = UIAlertAction(title: "OK", style: .default, handler: nil)
            reportalert.addAction(next)
            
            self.present(reportalert, animated: true, completion: nil)
        } else {
            self.textViewDismissKeyboard()
            PostStatusUpdate()
            GotoNewsfeed()
            
            //reset userDefaults
            deafaults.removeObject(forKey: "location")
            deafaults.synchronize()
        }
    }
    
    @IBAction func backbuttonTapped(_ sender: AnyObject) {
        self.textViewDismissKeyboard()
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }

    // camera controls
    
    @IBAction func CameraTapped(_ sender: AnyObject) {
        
        if (self.mediaDataArray.count < 3) {
            
            let camera = UIImagePickerController()
            DispatchQueue.main.async { () -> Void in
                camera.delegate = self
                camera.sourceType = UIImagePickerControllerSourceType.camera
                camera.allowsEditing = false
                self.present(camera, animated: true, completion: nil)
            }
        }
        
        else {
            self.displayAlert("Error", alertMessage: "You can add a maximum of 3 photos to each status update.")
        }
    }
    
    @IBAction func VideoTapped(_ sender: AnyObject) {
        
        if (self.mediaDataArray.count < 3) {
            
            var photo:UIImagePickerController!
            photo = UIImagePickerController()
            DispatchQueue.main.async {
                photo.delegate = self
                photo.sourceType = UIImagePickerControllerSourceType.photoLibrary
                photo.allowsEditing = false
                self.present(photo, animated: true, completion: nil)
            }
        }
            
        else {
            self.displayAlert("Error", alertMessage: "You can add a maximum of 3 photos to each status update.")
        }
    }

    // UITextfield delegate methods
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength:Int = (statusUpdateTextField.text as NSString).length + (text as NSString).length - range.length
        let remainingchars:Int = 400 - newLength
        charlabel.text = "\(remainingchars)"
        return (newLength > 400) ? false:true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderLabel.isHidden = true
    }
    
    func GotoNewsfeed() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBarController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }
    
    // image picker delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.mediaDataArray.insert(image, at:0)
        self.imageCheck = true
        self.imageList.reloadData()
    }
    
    // Collection view delegate methods.
    
    func deleteImageAtIndex(object: AnyObject) {
        
        // Setup the alert controller.
        let choiceAlert = UIAlertController(title: "Delete phpto", message: "Would you like to remove the selected photo from the status update.", preferredStyle: .actionSheet)
        
        // Setup the alert actions.
        let deletePhotoAction = { (action:UIAlertAction!) -> Void in
            
            self.mediaDataArray.remove(at: object.tag)
            self.imageList.reloadData()
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: deletePhotoAction)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        choiceAlert.addAction(deleteButton)
        choiceAlert.addAction(cancel)
        
        // Present the alert on screen.
        present(choiceAlert, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //    self.deleteImageAtIndex(selectedPath: indexPath)
    //}
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 136, height: 136)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get a reference to our storyboard cell.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusCell", for: indexPath as IndexPath) as! StatusUpdateCollectionCell
        
        // Set the preview image view.
        cell.previewImage.setImage(mediaDataArray[indexPath.row], for: .normal)
        
        // Set the buttont tag number.
        cell.previewImage.tag = indexPath.row
        
        // Connect the button image to the alert method.
        cell.previewImage.addTarget(self, action: #selector(self.deleteImageAtIndex(object:)), for: .touchUpInside)
        
        // Ensure the image sticks to the size of the button.
        cell.previewImage.clipsToBounds = true
        
        return cell
    }
    
    // Alert methods.
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
}
