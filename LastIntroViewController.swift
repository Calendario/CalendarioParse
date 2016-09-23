//
//  LastIntroViewController.swift
//  Calendario
//
//  Created by Harith Bakri on 22/03/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

protocol LastIntroViewControllerDelegate {
    func lastPageDone()
}

class LastIntroViewController: UIViewController {
    
    var delegate: LastIntroViewControllerDelegate?

    
    // MARK: IBActions
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        
        if delegate != nil {
            delegate?.lastPageDone()
        }
        
    }
}
