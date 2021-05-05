//
//  TextEditorManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import UIKit

final class TextEditorManger: NSObject, ObservableObject {
    
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case ShareMenu, InfoSheet, EditMenuSheet, AlignmentSheet, FontWeightSheet
    }
    
    enum FullScreenType: Identifiable {
        var id: FullScreenType { return self }
        case ShareAttributedText, ShareAsPDF, PDFViewer, FolderPicker, ShareAsImages
    }
    
    @Published var sheetType: ActionSheetType?
    @Published var fullScreenType: FullScreenType?
    
    private let note: Note
    private var history = [NSAttributedString]()
    var hasHistory: Bool { return !history.isEmpty }
    
    let textView = AutoCompleteTextView()
    
    var attributedText: NSAttributedString {
        get {
            return textView.attributedText
        }
        set {
            guard newValue != attributedText else { return }
            textView.attributedText = newValue
            SoundManager.vibrate(vibration: .soft)
        }
    }
    
    
    init(note: Note) {
        self.note = note
        super.init()
        self.attributedText = note.attributedText ?? NSAttributedString()
        textView.delegate = self
    }
    
    deinit {
        Log("Deinit")
    }
    
    func editingChanged(isEditing: Bool) {
        textView.isEditable = isEditing
        if isEditing && !textView.isFirstResponder {
            textView.becomeFirstResponder()
        } else if !isEditing && textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        SoundManager.vibrate(vibration: .rigid)
    }
}
// History
extension TextEditorManger {
    
    private func updateHistory() {
        if attributedText != note.attributedText && history.last != attributedText && attributedText.string == note.attributedText?.string {
            history.append(attributedText)
        }
    }
    
    func redo() {
        guard !history.isEmpty else { return }
        if history.last == attributedText {
            history.removeLast()
        }
        attributedText = history.last ?? note.attributedText ?? NSAttributedString()
    }
    
    func save() {
        if note.attributedText != attributedText {
            note.id = UUID()
            note.attributedText = attributedText
            note.text = note.attributedText?.string
            note.edited = Date()
            note.folder?.edited = Date()
        }
    }
}


extension TextEditorManger {
    
    private func updateFontSize(diff: CGFloat) {
        var selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        }
        let newText = attributedText.mutable
        
        newText.enumerateAttributes(in: selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            var attributes = attributes
            if let font = attributes[.font] as? UIFont { 
                attributes[.font] = font.withSize(font.pointSize + diff)
            }
            newText.setAttributes(attributes, range: range)
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
        var selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        }
        
        let newText = attributedText.mutable
        
        newText.enumerateAttributes(in: selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            var attributes = attributes
            if attributes[.backgroundColor] != nil {
                attributes.removeValue(forKey: .backgroundColor)
            } else {
                attributes[.backgroundColor] = UIColor.systemYellow.withAlphaComponent(0.6)
            }
            newText.setAttributes(attributes, range: range)
        }
        attributedText = newText
        if selectedRange.length != attributedText.length {
            textView.selectedRange = selectedRange
            textView.scrollRangeToVisible(selectedRange)
        }
    }
    func updateAlignment(alignment: NSTextAlignment) {
        var selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        }
        let newText = attributedText.mutable
        newText.enumerateAttributes(in: selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            var attributes = attributes
            let newStyle = NSMutableParagraphStyle.defaultStyle
            newStyle.alignment = alignment
            attributes[.paragraphStyle] = newStyle
            newText.setAttributes(attributes, range: range)
        }
        attributedText = newText
        textView.selectedRange = selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func updateFont(weight: UIFont.Weight) {
        var selectedRange = textView.selectedRange
        if selectedRange.length == 0 {
            selectedRange = NSRange(location: 0, length: attributedText.length)
        }
        let newText = attributedText.mutable
        newText.enumerateAttributes(in: selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            var attributes = attributes
            if let font = attributes[.font] as? UIFont {
                let newFont = font.setWeight(weight: weight)
                attributes.updateValue(newFont, forKey: .font)
            }
            newText.setAttributes(attributes, range: range)
        }
        attributedText = newText
        textView.selectedRange = selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func appendTexts(newText: NSAttributedString) {
        let originalText = attributedText.mutable
        originalText.append(NSAttributedString(string: "\n\n"))
        originalText.append(newText)
        attributedText = originalText
        history.append(originalText)
        textView.ensureCaretToTheEnd()
    }
    
    func joinTexts() {
        let selectedRange = textView.selectedRange
        
        guard selectedRange.length > 0 else { return }
        
        let newText = attributedText.mutable
        newText.enumerateAttributes(in: selectedRange, options: .longestEffectiveRangeNotRequired) { (attributes, range, pointer) in
            newText.replaceCharacters(in: range, with: attributedText.attributedSubstring(from: range).string.components(separatedBy: .newlines).joined())
        }
        attributedText = newText
        textView.selectedRange = selectedRange
        textView.scrollRangeToVisible(selectedRange)
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
//                let ratio = 841.8 / 595.2
//                let pageSize = CGSize(width: textView.frame.size.width, height: textView.frame.size.width * CGFloat(ratio))
//                let pageMargins = textView.textContainerInset
        
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

extension TextEditorManger: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateHistory()
        objectWillChange.send()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.selectedRange = NSRange(location: attributedText.length, length: 0)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        objectWillChange.send()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let subString = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if text != " " {
            self.textView.findCompletions(text: subString)
        }
        return true
    }
}
