//
//  WebPageViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 02/11/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class WebPageViewController : UIViewController, UIWebViewDelegate {
    
    // Setup the various UI objects.
    @IBOutlet weak var webPage: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // Do NOT change the following line of
    // code as it MUST be set to PUBLIC.
    public var passedURL:String!
    
    // Setup the on screen button actions.
    
    @IBAction func goBack(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load the website URL if it is valid.
        
        if (passedURL != nil) {
            
            // Set the initial title to the passed in URL.
            titleLabel.text = passedURL
            print(passedURL)
            
            // Load the website in the web view.
            let url = NSURL(string: "http://\(passedURL)")
            let requestObj = NSURLRequest(URL: url!)
            webPage.loadRequest(requestObj)
        }
        
        else {
            self.displayAlert("Error", alertMessage: "The website could not be loaded because the URL is invalid.")
        }
    }
    
    /// Web View methods.
    
    func webViewDidStartLoad(webView: UIWebView) {
        
        // Notify the user that the app is loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        // Get the website title/URL.
        let webTitle = webPage.stringByEvaluatingJavaScriptFromString("document.title")
        let webURL = webPage.request!.URL!.absoluteString
        
        // Set the website title.
        
        if (webTitle != nil) {
             titleLabel.text = webTitle
        }
        
        else {
            titleLabel.text = webURL
        }
        
        // Notify the user that the app has stopped loading.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        // Display the error message to the user.
        self.displayAlert("Error", alertMessage: "An error has occured: \(error)")
    }
    
    // Alert methods.
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func ActionPressed(sender: AnyObject) {
        OpeninSafari(NSURL(string: "http://\(passedURL)")!)
    }
    
    
    // Other methods.
    
    func OpeninSafari(url:NSURL)
    {
        UIApplication.sharedApplication().openURL(url)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}