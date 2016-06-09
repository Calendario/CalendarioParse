//
//  FullimageViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 26/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FullimageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func BackButtontapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public var passedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.Image.image = passedImage
        
        // Set the navigation bar properties.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 35/255.0, green: 135/255.0, blue: 75/255.0, alpha: 1.0)
        self.navigationItem.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent = false
        let font = UIFont(name: "SFUIDisplay-Regular", size: 18)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: font!]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        // Set the back button.
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "back_button.png"), forState: UIControlState.Normal)
        button.tintColor = UIColor.whiteColor()
        button.addTarget(self, action: #selector(FullimageViewController.closeView), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func closeView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.Image
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        
        let widthScale = size.width / Image.bounds.width
        let heightScale = size.height / Image.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    private func updateViewConstraints(size: CGSize) {
        
        let yOffset = max(0, (size.height - Image.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - Image.frame.height) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        updateViewConstraints()
    }
    
    
    func resizeImage(Image: UIImage, targetSize: CGSize) -> UIImage {
        let size = Image.size
        
        let widthRatio = targetSize.width / Image.size.width
        let heightRatio = targetSize.height / Image.size.height
        
        self.resizeImage(passedImage, targetSize: CGSizeMake(200.0, 200.0))
        
        // Figure the orientation
        
        var newSize: CGSize
        if (widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio , size.height * heightRatio)
            
        }
        else {
            newSize = CGSizeMake(size.width * widthRatio, size.height * widthRatio)
        }
        
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        Image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage
      }

}
