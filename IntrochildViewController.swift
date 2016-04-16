//
//  IntrochildViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 22/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

class IntrochildViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, LastIntroViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    let pages = ["Pageone","Pagetwo","Pagethree"]
    
    
    // MARK: LastIntroViewControllerDelegate methods
    
    func lastPageDone() {
        print("View Controller says Last page done")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Page View Controller Datasource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        if let index = pages.indexOf(viewController.restorationIdentifier!) {
            
            if index > 0 {
                return viewControllerAtIndex(index - 1)
            }
        }
        
        return nil
    }
    

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if let index = pages.indexOf(viewController.restorationIdentifier!) {
            
            if index < pages.count - 1 {
                return viewControllerAtIndex(index + 1)
            }
            
        }
        
        return nil
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        let vc = storyboard?.instantiateViewControllerWithIdentifier(pages[index])
        
        if pages[index] == "Pagethree" {
            
            (vc as! LastIntroViewController).delegate = self
            
        }
        
        
        return vc
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = storyboard?.instantiateViewControllerWithIdentifier("IntroPageViewController") {
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            
            pageViewController = vc as! UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
            
            pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: .Forward, animated: true, completion: nil)
            pageViewController.didMoveToParentViewController(self)
            
        }
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }

}
