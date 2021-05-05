//
//  AutoCompleteTextView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 13/4/21.
//

import UIKit

final class AutoCompleteTextView: UITextView {
    
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] {
        var attr = typingAttributes
        attr[.foregroundColor] = UIColor.tertiaryLabel
        return attr
    }
    private lazy var wordPredictManager = WordPredictManager()
    
    var suggestedText: String? {
        didSet {
            if oldValue != suggestedText {
                setNeedsDisplay()
            }
        }
    }

    override var attributedText: NSAttributedString!{
        didSet {
            delegate?.textViewDidChange?(self)
            typingAttributes = attributedText.attributes(at: attributedText.length - 1, effectiveRange: nil)
        }
    }

    private var suggestedRect = CGRect.zero
    private let oprationQueue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
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
            let attr = suggestedTextAttributes
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - (attr[.font] as! UIFont).lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX, y: caretRect.minY + diff)
            suggestedRect = CGRect(origin: origin, size: size)
            
            suggestedText.draw(in: suggestedRect, withAttributes: attr)
        }
    }
}

extension AutoCompleteTextView {
    
    private func setup() {
        allowsEditingTextAttributes = true
        isEditable = false
        isSelectable = true
        showsVerticalScrollIndicator = false
        textContainerInset = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        textContainer.lineFragmentPadding = 10
        textContainer.lineBreakMode = .byWordWrapping
        keyboardDismissMode = .none
        dataDetectorTypes = .all
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
    }
}

extension AutoCompleteTextView: UITextViewDelegate {
    
    func findCompletions(text: String) {
        
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
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UITapGestureRecognizer, !isEditable {
            if selectedRange.length == 0 {
                gesture.delaysTouchesBegan = true
                let point = gesture.location(in: self)
                let textRange = self.getLineRangeAtPosition(point)
                selectedTextRange = textRange
                gesture.delaysTouchesEnded = true
            }else {
                selectedRange = NSRange(location: selectedRange.location + selectedRange.length, length: 0)
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
