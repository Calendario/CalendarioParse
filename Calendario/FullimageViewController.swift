//
//  FullimageViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 26/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

class FullimageViewController: UIViewController, UIScrollViewDelegate {
    
    // Main view UI objects.
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var ImageViewTwo: UIImageView!
    @IBOutlet weak var ImageViewThree: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTwo: UIScrollView!
    @IBOutlet weak var scrollViewThree: UIScrollView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var dotView: UIPageControl!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var dotLoadingView: UIActivityIndicatorView!
    var pageControlCheck = false
    
    // Passed in image data.
    internal var passedImage:UIImage!
    internal var passedUserProfileImage:UIImage!
    internal var passedUserName:String!
    
    // Passed in post object data.
    internal var passedObject:PFObject!
    
    //MARK: BUTTONS.
    
    @IBAction func BackButtontapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePage(_ sender: AnyObject) {
        
        // Update the scroll view to the appropriate page
        var frame = CGRect.zero
        frame.origin.x = (CGFloat(self.containerScrollView.frame.size.width) * CGFloat(self.dotView.currentPage))
        frame.origin.y = 0
        frame.size = self.containerScrollView.frame.size
        self.containerScrollView.scrollRectToVisible(frame, animated: true)
        
        // Set the control check to true.
        self.pageControlCheck = true
    }
    
    //MARK: VIEW DID LOAD.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    //MARK: DATA METHODS.
    
    func loadMedia() {
        
        // Load in any additional images.
        ParseCalls.checkForUserPostedMedia(passedObject: self.passedObject, imageViewTwo: self.ImageViewTwo, imageViewThree: self.ImageViewThree) { (numberOfPictures) in
            
            // Set the number of dots.
            self.dotView.numberOfPages = (numberOfPictures + 1)
            
            if (numberOfPictures == 1) {
                self.containerScrollView.contentSize = CGSize(width: (UIScreen.main.bounds.size.width * 2), height: UIScreen.main.bounds.size.height)
            }
            
            else if (numberOfPictures == 2) {
                self.containerScrollView.contentSize = CGSize(width: (UIScreen.main.bounds.size.width * 3), height: UIScreen.main.bounds.size.height)
            }
            
            // Stop the loading indicator.
            self.dotLoadingView.stopAnimating()
            self.dotView.alpha = 1.0
        }
    }
    
    //MARK: UI METHODS.
    
    func setupUI() {
        
        // Set the status bar to white.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Turn the profile picture into a circle.
        self.userProfilePicture.layer.cornerRadius = (self.userProfilePicture.frame.size.width / 2)
        self.userProfilePicture.clipsToBounds = true
        
        // Start the loading indicator.
        self.dotLoadingView.startAnimating()
        
        // Setup the scroll view.
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.scrollView.isScrollEnabled = true
        self.scrollViewTwo.minimumZoomScale = 1.0
        self.scrollViewTwo.maximumZoomScale = 6.0
        self.scrollViewTwo.isScrollEnabled = true
        self.scrollViewThree.minimumZoomScale = 1.0
        self.scrollViewThree.maximumZoomScale = 6.0
        self.scrollViewThree.isScrollEnabled = true
        self.containerScrollView.isScrollEnabled = true
        self.containerScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        // Set the scroll view frame sizes/positions.
        self.scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.scrollViewTwo.frame = CGRect(x: UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.scrollViewThree.frame = CGRect(x: (UIScreen.main.bounds.size.width * 2), y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        
        // Set the image view frame sizes/positions.
        self.Image.frame = CGRect(x: 0, y: 0, width: self.scrollView.bounds.size.width, height: self.scrollView.bounds.size.height)
        self.ImageViewTwo.frame = CGRect(x: 0, y: 0, width: self.scrollViewTwo.bounds.size.width, height: self.scrollViewTwo.bounds.size.height)
        self.ImageViewThree.frame = CGRect(x: 0, y: 0, width: self.scrollViewThree.bounds.size.width, height: self.scrollViewThree.bounds.size.height)

        // Setup the image view.
        self.Image.image = self.passedImage
        self.Image.contentMode = .scaleAspectFit
        self.ImageViewTwo.contentMode = .scaleAspectFit
        self.ImageViewThree.contentMode = .scaleAspectFit
        
        // Setup the user data views.
        self.userProfilePicture.image = self.passedUserProfileImage
        self.userNameLabel.text = self.passedUserName!
        
        // Load in the additional data.
        self.loadMedia()
    }
    
    //MARK: OTHER METHODS.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resource that can be recreated.
    }
    
    //MARK: SCROLLVIEW DELEGATE METHODS.
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        if (scrollView.tag == 1) {
            return self.Image
            
        } else if (scrollView.tag == 2) {
            return self.ImageViewTwo
            
        } else {
            return self.ImageViewThree
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Check if the dot view is being
        // pressed by the user or not.
        
        if (!pageControlCheck) {
            
            // Switch the indicator when more than
            // 50% of the previous/next page is visible.
            let pageWidth:CGFloat = self.containerScrollView.frame.size.width
            let page = floor((self.containerScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
            self.dotView.currentPage = Int(page)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.pageControlCheck = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControlCheck = false
    }
}
