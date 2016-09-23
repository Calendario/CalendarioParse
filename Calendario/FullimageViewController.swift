//
//  FullimageViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 26/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class FullimageViewController: UIViewController, UIScrollViewDelegate {
    
    // Main view UI objects.
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Passed in image data.
    internal var passedImage:UIImage!
    
    //MARK: BUTTONS.
    
    @IBAction func BackButtontapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Setup the scroll view.
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        // Setup the image view.
        self.Image.image = passedImage
        self.Image.contentMode = .scaleAspectFit
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated.
    }
    
    //MARK: SCROLLVIEW DELEGATE METHODS.
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.Image
    }
}
