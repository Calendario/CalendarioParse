//
//  SeeMoreViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/22/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class SeeMoreViewController: UIViewController {

    @IBOutlet weak var UserLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var PostImage: UIImageView!
    
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var CommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        contentTextView.text = defaults.objectForKey("updatetext") as? String
        
        var objectid = defaults.objectForKey("objectId")
        
        print(objectid!)
        
        
        var query = PFQuery(className: "StatusUpdate")
        query.getObjectInBackgroundWithId(objectid! as! String) { (object, error) -> Void in
            var username = object!["user"]
          
        }
        
        //print(defaults.objectForKey("username") as? String)

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
