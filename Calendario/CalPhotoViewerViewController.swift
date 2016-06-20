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
      
        // Do any additional setup after loading the view.
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let imagedata:NSData = defaults.objectForKey("image") as! NSData
        let image = UIImage(data: imagedata)
        var finalimage = UIImage()
        
        self.scrollview.minimumZoomScale = 1.0
        self.scrollview.maximumZoomScale = 5.0
        scrollview.delegate = self
        
        addBlur()
        
        //Imageview.image = image
        
        Imageview.contentMode = .ScaleAspectFit
        Imageview.transform = CGAffineTransformMakeScale(1.0, -1.0)
        
        //roatateImage(image!)
        
        let flipped = UIImage(CGImage: image!.CGImage!, scale: image!.scale, orientation: UIImageOrientation.DownMirrored)
        finalimage = flipped
        
        Imageview.image = finalimage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlur()
    {
        let blureffect = UIBlurEffect(style: .Light)
        var blureffectview:UIVisualEffectView!
        blureffectview = UIVisualEffectView(effect: blureffect)
        blureffectview.frame = view.bounds
        blureffectview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(blureffectview)
        blureffectview.addSubview(scrollview)
    }
    
    func roatateImage(image:UIImage) -> UIImage {
        
        var finalimage = UIImage()
        
        if image.imageOrientation.hashValue == 0 {
            
            let flipped = UIImage(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.DownMirrored)
            finalimage = flipped
        } else {
            print(image.imageOrientation.hashValue)
        }
        
        return finalimage
    }
    
    @IBAction func CloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        var image:UIImageView!
        image = self.Imageview
        
        image.transform = CGAffineTransformMakeScale(1.0, -1.0)
        
        let flipped = UIImage(CGImage: image.image!.CGImage!, scale: image.image!.scale, orientation: UIImageOrientation.DownMirrored)
        image.image = flipped
        
        return image
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.scrollview.scrollEnabled = false
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.scrollview.scrollEnabled = false
    }
 
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrollView.zoomScale = 1
    }
}
