//
//  NSDate+Compare.swift
//  Calendario
//
//  Created by Derek Cacciotti on 2/8/16.
//  Copyright © 2016 Calendario. All rights reserved.
//

import UIKit

extension Date
{
    // this function compares a date to see if its greater than the passed date
    func isGreaterThanDate(_ datetoCompare:Date) -> Bool
    {
        var isGreater = false
        
        if self.compare(datetoCompare) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        return isGreater
    }
    
    // this function compares a date to see if its less than the passed date
    func isLessThanDate(_ dateToCompare:Date) -> Bool
    {
        var isLess = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        return isLess
    }
    
    // checks to see if the dates are equal
    func EqualtoDate(_ dateToCompare:Date) -> Bool
    {
        var isEqual = false
        
        if self.compare(dateToCompare) == ComparisonResult.orderedSame
        {
            isEqual = true
        }
        
        return isEqual
    }
    
    func DateisNotEqual(_ dateToCompare:Date) -> Bool
    {
        var notEqual = false
        
        if self.compare(dateToCompare) != ComparisonResult.orderedSame
        {
            notEqual = true
            
        }
        return notEqual
    }
}
