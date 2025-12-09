//
//  String+Extenstions.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//


import Foundation

public extension String {
    func currentDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    func convertTo12HourFormat() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    func replace(_ string: String, replacement: String) -> String {
        replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    func formatNumber() -> String {
        // Number eg. --> +20 123 456 7891
        replace(" ", replacement: "")
            .replacingOccurrences(of: #"^([\d]{3})([\d]{1,3})?([\d]{1,4})?$"#, with: "$1 $2 $3", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
    func removeLeadingZero() -> String {
        if self.first == "0" {
            return String(self.dropFirst())
        }
        return self
    }
}

extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf16) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
