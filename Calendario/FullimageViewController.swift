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
    
    @IBAction func back(sender: UIBarButtonItem) {
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
        
        
        
        
        zoomImageView.frame = CGRectMake(0, 0, 200, 100)
        zoomImageView.backgroundColor = UIColor.redColor()
       // zoomImageView.image = UIImage(data: passedImage)
        zoomImageView.contentMode = .ScaleAspectFill
        zoomImageView.clipsToBounds = true
        
        zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "animated"))
        
    
        view.addSubview(zoomImageView)
        
        
    }
    
    func animate() {
        UIView.animateWithDuration(0.75) { () -> Void in
            
            let height = (self.view.frame.width / self.startingFrame.width) * self.startingFrame.height
            
            let y = self.view.frame.height / 2 - height / 2
            
            self.zoomImageView.frame = CGRectMake(0 , 0, self.view.frame.width, 100)
        }
    }

    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.Image
    }
}
