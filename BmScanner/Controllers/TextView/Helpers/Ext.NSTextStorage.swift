//
//  BmTextStorage.swift
//  BmScanner
//
//  Created by Aung Ko Min on 9/5/21.
//

import UIKit

extension NSTextStorage {
    func toggleAttribute(key: NSAttributedString.Key, value: Any, selectedRange: NSRange) {
        if self.attribute(key, at: selectedRange.location, longestEffectiveRange: nil, in: selectedRange) != nil {
            self.removeAttribute(key, range: selectedRange)
        } else {
            self.addAttribute(key, value: value, range: selectedRange)
        }
    }
    
    func foregroundColor(at range: NSRange) -> UIColor {
        return getAttribute(for: .foregroundColor, at: range) as? UIColor ?? UIColor.label
    }
    
    func paragraphStyple(at range: NSRange) -> NSMutableParagraphStyle? {
        return getAttribute(for: .paragraphStyle, at: range) as? NSMutableParagraphStyle
    }
    func getAttribute(for key: NSAttributedString.Key, at range: NSRange) -> Any? {
        return attribute(key, at: range.location, longestEffectiveRange: nil, in: range)
    }
}
