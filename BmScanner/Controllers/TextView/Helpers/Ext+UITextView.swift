//
//  Ext+UITextView.swift
//  BalarSarYwat
//
//  Created by Aung Ko Min on 5/11/19.
//  Copyright © 2019 Aung Ko Min. All rights reserved.
//

import UIKit

extension UITextView {
    
    func getWordRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: .init(rawValue: 1))
        }
        return nil 
    }
    
    func getSentenceRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .sentence, inDirection: .init(rawValue: 1))
        }
        return nil
    }
    func getLineRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .line, inDirection: .init(rawValue: 1))
        }
        return nil
    }
    func getCharacterRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .character, inDirection: .init(rawValue: 1))
        }
        return nil
    }
    func getParagraphRangeAtPosition(_ point: CGPoint) -> UITextRange? {
        if let textPosition = self.closestPosition(to: point) {
            return tokenizer.rangeEnclosingPosition(textPosition, with: .paragraph, inDirection: .init(rawValue: 1))
        }
        return nil
    }
    func getWordAtPosition(_ point: CGPoint) -> String? {
        if let range = getWordRangeAtPosition(point) {
            return self.text(in: range)
        }
        return nil
    }
    func getAttributsAtPosition(_ point: CGPoint) -> [NSAttributedString.Key: Any]? {
        let characterIndex = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if let attributes = attributedText?.attributes(at: characterIndex, effectiveRange: nil) {
            return attributes
        }
        return nil
    }
    
    func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSMakeRange(-1, 0)) // Scroll to bottom
        } else {
            self.scrollRangeToVisible(NSMakeRange(0, 0)) // Scroll to top
        }
    }
    func ensureCaretToTheEnd() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }
}

extension UIScrollView{

    func scrollToBottom(animated: Bool) {
        var offset = contentOffset
        let inset = contentInset
        offset.y = max(-inset.top, contentSize.height - bounds.height + inset.bottom + safeAreaInsets.bottom)
        
        setContentOffset(offset, animated: animated)
    }
    
}

extension NSAttributedString {
    var range: NSRange { return NSRange(location: 0, length: length)}
    var mutable: NSMutableAttributedString { return NSMutableAttributedString(attributedString: self) }
}
