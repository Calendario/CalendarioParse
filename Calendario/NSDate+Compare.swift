//
//  NSDate+Compare.swift
//  Calendario
//
//  Created by Derek Cacciotti on 2/8/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

extension NSDate
{
    // this function compares a date to see if its greater than the passed date
    func isGreaterThanDate(datetoCompare:NSDate) -> Bool
    {
        var isGreater = false
        
        if self.compare(datetoCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        return isGreater
    }
    
    // this function compares a date to see if its less tah the passed date 
    func isLessThanDate(dateToCompare:NSDate) -> Bool
    {
        var isLess = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        return isLess
    }
    
    // checks to see if the dates are equal
    func EqualtoDate(dateToCompare:NSDate) -> Bool
    {
        var isEqual = false
        
        if self.compare(dateToCompare) == NSComparisonResult.OrderedSame
        {
            isEqual = true
        }
        
        return isEqual
    }
    
    func DateisNotEqual(dateToCompare:NSDate) -> Bool
    {
        var notEqual = false
        
        if self.compare(dateToCompare) != NSComparisonResult.OrderedSame
        {
            notEqual = true
            
        }
        return notEqual
    }
    
}
