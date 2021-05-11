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
    
    
    weak var textStylyingManager: TextStylyingManager?
    
    // Init
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        allowsEditingTextAttributes = true
        spellCheckingType = .yes
        autocorrectionType = .yes
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
    
    
    var suggestedText: String? {
        didSet {
            guard oldValue != suggestedText else { return }
            setNeedsDisplay()
        }
    }
    
    private var suggestedTextAttributes: [NSAttributedString.Key: Any] {
        var x = typingAttributes
        x.updateValue(UIColor.tertiaryLabel, forKey: .foregroundColor)
        return x
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let suggestedText = self.suggestedText {
            let caretRect = self.caretRect(for: self.endOfDocument)
            let attr = suggestedTextAttributes
            
            let size = CGSize(width: rect.width - caretRect.maxX, height: 50)
            let diff = (caretRect.height - (attr[.font] as! UIFont).lineHeight) / 2
            
            let origin = CGPoint(x: caretRect.maxX + 3, y: caretRect.minY + diff)
            let suggestedRect = CGRect(origin: origin, size: size)
            
            suggestedText.draw(in: suggestedRect, withAttributes: attr)
        }
    }
    
    @objc private func swipeRight(_ gesture: UISwipeGestureRecognizer) {
        guard isEditable else { return }
        if let suggestion = suggestedText {
            suggestedText = nil
            insertText(" "+suggestion)
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
            if selectedRange.length == 0 {
                ensureCaretToTheEnd()
            }
            inputView = nil
            becomeFirstResponder()
            reloadInputViews()
        }
    }
}


extension AutoCompleteTextView: UIGestureRecognizerDelegate {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isEditable {
            switch action {
            case
                #selector(delete(_:)),
                #selector(makeTextWritingDirectionRightToLeft(_:)),
                #selector(makeTextWritingDirectionLeftToRight(_:)):
                return true
            default:
                return super.canPerformAction(action, withSender: sender)
            }
        }else {
            
            switch action {
            case
                #selector(delete(_:)),
                #selector(selectAll(_:)),
                Selector(("_showTextStyleOptions:")),
                #selector(makeTextWritingDirectionRightToLeft(_:)),
                #selector(makeTextWritingDirectionLeftToRight(_:)),
                #selector(toggleBoldface(_:)),
                #selector(toggleUnderline(_:)),
                #selector(toggleItalics(_:)):
                return true
            default:
                return false
            }
        }
    }
    
    override func delete(_ sender: Any?) {
        textStorage.deleteCharacters(in: selectedRange)
        selectedRange.length = 0
    }
    
    override func makeTextWritingDirectionLeftToRight(_ sender: Any?) {
        textStylyingManager?.updateAlignment(alignment: .right)
    }
    override func makeTextWritingDirectionRightToLeft(_ sender: Any?) {
        textStylyingManager?.updateAlignment(alignment: .left)
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
