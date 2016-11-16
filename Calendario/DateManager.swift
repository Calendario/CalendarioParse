//
//  DateManager.swift
//  Calendario
//
//  Created by Daniel Sadjadian on 21/02/2016.
//  Copyright © 2016 Calendario. All rights reserved.
//

import Foundation
import Parse

/***************************************************

IMPORTANT PLEASE READ:

This class is all about date related methods such
as figuring out the difference between two dates
and returning the appropriate difference string.

***************************************************/

// DateManager class contains all the methods
// in relations to the status update dates.
@objc class DateManager : NSObject {
    
    @objc class func createDateDifferenceString(_ inputDate: Date, completion: @escaping (_ difference: String) -> Void) {
        
        // Get the current date.
        let currentDate: Date = Date()
        
        // Get the standard Gregorian calendar.s
        let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        // Calculate the different between the
        // current date and the input date.
        let components: DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute , NSCalendar.Unit.second], from: inputDate, to: currentDate, options: [])
        
        // Create the difference string.
        var result: String!
        
        // Set the difference string depending on the
        // year, month, day and seconds calculated.
        
        if (components.year! > 1) {
            result = "\(components.year!) years ago"
        }
            
        else if (components.year! == 1) {
            result = "1 year ago"
        }
        
        else {
            
            if (components.month! > 1) {
                result = "\(components.month!) months ago"
            }
                
            else if (components.month! == 1) {
                result = "1 month ago"
            }
            
            else {
                
                if (components.day! > 1) {
                    result = "\(components.day!) days ago"
                }
                    
                else if (components.day! == 1) {
                    result = "1 day ago"
                }
                
                else {
                    
                    if (components.hour! > 1) {
                        result = "\(components.hour!) hours ago"
                    }
                        
                    else if (components.hour! == 1) {
                        result = "1 hour ago"
                    }
                    
                    else {
                        
                        if (components.minute! > 1) {
                            result = "\(components.minute!) minutes ago"
                        }
                            
                        else if (components.minute! == 1) {
                            result = "1 minute ago"
                        }
                        
                        else {
                            
                            if (components.second! > 1) {
                                result = "\(components.second!) seconds ago"
                            }
                                
                            else {
                                result = "just posted"
                            }
                        }
                    }
                }
            }
        }
        
        // Return the difference string.
        DispatchQueue.main.async(execute: {
            completion(result)
        })
    }
}
