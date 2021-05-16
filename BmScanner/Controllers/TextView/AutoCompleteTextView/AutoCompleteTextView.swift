//
//  AutoCompleteTextView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 13/4/21.
//

import UIKit

final class AutoCompleteTextView: UITextView {
    
    override var attributedText: NSAttributedString!{
        didSet {
            guard oldValue != attributedText else { return }
            undoManager?.registerUndo(withTarget: self, handler: { target in
                target.attributedText = oldValue
            })
        }
    }
    
    var nexSuggesstion: String? {
        didSet {
            guard oldValue != nexSuggesstion else { return }
            setNeedsDisplay()
        }
    }
    
    // Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        allowsEditingTextAttributes = true
        spellCheckingType = .yes
        autocorrectionType = .no
        isEditable = false
        isSelectable = true
        showsVerticalScrollIndicator = false
        textContainerInset = UIEdgeInsets(top: 50, left: 5, bottom: 50, right: 5)
        keyboardDismissMode = .none
        dataDetectorTypes = .all
        
        inputView = UIView()
        
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        rightGesture.direction = .right
        addGestureRecognizer(rightGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] {
        var x = typingAttributes
        x.updateValue(UIColor.tertiaryLabel, forKey: .foregroundColor)
        return x
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let suggestedText = self.nexSuggesstion {
            let caretRect = self.caretRect(for: self.endOfDocument)
            let attr = suggestedTextAttributes
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - (attr[.font] as! UIFont).lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX + 3, y: caretRect.minY + diff)
            let suggestedRect = CGRect(origin: origin, size: size)
            
            suggestedText.draw(in: suggestedRect, withAttributes: attr)
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        guard isEditable else { return }
        if let suggestion = nexSuggesstion {
            nexSuggesstion = nil
            insertText(suggestion)
        }
    }
    
}

// Floating
extension AutoCompleteTextView {
    
    func toggleKeyboard() {
        isEditable.toggle()
        if inputView == nil {
            resignFirstResponder()
            inputView = UIView()
        }else {
            if selectedRange.location == 0 {
                ensureCaretToTheEnd()
            } else {
                selectedRange.length = 0
            }
            inputView = nil
            becomeFirstResponder()
            reloadInputViews()
        }
    }
}


extension AutoCompleteTextView: UIGestureRecognizerDelegate {
    
    private var isSelectedAll: Bool { return selectedRange.length == attributedText.length }
    
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isEditable {
            switch action {
            case #selector(paste(_:)):
                return UIPasteboard.general.string != nil
            case Selector(("_showTextStyleOptions:")):
                return false
            case #selector(delete(_:)):
                return super.canPerformAction(action, withSender: sender) && selectedRange.length > 0
            default:
                return super.canPerformAction(action, withSender: sender)
            }
        }else {
            switch action {
            case #selector(selectAll(_:)):
                return !isSelectedAll
            case #selector(delete(_:)):
                return !isSelectedAll
            case #selector(copy(_:)):
                return isSelectedAll
            case
                #selector(toggleBoldface(_:)),
                #selector(toggleUnderline(_:)),
                #selector(toggleItalics(_:)),
                Selector(("_showTextStyleOptions:")):
                return true
            default:
                return false
            }
        }
    }
    
    override func delete(_ sender: Any?) {
        let selecttedText = textStorage.attributedSubstring(from: selectedRange)
        let range = selectedRange
        textStorage.deleteCharacters(in: range)
        undoManager?.registerUndo(withTarget: self, handler: { target in
            target.selectedRange = range
            target.textStorage.insert(selecttedText, at: range.location)
            target.selectedRange = range
        })
        selectedRange.length = 0
        delegate?.textViewDidChange?(self)
    }
}

// Undo Manager
extension AutoCompleteTextView {
    
    func undo() {
        self.undoManager?.undo()
    }
    func redo() {
        self.undoManager?.redo()
    }
}
