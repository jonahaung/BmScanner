//
//  TextEditorManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import UIKit
import SwiftUI

final class TextEditorManger: NSObject, ObservableObject {
    
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case ShareMenu, InfoSheet, EditMenuSheet, AlignmentSheet, FontWeightSheet, ColorPicker
    }

    enum FullScreenType: Identifiable {
        var id: FullScreenType { return self }
        case ShareAttributedText, ShareUrl, PDFViewer, FolderPicker, ShareAsImages, FontPicker
    }
    
    @Published var actionSheetType: ActionSheetType?
    @Published var sheetType: FullScreenType?
    @Published var keyboardLanguage = String()
    var styleColor: CGColor = UIColor.systemRed.cgColor {
        didSet {
            guard oldValue != styleColor else { return }
            textStylingManager.updateTextColor(color: UIColor(cgColor: styleColor))
        }
    }
    
    var tempSavedDocumentUrl: URL?
    
    let note: Note
    
    var textView: AutoCompleteTextView
    let wordPredictor : WordPredictor
    let textStylingManager: TextStylyingManager
    
    init(note: Note) {
        self.note = note
        let textStorage = NSTextStorage(attributedString: note.attributedText ?? "".noteAttributedText)
        let textContainer = NSTextContainer(size: .zero)
        textContainer.widthTracksTextView = true

        textContainer.lineFragmentPadding = 10
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textView = AutoCompleteTextView(frame: .zero, textContainer: textContainer)
        textView.layoutManager.allowsNonContiguousLayout = false
        wordPredictor = WordPredictor(textView: textView)
        textStylingManager = TextStylyingManager(textView: textView)
        textView.textStylyingManager = textStylingManager
        super.init()
        WordPredictManager.shared.trainPrediction(string: note.text ?? "")
        textView.delegate = self
        observeKeyboardLangeChangeNotification()
    }
    
    deinit {
        removeNotificationObserver()
        Log("Deinit")
    }
}

// History
extension TextEditorManger {
    
    func saveChanges() {
        guard note.attributedText != textView.attributedText else { return }
        note.attributedText = textView.attributedText
        note.text = note.attributedText?.string
        note.edited = Date()
        note.folder?.edited = Date()
        note.id = UUID()
    }
}

extension TextEditorManger {
    
    private func observeKeyboardLangeChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardLanguageDidChange(_:)), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
    
    @objc private func keyboardLanguageDidChange(_ notification: NSNotification) {
        keyboardLanguage = textView.textInputMode?.primaryLanguage ?? "unknown"
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }
}

// TextView Delegate

extension TextEditorManger: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        objectWillChange.send()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardLanguage = textView.textInputMode?.primaryLanguage ?? "unknown"
//        textView.scrollToCorrectPosition()
    }
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        
//        return textView.inputView == nil
//    }
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return textView.inputView != nil
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        textView.inputView = UIView()
//        objectWillChange.send()
//    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        objectWillChange.send()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard range.length == 0 else {
            self.wordPredictor.resetSuggesstions()
            return true
        }
        let isMyanmar = self.keyboardLanguage == "my"
        let isReturnKeyPressed = text == "\n"
        var returnValue = true
        let isSpace = text == " "
        
        if isReturnKeyPressed {
            returnValue = !wordPredictor.applyAutocomplete()
        }
    
        if let end = self.textView.position(from: textView.beginningOfDocument, offset: range.location) {
            if isMyanmar {
                let isBanned = text == "ေ"
                
                if !isBanned, let textRange = textView.textRange(from: textView.beginningOfDocument, to: end), let cut = textView.text(in: textRange) {
                    
                    let lastWord = String(cut).lastWord
                    self.wordPredictor.findCompletions(word: lastWord.appending(text), isMyanmar: isMyanmar)
                    if isSpace {
                        self.wordPredictor.predict(word: lastWord)
                    }
                }
            }else {
                if let wordRange = self.textView.tokenizer.rangeEnclosingPosition(end, with: .word, inDirection: .init(rawValue: 1)), let word = textView.text(in: wordRange) {
                    let fullWord = word.appending(text)
                    if isSpace {
                        self.wordPredictor.predict(word: word)
                    }
                    self.wordPredictor.findCompletions(word: fullWord, isMyanmar: isMyanmar)
                }
            }
        }
        
        return returnValue
    }
}
