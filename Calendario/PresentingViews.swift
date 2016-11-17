//
//  PresentingViews.swift
//  Calendario
//
//  Created by Brian King on 3/19/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

open class PresentingViews: NSObject {
    
    class func ShowUserEditController(_ viewController: AnyObject) {
        let storyboard = UIStoryboard(name: "EditProfileUI", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "EditView") as! EditProfileViewController
        viewController.present(viewC, animated: true, completion: nil)
    }
    
    class func ShowFollowRequestsView(_ viewController: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "RequestsView") as! FollowRequestsTableViewController
        viewController.present(viewC, animated: true, completion: nil)
    }
    
    class func ViewSearchController(_ viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let searchView = sb.instantiateViewController(withIdentifier: "search") as! SearchViewController
        let NC = UINavigationController(rootViewController: searchView)
        viewController.present(NC, animated: true, completion: nil)
    }
    
    class func ViewAttendantsListView(_ viewController: AnyObject, eventID: String) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let attendantListView = sb.instantiateViewController(withIdentifier: "UserAttendantsList") as! AttendantsListViewController
        attendantListView.passedInEventID = eventID
        let NC = UINavigationController(rootViewController: attendantListView)
        viewController.present(NC, animated: true, completion: nil)
    }
    
    class func ReportView(_ viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewController(withIdentifier: "report") as! ReportTableViewController
        let NC = UINavigationController(rootViewController: reportVC)
        viewController.present(NC, animated: true, completion: nil)
    }
    
    class func showProfileView(_ passedUserObject: PFObject, viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportVC = sb.instantiateViewController(withIdentifier: "My Profile") as! MyProfileViewController
        reportVC.passedUser = passedUserObject as! PFUser
        viewController.parent!!.present(reportVC, animated: true, completion: nil)
    }
    
    class func presentHashtagsView(_ viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewController(withIdentifier: "HashtagNav") as! UINavigationController
        viewController.parent!!.present(likesView, animated: true, completion: nil)
    }
    
    class func openComments(_ commentsID: String, viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let commentvc = sb.instantiateViewController(withIdentifier: "comments") as! CommentsViewController
        commentvc.savedobjectID = commentsID
        let NC = UINavigationController(rootViewController: commentvc)
        viewController.parent!!.present(NC, animated: true, completion: nil)
    }
    
    class func showPhotoViewer(_ viewController: AnyObject, userPostedImage: UIImageView, userProfilePic: UIImage, userName: String, statusObject: PFObject) {
        let sb = UIStoryboard(name: "FullimageViewController", bundle: nil)
        let photoView = sb.instantiateViewController(withIdentifier: "photoViewer") as! FullimageViewController
        photoView.passedImage = userPostedImage.image!
        photoView.passedUserName = userName
        photoView.passedObject = statusObject
        photoView.passedUserProfileImage = userProfilePic
        viewController.parent!!.present(photoView, animated: true, completion: nil)
    }
    
    class func showLikesView(_ viewController: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let likesView = sb.instantiateViewController(withIdentifier: "likesNav") as! UINavigationController
        viewController.parent!!.present(likesView, animated: true, completion: nil)
    }
    
    class func viewRecommendations(_ viewController: AnyObject) {
        // Open the user recommendations view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let postsview = sb.instantiateViewController(withIdentifier: "recommend") as! RecommendedUsersViewController
        viewController.present(postsview, animated: true, completion: nil)
    }
    
    class func viewAcknowledgments(_ viewController: AnyObject) {
        // Open the webpage view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "WebPage") as! WebPageViewController
        viewC.passedURL = "http://www.calendario.co.uk/acknowledgements.htm"
        viewController.present(viewC, animated: true, completion: nil)
    }
    
    class func ViewTermsOfService(_ viewController: AnyObject) {
        
        // Open the terms of service view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "WebPage") as! WebPageViewController
        viewC.passedURL = "http://calendario.co.uk/termsofuse.html"
        viewController.present(viewC, animated: true, completion: nil)
    }
    
    class func ViewPrivacyPolicy(_ viewController: AnyObject) {
        
        // Open the privacy policy view.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewC = storyboard.instantiateViewController(withIdentifier: "WebPage") as! WebPageViewController
        viewC.passedURL = "http://www.calendario.co.uk/privacypolicy.html"
        viewController.present(viewC, animated: true, completion: nil)
    }
    
    class func presentNewsFeed(_ viewController: AnyObject, completion:() -> Void) {
        
        // Show the home view (news feed).
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBarController: UITabBarController = storyboard.instantiateViewController(withIdentifier: "tabBar") as! tabBarViewController
        appDelegate.window.makeKeyAndVisible()
        appDelegate.window.rootViewController = tabBarController
        completion()
    }
    
    class func ViewReportBug(_ viewController: AnyObject) {
        
        // Open the terms of service view.
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let reportbug = sb.instantiateViewController(withIdentifier: "reportbug") as! reportBug
        viewController.present(reportbug, animated: true, completion: nil)
    }
    
    //    class func Seemore(viewController: AnyObject) {
    //        // Open the see more view.
    //        let sb = UIStoryboard(name: "Main", bundle: nil)
    //        let SMVC = sb.instantiateViewControllerWithIdentifier("seemore") as! SeeMoreViewController
    //        let NC = UINavigationController(rootViewController: SMVC)
    //        viewController.presentViewController(NC, animated: true, completion: nil)
    //    }
}
