//
//  ToSViewController.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 25/10/2015.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class TosViewController : UIViewController {
    
    // Setup the on screen button actions.
    
    @IBAction func cancel(_ sender: UIButton) {
        
        // Go back to the login page.
        self.dismiss(animated: true, completion: nil)
    }
    
    // View Did Load method.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Other methods.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
