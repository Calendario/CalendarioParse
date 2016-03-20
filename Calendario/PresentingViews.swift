//
//  PresentingViews.swift
//  Calendario
//
//  Created by Brian King on 3/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

public class PresentingViews: NSObject {
    
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
        let PVC = sb.instantiateViewControllerWithIdentifier("PhotoV2") as! PhotoViewV2
        PVC.passedImage = userPostedImage.image!
        let NC = UINavigationController(rootViewController: PVC)
        viewController.parentViewController!!.presentViewController(NC, animated: true, completion: nil)
    }
    
    class func showLikesView(viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewControllerWithIdentifier("likesNav") as! UINavigationController
        viewController.parentViewController!!.presentViewController(likesView, animated: true, completion: nil)
    }

    
    //    class func Seemore(viewController: AnyObject) {
    //        // Open the see more view.
    //        let sb = UIStoryboard(name: "Main", bundle: nil)
    //        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
    //        let NC = UINavigationController(rootViewController: SMVC)
    //        viewController.presentViewController(NC, animated: true, completion: nil)
    //    }
    
    
}
