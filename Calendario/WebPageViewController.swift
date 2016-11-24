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
    
    // Passed in website URL string.
    internal var passedURL:String!
    
    // Setup the on screen button actions.
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load the website URL if it is valid.
        
        if (passedURL != nil) {
            
            // Set the initial title to the passed in URL.
            titleLabel.text = passedURL
            
            // Setup the URL scheme check.
            var urlComp: URLComponents!
            urlComp = URLComponents(string: passedURL)!
            
            // If the URL does not have a scheme then
            // add the standard 'http' URL scheme in.
            
            if (urlComp.scheme == nil) {
                
                // Set the standard URL scheme.
                
                if (passedURL.contains("://") == false) {
                    passedURL = "http://\(passedURL!)"
                }
            }

            // Load the website in the web view.
            let url = URL(string: passedURL)
            let requestObj = URLRequest(url: url!)
            webPage.loadRequest(requestObj)
        }
        
        else {
            self.displayAlert("Error", alertMessage: "The website could not be loaded because the URL is invalid.")
        }
    }
    
    /// Web View methods.
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        // Notify the user that the app is loading.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // Get the website title/URL.
        let webTitle = webPage.stringByEvaluatingJavaScript(from: "document.title")
        let webURL = webPage.request!.url!.absoluteString
        
        // Set the website title.
        
        if (webTitle != nil) {
            
            if ((webTitle == "") || (webTitle == " ") || (webTitle == nil)) {
                titleLabel.text = passedURL
            }
            
            else {
                titleLabel.text = webTitle
            }
        }
        
        else {
            titleLabel.text = webURL
        }
        
        // Notify the user that the app has stopped loading.
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        // Display the error message to the user.
        self.displayAlert("Error", alertMessage: "An error has occured: \(error.localizedDescription)")
    }
    
    // Alert methods.
    
    func displayAlert(_ alertTitle: String, alertMessage: String) {
        
        // Setup the alert controller.
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        // Setup the alert actions.
        let cancel = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(cancel)
        
        // Present the alert on screen.
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func ActionPressed(_ sender: AnyObject) {
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [URL(string: "\(passedURL!)")!], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.barButtonItem = (sender as! UIBarButtonItem)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // Other methods.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
