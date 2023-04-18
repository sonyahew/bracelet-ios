//
//  DataExtension.swift
//  Metastones
//
//  Created by Ivan Tuang on 11/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return getTranslate(transID: self) ?? self
    }
    
    private func getTranslate(transID: String) -> String? {
        let appData = AppData.shared
        let translations = appData.translations?.data
        return translations?.filter({ $0?.transID == transID && $0?.langID == appData.data?.langId }).first??.transDesc
    }
    
    func currencyWithoutGrouping() -> String {
        return self.replacingOccurrences(of: ",", with: "")
    }
    
    func toCurrency() -> String {
        if let intStr = Double(self) {
            let numberStr = NSNumber(value:intStr)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = ""
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            return formatter.string(from: numberStr)!
        }
        
        return ""
    }
    
    func toDisplayCurrency() -> String {
        
        var isNegative = false
        var inputStr = self
        isNegative = self.contains("-") ? true : false
        if isNegative {
            inputStr = inputStr.replacingOccurrences(of: "-", with: "")
        }
        
        var finalStr = ""
        finalStr.append(isNegative ? "-" : "")
        if let intStr = Double(inputStr) {
            let numberStr = NSNumber(value:intStr)
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = ""
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            return finalStr.appending("\(formatter.string(from: numberStr)!)")
        }
        
        return ""
    }
    
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return "0.00"
        }
        
        return formatter.string(from: number)!
    }
    
    func toDate(fromFormat : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        return dateFormatter.date(from: self)
    }
    
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = NSCharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    var urlPercentEncoding: String {
        var charSet = CharacterSet.urlQueryAllowed
        charSet.insert(charactersIn: "#")
        charSet.insert(charactersIn: "%")
        return self.addingPercentEncoding(withAllowedCharacters: charSet) ?? ""
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }
    
    func safeMobileNo() -> String {
        let intLetters = self.prefix(4)
        let endLetters = self.suffix(2)
        let numberOfStars = self.count - (intLetters.count + endLetters.count)
        var starString = ""
        for _ in 1...numberOfStars {
            starString += "*"
        }
        
        return intLetters + starString + endLetters
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

extension Date {
    var hour: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self)
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    var month: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self)
    }
    
    var year: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
    
    func getFormattedDate(toFormat : String) -> String{
        let date = self
        let formatter = DateFormatter()
        
        formatter.dateFormat = toFormat
        
        return formatter.string(from: date)
    }
}

extension StringProtocol {
    //https://stackoverflow.com/questions/32305891/index-of-a-substring-in-a-string-with-swift
    
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension Double {
    var roundedTwoDecimal: Double {
        return (self*100).rounded()/100
    }
    
    var toStrDisplayCurr: String {
        return "\(self)".toDisplayCurrency()
    }
    
    var positiveOnly: Double {
        return self < 0 ? 0 : self
    }
}

extension Int {
    var yesNo: String {
        return self == 1 ? kLb.yes.localized : kLb.no.localized
    }
}
