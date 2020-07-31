//
//  String+Extension.swift
//  OfflineWallet
//
//  Created by Song-Hua on 2018/10/29.
//  Copyright © 2018 gib. All rights reserved.
//

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension StringProtocol {
    var drop0xPrefix: SubSequence { hasPrefix("0x") ? dropFirst(2) : self[...] }
    var drop0bPrefix: SubSequence { hasPrefix("0b") ? dropFirst(2) : self[...] }
    var hexaToDecimal: Int { Int(drop0xPrefix, radix: 16) ?? 0 }
    var hexaToBinary: String { .init(hexaToDecimal, radix: 2) }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    var decimalToBinary: String { .init(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal: Int { Int(drop0bPrefix, radix: 2) ?? 0 }
    var binaryToHexa: String { .init(binaryToDecimal, radix: 16) }
}

enum ConvertDecimalError: Error {
    case InvalidateValue
}
extension StringProtocol {
    func converHexStringToDecimal() throws -> Decimal {
        if !self.hasPrefix("0x") {
            throw ConvertDecimalError.InvalidateValue
        }
       let hexValue = self.suffix(self.count-2)
        let power = pow(Decimal(16), 10)
        var ans: Decimal = Decimal(string: "0")!
        var mod: Int = 0

        var calString = hexValue
        for i in stride(from: 0, through: hexValue.count, by: 10) {
            let getLastCount = hexValue.count - i > 10 ? 10 : hexValue.count - i

            let calc = calString.suffix(getLastCount)
            guard let value = Int64(calc, radix: 16) else {
                throw ConvertDecimalError.InvalidateValue
            }
            var dec = Decimal(value)

            for _ in 0..<mod {
                dec = dec * power
            }
            ans += dec
            calString = calString.dropLast(10)
            mod += 1
        }

        return ans
    }
}
