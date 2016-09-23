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
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Page View Controller Datasource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let index = pages.index(of: viewController.restorationIdentifier!) {
            
            if index > 0 {
                return viewControllerAtIndex(index - 1)
            }
        }
        
        return nil
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let index = pages.index(of: viewController.restorationIdentifier!) {
            
            if index < pages.count - 1 {
                return viewControllerAtIndex(index + 1)
            }
            
        }
        
        return nil
    }
    
    func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        let vc = storyboard?.instantiateViewController(withIdentifier: pages[index])
        
        if pages[index] == "Pagethree" {
            
            (vc as! LastIntroViewController).delegate = self
            
        }
        
        
        return vc
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "IntroPageViewController") {
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            
            pageViewController = vc as! UIPageViewController
            pageViewController.dataSource = self
            pageViewController.delegate = self
            
            pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: .forward, animated: true, completion: nil)
            pageViewController.didMove(toParentViewController: self)
            
        }
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }

}
