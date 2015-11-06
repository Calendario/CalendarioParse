//
//  Follow.swift
//  Calendario
//
//  Created by Derek Cacciotti on 11/3/15.
//  Copyright © 2015 Calendario. All rights reserved.
//

import UIKit

class Follow: NSObject {
    
    var User:PFUser
    
    
    init(user:PFUser) {
        self.User = user
    }
    
    
    
    func getuser() -> String
    {
     
        return User.username!
    }
    
    
    
    

    
    
    
}