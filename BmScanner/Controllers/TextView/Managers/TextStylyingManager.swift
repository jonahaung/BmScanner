//
//  TextStylyingManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 10/5/21.
//

import SwiftUI


class TextStylyingManager {
    
    private let textView: AutoCompleteTextView
    
    init(textView: AutoCompleteTextView) {
        self.textView = textView
    }
    
    var styleColor: Color = .primary
    
    private var selectedTextRange: UITextRange? {
        get { return textView.selectedTextRange }
        set { textView.selectedTextRange = newValue }
    }
    
    private var selectedRange: NSRange {
        get { return textView.selectedRange }
        set { textView.selectedRange = newValue }
    }
    
    private var attributedText: NSAttributedString {
        get { return textView.attributedText }
        set { textView.attributedText = newValue }
    }
    
    private var textStorage: NSTextStorage {
        return textView.textStorage
    }
    
    private var undoManager: UndoManager? {
        return textView.undoManager
    }
    
    // Dynamics
    var fontName: String {
        guard textView.selectedRange.length > 0 else { return "Change"}
        if let x = textView.textStorage.attribute(.font, at: textView.selectedRange.location, effectiveRange: nil) as? UIFont {
            return x.fontName
        }
        return "Font Name"
    }
    var textColor: UIColor {
        guard textView.selectedRange.length > 0 else { return .label}
        if let x = textView.textStorage.attribute(.foregroundColor, at: textView.selectedRange.location, effectiveRange: nil) as? UIColor {
            return x
        }
        return .label
    }
    
    // Cleanup Text
    func cleanUpTexts() {
        var string = attributedText.string
        string = string.replacingOccurrences(of: "\n", with: " ")
        
        let originalLines = string.components(separatedBy: .lineEnding)
        
        var newLines = [String]()
        
        for originalLine in originalLines {
            let originalWords = originalLine.words()
            var newWords = [String]()
            
            for originalWord in originalWords {
                let segments = WordSegmentationManager.shared.tag(originalWord)
                let joined = segments.map{$0.tag}.joined()
                newWords.append(joined)
            }
            
            let newLine = newWords.joined(separator: " ")
            newLines.append(newLine)
        }
        let newSentence = newLines.joined(separator: "။ ")
        textView.text = newSentence
    }
    
