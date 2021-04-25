//
//  AutoCompleteTextView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 13/4/21.
//

import UIKit
protocol AutoCompleteTextViewDelegate: class {
    func textViewDidChange(_ textView: AutoCompleteTextView)
    func textViewDidEndEditing(_ textView: AutoCompleteTextView)
    func textViewDidBeginEditing(_ textView: AutoCompleteTextView)
    func textViewDidChangeSelection(_ textView: AutoCompleteTextView)
}
final class AutoCompleteTextView: UITextView {
    
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.quaternaryLabel]
    weak var autocompleteTextViewDelegate: AutoCompleteTextViewDelegate?
    private lazy var wordPredictManager = WordPredictManager()
    
    var suggestedText: String? {
        didSet {
            if oldValue != suggestedText {
                setNeedsDisplay()
            }
        }
    }
    
    private var suggestedRect = CGRect.zero
    private let oprationQueue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    override var attributedText: NSAttributedString!{
        didSet {
            updateTypingAttributes()
            autocompleteTextViewDelegate?.textViewDidChange(self)
        }
    }
    
    private func updateTypingAttributes() {
        let attributes = attributedText.attributes(at: attributedText.length - 1, effectiveRange: nil)
        suggestedTextAttributes = attributes
        suggestedTextAttributes.updateValue(UIColor.tertiaryLabel, forKey: .foregroundColor)
        if let newFont = typingAttributes.filter({ $0.key == .font }).first?.value as? UIFont, self.font != newFont {
            self.font = newFont
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}


extension AutoCompleteTextView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let suggestedText = self.suggestedText {
            let caretRect = self.caretRect(for: self.endOfDocument)
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - (font!).lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX, y: caretRect.minY + diff)
            suggestedRect = CGRect(origin: origin, size: size)
            
            suggestedText.draw(in: suggestedRect, withAttributes: suggestedTextAttributes)
        }
    }
}

extension AutoCompleteTextView {
    
    private func setup() {
        isEditable = false
        tintColor = .link
        allowsEditingTextAttributes = false
        isSelectable = true
        isScrollEnabled = true
        showsVerticalScrollIndicator = false
        textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 120, right: 10)
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        dataDetectorTypes = .all
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
        //
        //        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        //        leftGesture.direction = .left
        //        addGestureRecognizer(leftGesture)
        
        delegate = self
    }
}

extension AutoCompleteTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        autocompleteTextViewDelegate?.textViewDidChange(self)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        suggestedText = nil
        autocompleteTextViewDelegate?.textViewDidEndEditing(self)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        autocompleteTextViewDelegate?.textViewDidBeginEditing(self)
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        autocompleteTextViewDelegate?.textViewDidChangeSelection(self)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let subString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if text != " " {
            findCompletions(text: subString)
        }
        return true
    }
    
    private func findCompletions(text: String) {
        
        oprationQueue.cancelAllOperations()
        oprationQueue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            let lastWord = text.lastWord.trimmed
            
            var suggestingText: String?
            
            suggestingText = self.wordPredictManager.completion(for: lastWord)
            OperationQueue.main.addOperation {
                self.suggestedText = suggestingText
            }
        }
    }
}
extension AutoCompleteTextView: UIGestureRecognizerDelegate {
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        guard isEditable else { return }
        gesture.delaysTouchesBegan = true
        if !text.isEmpty {
            
            if let suggestion = suggestedText {
                suggestedText = nil
                insertText(suggestion+" ")
                
                gesture.delaysTouchesEnded = true
                
            } else {
                if text.hasSuffix(" ") {
                    deleteBackward()
                    gesture.delaysTouchesEnded = true
                    return
                }
                (1...text.lastWord.utf16.count).forEach { _ in
                    deleteBackward()
                }
                gesture.delaysTouchesEnded = true
            }
            ensureCaretToTheEnd()
        }
    }
    
    
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        super.touchesBegan(touches, with: event)
    //        guard !isEditable else { return }
    //        if let first = touches.first {
    //            let position = first.location(in: self)
    //            let textRange = self.getLineRangeAtPosition(position)
    //            selectedTextRange = textRange
    //        }
    //
    //    }
    
}
