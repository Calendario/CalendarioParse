//
//  ProfileSubController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 15/11/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import QuartzCore

class ProfileSubController: UIViewController {
    
    // Setup the various user labels/etc.
    @IBOutlet weak var profPicture: UIImageView!
    @IBOutlet weak var profVerified: UIImageView!
    @IBOutlet weak var profName: UILabel!
    @IBOutlet weak var profUserName: UILabel!
    @IBOutlet weak var profWeb: UIButton!
    @IBOutlet weak var profPosts: UILabel!
    @IBOutlet weak var profFollowers: UILabel!
    @IBOutlet weak var profFollowing: UILabel!
    @IBOutlet weak var profDesc: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var privateMessagesButton: MIBadgeButton!
    
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Turn the profile picture into a circle.
        self.profPicture.layer.cornerRadius = (self.profPicture.frame.size.width / 2)
        self.profPicture.clipsToBounds = true
        
        // Get the screen size values.
        let result = UIScreen.main.bounds.size
        
        // Set the various UI object dimensions
        // depending on the device screen size.
        
        if (result.height == 480) {
            
            // 3.5 inch display - iPhone 4S & below.
            self.profVerified.frame = CGRect(x: 176, y: 92, width: 25, height: 25)
        }
            
        else if (result.height == 568) {
            
            // 4 inch display - iPhone 5/5s.
            self.profVerified.frame = CGRect(x: 176, y: 92, width: 25, height: 25)
        }
            
        else if (result.height == 667) {
            
            // 4.7 inch display - iPhone 6.
            self.profVerified.frame = CGRect(x: 203, y: 92, width: 25, height: 25)
        }
            
        else if (result.height >= 736) {
            
            // 5.5 inch display - iPhone 6 Plus.
            self.profVerified.frame = CGRect(x: 223, y: 92, width: 25, height: 25)
        }
        
        // Set the private message button properties.
        self.privateMessagesButton.badgeTextColor = UIColor.white
        self.privateMessagesButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 0)
    }
    
    //MARK: UI METHODS.
    
    func setPostsLabel(number: String) {
        
        // Set the label to show the posts image and string.
        var attachment:NSTextAttachment!
        attachment = NSTextAttachment()
        attachment.image = UIImage(named: "post-icon.png")!
        attachment.bounds = CGRect(x: -8.0, y: -2.0, width: 20.0, height: 20.0)
        let attachmentString = NSAttributedString(attachment: attachment)
        var myString:NSMutableAttributedString!
        myString = NSMutableAttributedString(string: "")
        myString.append(attachmentString)
        let myString1 = NSMutableAttributedString(string: number)
        myString.append(myString1)
        self.profPosts.attributedText = myString
    }
    
    func resetUIObjects() {
        self.profPicture.image = nil
        self.profVerified.image = nil
        self.profName.text = ""
        self.profUserName.text = ""
        self.profWeb.setTitle("", for: .normal)
        self.setPostsLabel(number: "0")
        self.profFollowers.text = ""
        self.profFollowing.text = ""
        self.profDesc.text = ""
        self.backgroundImage.image = nil
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
