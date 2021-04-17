//
//  TextEditorManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import UIKit

final class TextEditorManger: ObservableObject {
    
    private var originalText: NSAttributedString
    private var history = [NSAttributedString]()
    var hasHistory: Bool { return !history.isEmpty }
    let textView = AutoCompleteTextView()
    
    @Published var isEditing = false
    
    var currentFont = TextEditorFont.Regular {
        didSet {
            self.font = currentFont.font(for: fontSize, isMyanmar: attributedText.string.language == "my")
        }
    }
    
    var attributedText: NSAttributedString {
        get {
            return textView.attributedText
        }
        set {
            textView.attributedText = newValue
            updateHistory()
            objectWillChange.send()
        }
    }
    var font: UIFont {
        get {
            return textView.font!
        }
        set {
            textView.font = newValue
            updateHistory()
            objectWillChange.send()
        }
    }
    
    var fontSize: CGFloat {
        get {
            return font.pointSize
        }
        set {
            font = font.withSize(UIFontMetrics.default.scaledValue(for: newValue))
        }
    }
    private let note: Note
    
    init(note: Note) {
        self.note = note
        self.originalText = note.attributedText ?? NSAttributedString()
        self.attributedText = note.attributedText ?? NSAttributedString()
        textView.autocompleteTextViewDelegate = self
    }
    
    deinit {
        Log("Deinit")
    }
    
    
//    func adjustFont() {
//        text = originalText
////        let maxWidth = textView.contentSize.width - (textView.textContainerInset.left + textView.textContainerInset.right + textView.textContainer.lineFragmentPadding + 10)
//        let maxWidth = UIScreen.main.bounds.size.width - 45
//        let lines = textView.text.lines()
//        guard lines.count > 1 else { return }
//        if let longest = (lines.sorted{$0.count > $1.count }).first {
//            let height = CGFloat(30)
//            var fontSize = height
//            var textSize: CGSize {
//                return longest.boundingRect(with: CGSize(width: .infinity, height: height), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font.withSize(fontSize)], context: nil).size
//            }
//
//            repeat {
//                fontSize -= 0.5
//            } while textSize.width >= maxWidth
//            self.fontSize = max(8, min(30, fontSize))
//        }
//    }
}
// History
extension TextEditorManger {
    
    private func updateHistory() {
       
        if !history.contains(attributedText) && attributedText != originalText {
            SoundManager.vibrate(vibration: .soft)
            history.append(attributedText)
        }
    }
    func redo() {
        guard !history.isEmpty else { return }
        history.removeLast()
        attributedText = history.last ?? originalText
    }
}

extension TextEditorManger {
    
    func downSize() {
        fontSize -= 0.5
    }
    
    func upSize() {
        fontSize += 0.5
    }
    
    func selectAllTexts() {
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.endOfDocument)
    }
}

extension TextEditorManger {
    
    func convertToPDF() -> NSMutableData? {
        guard let attributedText = textView.attributedText else { return nil}
        let printFormatter = UISimpleTextPrintFormatter(attributedText: attributedText)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
//        let ratio = 841.8 / 595.2
//        let pageSize = CGSize(width: textView.frame.size.width, height: textView.frame.size.width * CGFloat(ratio))
//        let pageMargins = textView.textContainerInset
        
        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        
        return pdfData
    }
}

extension TextEditorManger: AutoCompleteTextViewDelegate {
    
    func textView(didChange textView: AutoCompleteTextView) {
        objectWillChange.send()
    }
    func textView(didBeginEditing textView: AutoCompleteTextView) {
        isEditing = true
    }
    func textView(didEndEditing textView: AutoCompleteTextView) {
        isEditing = false
    }
    func textView(layoutSubViews textView: AutoCompleteTextView) {
       
    }
}
