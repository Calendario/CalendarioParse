//
//  StatusUpdateViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 10/11/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit
import CoreLocation



class StatusUpdateViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {

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
    
    var currenttense: String! = "going"
    
    
    
    
    
    
    
    //creates a id number for each status update
    var statusID = arc4random()
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.setRightBarButtonItem(PostButton, animated: true)
        statusUpdateTextField.delegate = self
        dateLabel.hidden = true
        
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
        var statusupdate = PFObject(className: "StatusUpdate")
        statusupdate["updatetext"] = statusUpdateTextField.text
        statusupdate["user"] = PFUser.currentUser()
        statusupdate["dateofevent"] = dateLabel.text
        statusupdate["ID"] = Int(statusID)
        statusupdate["tense"] = currenttense
        
        
        
        
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
    
    
    
    
    
    // UITextfield delegate methods
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var newLength:Int = (statusUpdateTextField.text as NSString).length + (text as NSString).length - range.length
        var remainingchars:Int = 400 - newLength
        charlabel.text = "\(remainingchars)"
        return (newLength > 400) ? false:true
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
