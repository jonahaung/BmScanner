//
//  WordsPredictor.swift
//  BmScanner
//
//  Created by Aung Ko Min on 10/5/21.
//

import UIKit

final class WordPredictor {
    
    typealias Result = (searchedText: String, resultText: String?, resultArray: [String])
    
    private let textView: AutoCompleteTextView
    private let suggesstionLabel: PaddingLabel = {
        return $0
    }(PaddingLabel())
    
    private lazy var wordPredictManager = WordPredictManager.shared
    
    private let oprationQueue: OperationQueue = {
        $0.qualityOfService = .background
        $0.maxConcurrentOperationCount = 1
        return $0
    }(OperationQueue())
    
    var currentResult: Result? {
        didSet {
            suggesstionLabel.text = currentResult?.1
            layoutSuggestedLabel()
            textView.delegate?.textViewDidChange?(textView)
        }
    }
    
    var suggesstions: [String] { return currentResult?.2 ?? []}
    
    
    init(textView: AutoCompleteTextView) {
        self.textView = textView
        textView.addSubview(suggesstionLabel)
    }
    
    private func layoutSuggestedLabel() {
        guard let selectedTextRange = textView.selectedTextRange else { return }
        let caretRect = textView.caretRect(for: selectedTextRange.end)
        let labelSize = suggesstionLabel.bounds.size
        
        var labelX = caretRect.midX - (labelSize.width/2)
        while textView.bounds.maxX - 10 < labelX + labelSize.width {
            labelX -= 1
        }
        while labelX < 10 {
            labelX += 1
        }
        let labelPosition = CGPoint(x: labelX, y: caretRect.minY - (suggesstionLabel.frame.size.height + 10))
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .allowAnimatedContent) {
            self.suggesstionLabel.frame.origin = labelPosition
        }
    }
    
    func applySuggesstion(word: String) {
        guard let searchedWord = currentResult?.0.urlEncoded else { return }
        let encoded = word.urlEncoded
        let x = encoded.dropFirst(searchedWord.utf16.count)
        let string = String(x).urlDecoded
        textView.insertText(string)
        resetSuggesstions()
    }
    
    func applyAutocomplete() -> Bool {
        if let word = currentResult?.1 {
            applySuggesstion(word: word)
            return true
        }
        return false
    }
    
    func findCompletions(word: String, isMyanmar: Bool) {
        
        oprationQueue.cancelAllOperations()
        oprationQueue.addOperation {[weak self] in
            guard let `self` = self else { return }
            
            var array = isMyanmar ? self.wordPredictManager.completion(myanmar: word) : self.wordPredictManager.completion(english: word)
            if !array.isEmpty {
                if array.first == word {
                    array.removeFirst()
                }
            }
            OperationQueue.main.addOperation {
                self.currentResult = Result(word, array.first, array.map{ $0})
            }
        }
    }
    
    func predict(word: String) {
        self.textView.nexSuggesstion = self.wordPredictManager.pridict(text: word)
    }
    
    func resetSuggesstions() {
        currentResult = nil
    }
}
