//
//  EliteDate.swift
//  EliteFramework
//
//  Created by Lifelong-Study on 2016/3/2.
//  Copyright © 2016年 Lifelong-Study. All rights reserved.
//

import UIKit

public extension Date {
    
    public var dateByZeroSecond: Date {
        return self
    }
    
    public func dateByZeroSecond(date: Date) -> Date {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        calendar.timeZone = .current
        
        let components = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS"
        
        let dateString = String(format: "%04d-%02d-%02d 00:00:00.0000", components.year!, components.month!, components.day!)
        
        return dateFormatter.date(from: dateString)!
    }
    
    public func cleanNanosecond() -> Date {
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = (calendar as NSCalendar?)?.components([.year, .month, .day, .hour, .minute, .second], from: self)
        
        components?.nanosecond = 0
        
        return calendar.date(from: components!) as Date!
    }
    
    public func string(format: String) -> String? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    var firstDayByTheYear: Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = (calendar as NSCalendar?)?.components([.year, .hour, .minute, .second], from: self)
        
        components?.month = 1
        components?.day = 1
        components?.nanosecond = 0
        
        return calendar.date(from: components!)
    }
    
    var firstDayByTheMonth: Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = (calendar as NSCalendar?)?.components([.year, .month, .hour, .minute, .second], from: self)
        
        components?.day = 1
        
        return calendar.date(from: components!)
    }
    
    var lastDayByTheMonth: Date? {
        return self.addingTimeInterval(Double(daysInTheMonth!) * 24 * 60 * 60)
    }
    
    var daysInTheMonth: Int? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        return (calendar as NSCalendar?)?.range(of: .day, in: .month, for: self).length
    }
    
    func calendar() -> Calendar? {
        return Calendar(identifier: Calendar.Identifier.gregorian)
    }
    
    var year:   Int? { return (calendar() as NSCalendar?)?.components([.year],   from: self).day    }
    var month:  Int? { return (calendar() as NSCalendar?)?.components([.month],  from: self).month  }
    var day:    Int? { return (calendar() as NSCalendar?)?.components([.day],    from: self).day    }
    var hour:   Int? { return (calendar() as NSCalendar?)?.components([.hour],   from: self).hour   }
    var minute: Int? { return (calendar() as NSCalendar?)?.components([.minute], from: self).minute }
    var second: Int? { return (calendar() as NSCalendar?)?.components([.second], from: self).second }
    
    var shortweek: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: self)
    }
    
    var longweek: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}
