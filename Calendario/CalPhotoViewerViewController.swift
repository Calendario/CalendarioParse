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
        
        self.navigationItem.setLeftBarButton(closeButton, animated: true)
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.17, green: 0.58, blue: 0.38, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
      
        // Do any additional setup after loading the view.
        
        let defaults = UserDefaults.standard
        let imagedata:Data = defaults.object(forKey: "image") as! Data
        let image = UIImage(data: imagedata)
        var finalimage = UIImage()
        
        self.scrollview.minimumZoomScale = 1.0
        self.scrollview.maximumZoomScale = 5.0
        scrollview.delegate = self
        
        addBlur()
        
        //Imageview.image = image
        
        Imageview.contentMode = .scaleAspectFit
        Imageview.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        
        //roatateImage(image!)
        
        let flipped = UIImage(cgImage: image!.cgImage!, scale: image!.scale, orientation: UIImageOrientation.downMirrored)
        finalimage = flipped
        
        Imageview.image = finalimage
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addBlur()
    {
        let blureffect = UIBlurEffect(style: .light)
        var blureffectview:UIVisualEffectView!
        blureffectview = UIVisualEffectView(effect: blureffect)
        blureffectview.frame = view.bounds
        blureffectview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blureffectview)
        blureffectview.addSubview(scrollview)
    }
    
    func roatateImage(_ image:UIImage) -> UIImage {
        
        var finalimage = UIImage()
        
        if image.imageOrientation.hashValue == 0 {
            
            let flipped = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.downMirrored)
            finalimage = flipped
        } else {
            print(image.imageOrientation.hashValue)
        }
        
        return finalimage
    }
    
    @IBAction func CloseButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        var image:UIImageView!
        image = self.Imageview
        
        image.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        
        let flipped = UIImage(cgImage: image.image!.cgImage!, scale: image.image!.scale, orientation: UIImageOrientation.downMirrored)
        image.image = flipped
        
        return image
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.scrollview.isScrollEnabled = false
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.scrollview.isScrollEnabled = false
    }
 
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.zoomScale = 1
    }
}
