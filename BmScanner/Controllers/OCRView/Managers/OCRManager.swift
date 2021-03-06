//
//  ProcessorTwoManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 12/4/21.
//

import UIKit
import SwiftyTesseract
import Vision

final class OCRManager: ObservableObject {
    
    @Published var showLoading = false
    var onGetTexts: ((String?) -> Void)?
    
    deinit {
        Log("Deinit")
    }
}

extension OCRManager {
    
    func recognizeText(image: UIImage?) {
        guard let image = image, !showLoading else { return }
        
        let languageMode = UserDefaultManager.shared.lanaguageMode
        if languageMode == .English {
            recognizeEnglishText(image)
        } else {
            recognizeMyanmarTexts(image, languageMode)
        }
    }
    
    private func recognizeEnglishText(_ image: UIImage) {
        
        guard !showLoading else { return }
        showLoading = true
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        Async.userInitiated{ [weak self] in
            guard let buffer = image.pixelBuffer()
            else {
                Async.main { self?.showLoading = false }
                return
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
            
            do {
                try handler.perform([request])
            } catch {
                Async.main { self?.showLoading = false }
                print(error)
            }
        }.main { [weak self] in
            guard
                let sself = self,
                let results = request.results as? [VNRecognizedTextObservation],
                !results.isEmpty
            else {
                self?.showLoading = false
                return
            }
            var resultTexts = [String]()
            results.forEach {
                if let first = $0.topCandidates(1).first, !first.string.isWhitespace {
                    resultTexts.append(first.string)
                }
            }
            
            guard !resultTexts.isEmpty else {
                sself.showLoading = false
                return
            }
            let text = resultTexts.joined(separator: "\n")
            sself.onGetTexts?(text)
        }
        
    }
    
    private func recognizeMyanmarTexts(_ image: UIImage, _ languageMode: LanguageMode) {
        guard !showLoading else { return }
        
        showLoading = true
        let tesseract = Tesseract(languages: languageMode.recognitionLanguage, dataSource: Bundle.main, engineMode: .lstmOnly)
        Async.userInitiated { [weak self] in
            tesseract.performOCRPublisher(on: image)
                .sink { [weak self] complete in
                guard let self = self else { return }
                
                switch complete {
                case .failure(let error):
                    print(error)
                    Async.main {
                        self.showLoading = false
                    }
                case .finished:
                    Async.main {
                        self.showLoading = false
                    }
                }
            } receiveValue: { [weak self] string in
                Async.main { [weak self] in
                    guard let self = self else { return }
                    let lines = string.components(separatedBy: "\n").filter{!$0.isWhitespace}
                    let text = lines.joined(separator: "\n")
                    self.onGetTexts?(text)
                }
            }.cancel()
        }
    }
}