    // Append Texts
    func appendTexts(appendingTexts: NSAttributedString) {
        let oldTexts = attributedText.mutable
        oldTexts.append(appendingTexts)
        attributedText = oldTexts
        let newRange = textStorage.editedRange
        
        selectedRange = newRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    // Joined Selected Texts
    func joinSelectedTexts() {
        let oldText = textStorage.attributedSubstring(from: selectedRange)
        let newText = oldText.string.lines().joined(separator: " ")
        textStorage.replaceCharacters(in: selectedRange, with: newText)
        undoManager?.registerUndo(withTarget: self, handler: {
            $0.textStorage.replaceCharacters(in: $0.selectedRange, with: oldText)
        })
    }
    
    // Font Size
    func updateFontSize(diff: CGFloat) {
        let appropriteRange = getAppropriteRange()
        textStorage.enumerateAttribute(.font, in: appropriteRange, options: .longestEffectiveRangeNotRequired) { (value, range, _) in
            if let oldFont = value as? UIFont {
                let oldFontDescriptor = oldFont.fontDescriptor
                let oldTraits = oldFontDescriptor.symbolicTraits
                var newFont: UIFont
                if let fontDescriptorWithSymbolicTraits = UIFontDescriptor(name: oldFont.fontName, size: oldFontDescriptor.pointSize + diff).withSymbolicTraits(oldTraits) {
                    newFont = UIFont(descriptor: fontDescriptorWithSymbolicTraits, size: oldFontDescriptor.pointSize + diff)
                } else {
                    newFont = UIFont(descriptor: oldFontDescriptor, size: oldFontDescriptor.pointSize + diff)
                }
                textStorage.addAttribute(.font, value: newFont, range: range)
            }
        }
        
        undoManager?.registerUndo(withTarget: self, handler: {
            $0.selectedRange = appropriteRange
            $0.updateFontSize(diff: -diff)
        })
        selectedRange = appropriteRange
    }
    
    // Font
    func updateFont(preferredFont: UIFont) {
        let appropriteRange = getAppropriteRange()
        guard let oldFont = textStorage.attribute(.font, at: appropriteRange.location, effectiveRange: nil) as? UIFont else {
            Log("No Font")
            return
        }
        
        let oldFontDescriptor = oldFont.fontDescriptor
        let oldTraits = oldFontDescriptor.symbolicTraits
        
        var newFont: UIFont
        if let fontDescriptorWithSymbolicTraits = UIFontDescriptor(name: preferredFont.fontName, size: oldFontDescriptor.pointSize).withSymbolicTraits(oldTraits) {
            newFont = UIFont(descriptor: fontDescriptorWithSymbolicTraits, size: 0)
        } else {
            newFont = UIFont(descriptor: oldFontDescriptor, size: 0)
        }
        textStorage.addAttribute(.font, value: newFont, range: appropriteRange)
        undoManager?.registerUndo(withTarget: self, handler: {
            $0.selectedRange = appropriteRange
            $0.updateFont(preferredFont: oldFont)
        })
        selectedRange = appropriteRange
    }

//    // Symbolic Traits
//    func updateSymbolicTraits(newTrait: UIFontDescriptor.SymbolicTraits) {
//        let appropriteRange = getAppropriteRange()
//        textStorage.enumerateAttribute(.font, in: appropriteRange, options: .longestEffectiveRangeNotRequired) { (value, range, pointer) in
//            if let font = value as? UIFont {
//                let fontDescriptor = font.fontDescriptor
//                var symbolicTraits = fontDescriptor.symbolicTraits
//                symbolicTraits.formSymmetricDifference(newTrait)
//
//                var newFont: UIFont
//
//                if let newFontDescriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) {
//                    newFont = UIFont(descriptor: newFontDescriptor, size: fontDescriptor.pointSize)
//                } else {
//                    newFont = UIFont(descriptor: fontDescriptor, size: 0)
//                }
//                textStorage.addAttribute(.font, value: newFont, range: range)
//            }
//        }
//        undoManager?.registerUndo(withTarget: self, handler: { target in
//            target.selectedRange = appropriteRange
//            target.updateSymbolicTraits(newTrait: newTrait)
//        })
//    }
    
    func selectParagraph() -> NSRange {
        if selectedRange.length == 0 {
            selectedRange = NSRange(location: 0, length: attributedText.length)
            return selectedRange
        }
        if selectedRange == NSRange(location: 0, length: attributedText.length) {
            return selectedRange
        }
        guard let selectedTextRange = self.selectedTextRange else { return selectedRange}
        guard let paragraphRange = textView.tokenizer.rangeEnclosingPosition(selectedTextRange.start, with: .paragraph, inDirection: .init(rawValue: 0)) else { return selectedRange }
        self.selectedTextRange = paragraphRange
        return selectedRange
    }
    
    // Alignment
    func updateAlignment(alignment: NSTextAlignment) {
        let paragraphRange = selectParagraph()
        let paragraphStyle = textStorage.paragraphStyple(at: paragraphRange)
        let oldAlignment = paragraphStyle?.alignment ?? NSTextAlignment.natural
        
        let newStyle = NSMutableParagraphStyle.defaultStyle
        newStyle.alignment = alignment
        
        textStorage.addAttributes([.paragraphStyle: newStyle], range: paragraphRange)
        undoManager?.registerUndo(withTarget: self, handler: { target in
            target.selectedRange = paragraphRange
            target.updateAlignment(alignment: oldAlignment)
        })
        selectedRange = paragraphRange
        textView.delegate?.textViewDidChange?(textView)
    }
    
    // TextColor Color
    func updateTextColor(color: UIColor) {
        let appropriteRange = getAppropriteRange()
        let oldColor = textStorage.getAttribute(for: .foregroundColor, at: appropriteRange)  as? UIColor ?? UIColor.label
        textStorage.addAttribute(.foregroundColor, value: color, range: appropriteRange)
        undoManager?.registerUndo(withTarget: self, handler: { target in
            target.selectedRange = appropriteRange
            target.updateTextColor(color: oldColor)
        })
        textView.delegate?.textViewDidChange?(textView)
    }
    
    var foregroundColorAtSelectedRange: UIColor {
        return textStorage.foregroundColor(at: selectedRange)
    }
    
    func toggleStrikeThrough() {
        toggleAttribute(attributs: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: foregroundColorAtSelectedRange])
    }
    func toggleHighlight(color: UIColor) {
        toggleAttribute(attributs: [.backgroundColor: color.withAlphaComponent(0.6)])
    }
    
    private func toggleAttribute(attributs: [NSAttributedString.Key: Any]) {
        let appropriteRange = getAppropriteRange()
        
        attributs.forEach{
            textStorage.toggleAttribute(key: $0.key, value: $0.value, selectedRange: appropriteRange)
        }
        undoManager?.registerUndo(withTarget: self, handler: { target in
            target.selectedRange = appropriteRange
            target.toggleAttribute(attributs: attributs)
        })
        selectedRange = appropriteRange
        textView.delegate?.textViewDidChange?(textView)
    }
    
    // Helpers
    private func getAppropriteRange() -> NSRange {
        var range = self.selectedRange
        if range.length == 0 {
            range = NSRange(location: 0, length: attributedText.length)
        }
        return range
    }
}
