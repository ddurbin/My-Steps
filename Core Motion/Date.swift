//
//  Date.swift
//  Core Motion
//
//  Created by DANIEL DURBIN on 8/6/15.
//  Copyright (c) 2015 DANIEL DURBIN. All rights reserved.
//

import Foundation

class Date {
    class func from (year:Int, month:Int, day:Int) -> Foundation.Date {
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        let gregorianCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = gregorianCalendar.date(from: components)
        
        return date!
    }
    
    class func toString(date:Foundation.Date) -> NSString {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "EEE, MMM dd yyyy - hh:mm a"
        let dateString = dateStringFormatter.string(from: date)
        return dateString as NSString
    }
}

