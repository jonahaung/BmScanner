//
//  AutoCompleteTextView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 13/4/21.
//

import UIKit
protocol AutoCompleteTextViewDelegate: class {
    
    func textView(layoutSubViews textView: AutoCompleteTextView)
    func textView(didEndEditing textView: AutoCompleteTextView)
    func textView(didBeginEditing textView: AutoCompleteTextView)
    func textView(didChange textView: AutoCompleteTextView)
}
final class AutoCompleteTextView: UITextView {
    
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.tertiaryLabel]
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
            let attributes = attributedText.attributes(at: attributedText.length - 1, effectiveRange: nil)
            typingAttributes = attributes
            suggestedTextAttributes = attributes
            suggestedTextAttributes.updateValue(UIColor.tertiaryLabel, forKey: .foregroundColor)
        }
    }
    
    override var font: UIFont? {
        didSet {
            guard let font = self.font else { return }
            typingAttributes.updateValue(font, forKey: .font)
            suggestedTextAttributes.updateValue(font, forKey: .font)
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
        autocompleteTextViewDelegate?.textView(layoutSubViews: self)
    }
}


extension AutoCompleteTextView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let suggestedText = self.suggestedText {
            let caretRect = self.caretRect(for: self.endOfDocument)
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - (self.font!).lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX, y: caretRect.minY + diff)
            suggestedRect = CGRect(origin: origin, size: size)
        
            suggestedText.draw(in: suggestedRect, withAttributes: suggestedTextAttributes)
        }
    }
}

extension AutoCompleteTextView {

    private func setup() {
        tintColor = .link
        allowsEditingTextAttributes = true
        isSelectable = true
        isScrollEnabled = true
        showsVerticalScrollIndicator = false
        textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textContainer.lineFragmentPadding = 0
        showsHorizontalScrollIndicator = false
        keyboardDismissMode = .interactive
        dataDetectorTypes = .all
    
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        leftGesture.direction = .left
        addGestureRecognizer(leftGesture)
        delegate = self
    }
}

extension AutoCompleteTextView: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        suggestedText = nil
        autocompleteTextViewDelegate?.textView(didEndEditing: self)
        return true
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        autocompleteTextViewDelegate?.textView(didBeginEditing: self)
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        autocompleteTextViewDelegate?.textView(didChange: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let subString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if text == " " {
            
        }else {
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
    private func findNextWord(text: String) {
        oprationQueue.cancelAllOperations()
        oprationQueue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            let lastWord = text.lastWord.trimmed
            
            var suggestingText: String?
            
            suggestingText = self.wordPredictManager.pridict(text: lastWord)
            OperationQueue.main.addOperation {
                self.suggestedText = suggestingText
            }
        }
    }
 
}
extension AutoCompleteTextView: UIGestureRecognizerDelegate {
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
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
            
            findNextWord(text: text)
        }
    }
    @objc private func swipeLeft(_ gesture: UISwipeGestureRecognizer) {
//        (1...text.lastWord.utf16.count).forEach { _ in
//            deleteBackward()
//        }
        findNextWord(text: text)
        
    }
}
