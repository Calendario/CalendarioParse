//
//  CalPhotoViewerViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/12/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CalPhotoViewerViewController: UIViewController {

    @IBOutlet weak var Imageview: UIImageView!
    
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        self.navigationController?.hidesBarsOnTap = true
        
        addBlur()

        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let imagedata:NSData = defaults.objectForKey("image") as! NSData
        let image = UIImage(data: imagedata)
        
        
        Imageview.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlur()
    {
        var blureffect = UIBlurEffect(style: .Dark)
        var blureffectview = UIVisualEffectView(effect: blureffect)
        blureffectview.frame = view.bounds
        blureffectview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(blureffectview)
        blureffectview.addSubview(Imageview)
       
    }
    
    @IBAction func CloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
