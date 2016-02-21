//
//  PhotoViewV2.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 21/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class PhotoViewV2 : UIViewController {
    
    // Setup the various UI objects.
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var imageScroll: UIScrollView!
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedImage:UIImage!
    
    // Setup the on screen button actions.
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the image views with the passed in image.
        self.backgroundImage.image = passedImage
        self.frontImage.image = passedImage
        
        // Set the blur on the background image.
        var visualEffectView:UIVisualEffectView!
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark)) as UIVisualEffectView
        visualEffectView.frame = self.backgroundImage.bounds
        self.backgroundImage.insertSubview(visualEffectView, atIndex: 0)
        
        // Set the scroll view properties.
        //self.imageScroll.scrollEnabled = true
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
