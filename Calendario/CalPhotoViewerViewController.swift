//
//  CalPhotoViewerViewController.swift
//  Calendario
//
//  Created by Derek Cacciotti on 12/12/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class CalPhotoViewerViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var Imageview: UIImageView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setLeftBarButtonItem(closeButton, animated: true)
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.38, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        
        
        addBlur()

        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let imagedata:NSData = defaults.objectForKey("image") as! NSData
        let image = UIImage(data: imagedata)
        
        self.scrollview.minimumZoomScale = 1.0
        self.scrollview.maximumZoomScale = 6.0
        scrollview.delegate = self
        
        
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
        blureffectview.addSubview(scrollview)
        //blureffectview.addSubview(Imageview)
       
    }
    
    @IBAction func CloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.Imageview
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
