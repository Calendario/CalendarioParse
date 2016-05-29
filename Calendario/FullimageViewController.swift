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
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func BackButtontapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    let zoomImageView = UIImageView()
    let startingFrame = CGRectMake(0, 0, 200, 100)
    
    
    public var passedImage:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.minimumZoomScale = 1.0
        
        self.scrollView.maximumZoomScale = 6.0
       
        self.Image.image = passedImage
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.Image
    }
}
