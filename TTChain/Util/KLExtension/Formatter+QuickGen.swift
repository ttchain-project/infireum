//
//  DateFormatter+QuickGen.swift
//  UniversalModule
//
//  Created by keith.lee on 2016/11/15.
//  Copyright © 2016年 git4u. All rights reserved.
//

import Foundation
extension Decimal {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int, rule: FloatingPointRoundingRule) -> Decimal {
//        let divisor = pow(10, places)
        return doubleValue
                    .rounded(toPlaces: places,
                             rule: rule)
                    .decimalValue
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int, rule: FloatingPointRoundingRule) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(rule) / divisor
    }
}

extension Decimal {
    var decimalValue: Decimal {
        return self
    }
    
    var doubleValue: Double {
        return Double(truncating: NSDecimalNumber(decimal:self))
    }
    
    func asString(digits: Int, force: Bool = false, separator sep: String = "", maxDigits: Int? = nil, digitMoveCondition: ((String) -> Bool)? = nil) -> String {
        let str = NumberFormatter.decimalString(fromDecimal: self, withDigits: digits, separator: sep, forceDigit: force)!
        
        if let maxDigit = maxDigits, let condition = digitMoveCondition {
            let shouldModeAtCondition = condition(str)
            if !shouldModeAtCondition || digits == maxDigit {
                return str
            }else {
                return asString(
                    digits: digits + 1,
                    force: force,
                    separator: sep,
                    maxDigits: maxDigits,
                    digitMoveCondition: digitMoveCondition
                )
            }
        }else {
            return str
        }
    }
}

extension Double {
    var decimalValue: Decimal {
        return Decimal.init(self.rounded(toPlaces: 18,
                                         rule: .toNearestOrAwayFromZero))
    }
    
    func asString(digits: Int, force: Bool = false, separator sep: String = "", maxDigits: Int? = nil, digitMoveCondition: ((String) -> Bool)? = nil) -> String {
        let str = NumberFormatter.decimalString(fromDoubleValue: self, withDigits: digits, separator: sep, forceDigit: force)!
        
        if let maxDigit = maxDigits, let condition = digitMoveCondition {
            let shouldModeAtCondition = condition(str)
            if !shouldModeAtCondition || digits == maxDigit {
                return str
            }else {
                return asString(
                    digits: digits + 1,
                    force: force,
                    separator: sep,
                    maxDigits: maxDigits,
                    digitMoveCondition: digitMoveCondition
                )
            }
        }else {
            return str
        }
        
    }
}

extension Float {
    func asString(digits: Int, force: Bool = false, separator sep: String = "") -> String {
        return NumberFormatter.decimalString(fromFloatValue: self, withDigits: digits, separator: sep, forceDigit: force)!
    }
}

extension DateFormatter {
    
    /// Quick generate dateString from specific date of current locale
    ///
    /// - Parameters:
    ///   - date: date
    ///   - format: format
    /// - Returns: dateString
    static func dateString(from date: Date, withFormat format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    
    /// Quick generate date from current locale
    ///
    /// - Parameters:
    ///   - dateString: original date string
    ///   - format: date format
    /// - Returns: parsed date (optional)
    static func date(from dateString: String, withFormat format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.date(from: dateString)
    }
}

extension NumberFormatter {
    static func decimalString(fromDecimal: Decimal, withDigits digits:Int, separator sep: String = "", forceDigit: Bool = false) -> String? {
        
        let ns = NumberFormatter.init()
        ns.allowsFloats = true
        ns.maximumFractionDigits = digits
        if forceDigit {
            ns.minimumFractionDigits = digits
        }
        
        
        ns.roundingMode = .floor
        ns.numberStyle = .decimal
        ns.groupingSeparator = sep
        
        return ns.string(from: NSDecimalNumber.init(decimal: fromDecimal))
        
    }
    
    
    static func decimalString(fromFloatValue:Float, withDigits digits:Int, separator sep: String = "", forceDigit: Bool = false) -> String? {
        let ns = NumberFormatter.init()
        ns.allowsFloats = true
        ns.maximumFractionDigits = digits
        if forceDigit {
            ns.minimumFractionDigits = digits
        }
        
        
        ns.roundingMode = .floor
        ns.numberStyle = .decimal
        ns.groupingSeparator = sep
        
        return ns.string(from: NSNumber.init(value: fromFloatValue))
    }
    
    static func decimalString(fromDoubleValue:Double, withDigits digits:Int, separator sep: String = "", forceDigit: Bool = false) -> String? {
        let ns = NumberFormatter.init()
        ns.allowsFloats = true
        ns.maximumFractionDigits = digits
        if forceDigit {
            ns.minimumFractionDigits = digits
        }
        ns.roundingMode = .floor
        ns.numberStyle = .decimal
        ns.groupingSeparator = sep
        
        return ns.string(from: NSNumber.init(value: fromDoubleValue))
    }

    
    static func decimalString(from number:NSNumber, withDigits digits:Int) -> String? {
        let ns = NumberFormatter.init()
        ns.allowsFloats = true
        ns.maximumFractionDigits = digits
        ns.numberStyle = .decimal
        ns.roundingMode = .floor
        
        return ns.string(from: number)
    }
    
    static func decimalNoDigitString(from number:NSNumber) -> String? {
        return self.decimalString(from: number, withDigits: 0)
    }
    
    static func numberOfDecimalString(from string:String, withDigits digits:Int) -> NSNumber? {
        let ns = NumberFormatter.init()
        ns.allowsFloats = true
        ns.maximumFractionDigits = digits
        ns.numberStyle = .decimal
        ns.roundingMode = .floor
        return ns.number(from: string)
    }
    
    static func numberOfNoDigitsDecimalString(from string:String) -> NSNumber? {
        return self.numberOfDecimalString(from: string, withDigits: 0)
    }
}
