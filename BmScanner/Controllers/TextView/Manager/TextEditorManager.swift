//
//  TextEditorManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import UIKit

final class TextEditorManger: ObservableObject {
    
    private let note: Note
    private var originalText: NSAttributedString
    private var history = [NSAttributedString]()
    var hasHistory: Bool { return !history.isEmpty }
    
    let textView = AutoCompleteTextView()
    var isEditable: Bool {
        get { return textView.isEditable }
        set {
            textView.isEditable = newValue
            objectWillChange.send()
        }
    }
    var isEditing: Bool {
        get { return textView.isFirstResponder }
        set {
            if newValue {
                textView.becomeFirstResponder()
            } else {
                textView.resignFirstResponder()
            }
        }
    }
    var isSelectedAll: Bool {
        return textView.selectedRange == NSRange(location: 0, length: attributedText.length)
    }

    var hasSelectedText: Bool {
        return textView.selectedRange.length > 0
    }
    
    var attributedText: NSAttributedString {
        get {
            return textView.attributedText
        }
        set {
            guard newValue != attributedText else { return }
            textView.attributedText = newValue
            updateHistory()
        }
    }
    
    
    
    init(note: Note) {
        self.note = note
        self.originalText = (note.attributedText ?? NSAttributedString())
        self.attributedText = originalText
        textView.autocompleteTextViewDelegate = self
        
    }
    
    deinit {
        Log("Deinit")
    }
}
// History
extension TextEditorManger {
    
    private func updateHistory() {
        SoundManager.vibrate(vibration: .soft)
        if attributedText != originalText {
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
    func updateFont(currentFont: TextEditorFont) {
       
        var selectedRange = NSRange(location: 0, length: 0)
        if !hasSelectedText {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        } else {
            selectedRange = textView.selectedRange
        }
        
        let newText = attributedText.mutable
        let new = currentFont.font(for: 17, isMyanmar: attributedText.string.language == "my")
       
        attributedText.enumerateAttribute(.font, in: textView.selectedRange, options: .longestEffectiveRangeNotRequired) { (value, range, pointer) in
            if let old = value as? UIFont {
                newText.addAttributes([.font: new.withSize(old.pointSize)], range: range)
            }
        }
        self.attributedText = newText
        if selectedRange.length != attributedText.length {
            textView.selectedRange = selectedRange
            textView.scrollRangeToVisible(selectedRange)
        }
    }
    private func updateFontSize(diff: CGFloat) {
        var selectedRange = NSRange(location: 0, length: 0)
        if !hasSelectedText {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        } else {
            selectedRange = textView.selectedRange
        }
        let newText = attributedText.mutable
        attributedText.enumerateAttribute(.font, in: selectedRange, options: .longestEffectiveRangeNotRequired) { (value, range, pointer) in
            if let old = value as? UIFont {
                newText.addAttributes([.font: old.withSize(old.pointSize + diff)], range: range)
            }
        }
        attributedText = newText
        if selectedRange.length != attributedText.length {
            textView.selectedRange = selectedRange
            textView.scrollRangeToVisible(selectedRange)
        }
    }
    func downSize() {
        updateFontSize(diff: -1)
    }
    
    func upSize() {
        updateFontSize(diff: 1)
    }
    
    func highlight() {
        var selectedRange = NSRange(location: 0, length: 0)
        if !hasSelectedText {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        } else {
            selectedRange = textView.selectedRange
        }
        let newText = attributedText.mutable
        
        
        attributedText.enumerateAttribute(.backgroundColor, in: selectedRange, options: .longestEffectiveRangeNotRequired) { (value, range, pointer) in
            if value == nil {
                newText.addAttributes([.backgroundColor: UIColor.systemYellow.withAlphaComponent(0.6)], range: range)
            } else {
                newText.removeAttribute(.backgroundColor, range: range)
            }
        }
        attributedText = newText
        if selectedRange.length != attributedText.length {
            textView.selectedRange = selectedRange
            textView.scrollRangeToVisible(selectedRange)
        }
    }
    
    
    func appendTexts(newText: NSAttributedString) {
        let text = attributedText.mutable
        text.append(NSAttributedString(string: "\n"))
        text.append(newText)
        attributedText = text
        textView.scrollToBottom(animated: true)
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
    
    func convertToImages()  -> [UIImage] {
        if let data = convertToPDF(), let cgData = CGDataProvider(data: data) {
            guard let document = CGPDFDocument(cgData) else { return [] }
            var images = [UIImage]()
            for i in (1..<document.numberOfPages+1) {
                guard let page = document.page(at: i) else { continue }
                let pageRect = page.getBoxRect(.artBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)
                    
                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    
                    ctx.cgContext.drawPDFPage(page)
                }
                let ciImage = CIImage(image: img)
                let cgOrientation = CGImagePropertyOrientation(img.imageOrientation)
                if let orientedImage = ciImage?.oriented(forExifOrientation: Int32(cgOrientation.rawValue)).uiImage {
                    images.append(orientedImage)
                }
            }
            return images
        }
        return []
    }
    
}

extension TextEditorManger: AutoCompleteTextViewDelegate {
    
    func textViewDidChange(_ textView: AutoCompleteTextView) {
        SoundManager.vibrate(vibration: .soft)
    }
    
    
    func textViewDidEndEditing(_ textView: AutoCompleteTextView) {
        isEditable = false
    }
    
    func textViewDidBeginEditing(_ textView: AutoCompleteTextView) {
        objectWillChange.send()
    }
    
    func textViewDidChangeSelection(_ textView: AutoCompleteTextView) {
        objectWillChange.send()
    }
}
