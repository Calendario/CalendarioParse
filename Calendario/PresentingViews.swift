//
//  PresentingViews.swift
//  Calendario
//
//  Created by Brian King on 3/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

public class PresentingViews: NSObject {
    
    class func ViewAttendantsListView(viewController: AnyObject, eventID: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let attendantListView = sb.instantiateViewControllerWithIdentifier("UserAttendantsList") as! AttendantsListViewController
        attendantListView.passedInEventID = eventID
        let NC = UINavigationController(rootViewController: attendantListView)
        viewController.presentViewController(NC, animated: true, completion: nil)
    }
    
    class func ReportView(viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        viewController.presentViewController(NC, animated: true, completion: nil)
    }
    
    class func showProfileView(passedUserObject: PFObject, viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewControllerWithIdentifier("My Profile") as! MyProfileViewController
        reportVC.passedUser = passedUserObject as! PFUser
        viewController.parentViewController!!.presentViewController(reportVC, animated: true, completion: nil)
    }
    
    class func presentHashtagsView(viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("HashtagNav") as! UINavigationController
        viewController.parentViewController!!.presentViewController(likesView, animated: true, completion: nil)
    }
    
    class func openComments(commentsID: String, viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let commentvc = sb.instantiateViewControllerWithIdentifier("comments") as! CommentsViewController
        commentvc.savedobjectID = commentsID
        let NC = UINavigationController(rootViewController: commentvc)
        viewController.parentViewController!!.presentViewController(NC, animated: true, completion: nil)
    }
    
    class func showPhotoViewer(viewController: AnyObject, userPostedImage: UIImageView) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let PVC = sb.instantiateViewControllerWithIdentifier("photoViewer") as! FullimageViewController
        PVC.passedImage = userPostedImage.image!
        let NC = UINavigationController(rootViewController: PVC)
        viewController.parentViewController!!.presentViewController(NC, animated: true, completion: nil)
    }
    
    class func showLikesView(viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("likesNav") as! UINavigationController
        viewController.parentViewController!!.presentViewController(likesView, animated: true, completion: nil)
    }
    
    class func viewRecommendations(viewController: AnyObject) {
        // Open the user recommendations view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewControllerWithIdentifier("recommend") as! RecommendedUsersViewController
        viewController.presentViewController(postsview, animated: true, completion: nil)
    }
    
    class func viewAcknowledgments(viewController: AnyObject) {
        // Open the webpage view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewControllerWithIdentifier("WebPage") as! WebPageViewController
        viewC.passedURL = "http://www.calendario.co.uk/acknowledgements.htm"
        viewController.presentViewController(viewC, animated: true, completion: nil)
    }
    
    class func ViewTermsOfService(viewController: AnyObject) {
        
        // Open the terms of service view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let termsofservice = sb.instantiateViewControllerWithIdentifier("tos") as! TosViewController
        viewController.presentViewController(termsofservice, animated: true, completion: nil)
    }
    
    class func ViewPrivacyPolicy(viewController: AnyObject) {
        
        // Open the privacy policy view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let privacypolicyVC = sb.instantiateViewControllerWithIdentifier("privacypolicy") as! PrivacyPolicyViewController
        viewController.presentViewController(privacypolicyVC, animated: true, completion: nil)
    }
    
    class func presentNewsFeed(viewController: AnyObject) {
        // Show the home view (news feed).
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let tabBarController: UITabBarController = storyboard.instantiateViewControllerWithIdentifier("tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
    }

    
    //    class func Seemore(viewController: AnyObject) {
    //        // Open the see more view.
    //        let sb = UIStoryboard(name: "Main", bundle: nil)
    //        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
    //        let NC = UINavigationController(rootViewController: SMVC)
    //        viewController.presentViewController(NC, animated: true, completion: nil)
    //    }
    
    
}
