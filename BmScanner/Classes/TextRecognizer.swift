//
//  TextRecognizer.swift
//  MyanScan
//
//  Created by Aung Ko Min on 3/3/21.
//

import UIKit
import SwiftyTesseract
import Vision

struct TextRecognizer {
    
    static func recognizeText(for image: UIImage, _ completion: @escaping (NSAttributedString?) -> Void ) {
        
        let languageMode = LanguageMode(rawValue: UserDefaults.standard.integer(forKey: "languageMode")) ?? .Myanmar
        let languages = languageMode.recognitionLanguage
        
        if let firstLanguage = languages.first, languages.count == 1 {
            self.recognizeEnglishText(image: image, completion: completion)
        } else {
            self.recognizeMyanmarText(for: image, languages: languages, completion)
        }
    }
    
    static func recognizeMyanmarText(for image: UIImage, languages: [RecognitionLanguage], _ completion: @escaping (NSAttributedString?) -> Void ) {
        let tesseract = Tesseract(languages: languages, dataSource: Bundle.main, engineMode: .lstmOnly)
        var result: NSAttributedString?
       
        Async.userInitiated {
            tesseract.performOCRPublisher(on: image).sink { complete in
                switch complete {
                case .failure(let error):
                    print(error)
                    Async.main {
                        completion(result)
                    }
                case .finished:
                    print("Finished")
                }
            } receiveValue: { string in
    
                Async.main {
                    let lines = string.lines().filter{!$0.isWhitespace}
                    let text = lines.joined(separator: "\n")
                    if let longest = (lines.sorted{$0.count > $1.count }).first {
                        let fontSize = self.calculateFontSize(for: longest, maxWidth: UIScreen.main.bounds.width - 20, heigt: 30, font: UIFont.myanmarFont)
                        let paragraph = NSMutableParagraphStyle()
                        paragraph.lineHeightMultiple = 1.2
                        paragraph.lineBreakMode = .byWordWrapping
                        result = NSMutableAttributedString(string: text, attributes: [NSMutableAttributedString.Key.font: UIFont.myanmarFont.withSize(fontSize), .paragraphStyle: paragraph])
                    }
                    completion(result)
                }
                
            }.cancel()
        }
    }
    
    
    static func calculateFontSize(for text: String, maxWidth: CGFloat, heigt: CGFloat, font: UIFont) -> CGFloat {
        
        var fontSize = heigt
        var textSize: CGSize {
            return text.boundingRect(with: CGSize(width: .infinity, height: heigt), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font.withSize(fontSize)], context: nil).size
        }
        repeat {
            fontSize -= 0.5
        } while textSize.width > maxWidth
        return fontSize
    }
    
    static func recognizeEnglishText(image: UIImage, completion: @escaping (NSAttributedString?)->Void) {
        var result: NSAttributedString?
        
        guard let buffer = image.pixelBuffer() else {
            completion(result)
            return
        }
        
        let request = VNRecognizeTextRequest { (x, _) in
            Async.main {
                guard let results = x.results as? [VNRecognizedTextObservation], results.count > 0 else {
                    completion(result)
                    return
                }
                
                var lines = [String]()
                results.forEach {
                    if let first = $0.topCandidates(1).first, !first.string.isWhitespace {
                        lines.append(first.string)
                    }
                }
                
                guard !lines.isEmpty else {
                    completion(result)
                    return
                }
                
                let sentence = lines.joined(separator: "\n")
               
                if let longest = (lines.sorted{$0.count > $1.count }).first {
                    let fontSize = self.calculateFontSize(for: longest, maxWidth: UIScreen.main.bounds.width - 10, heigt: 30, font: UIFont.preferredFont(forTextStyle: .body))
                    
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.lineBreakMode = .byWordWrapping
                    paragraph.alignment = .natural
                    paragraph.firstLineHeadIndent = 1.5
                    result = NSMutableAttributedString(string: sentence, attributes: [NSMutableAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body).withSize(fontSize), .paragraphStyle: paragraph])
                    
                }
                completion(result)
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
        Async.userInitiated {
            try? handler.perform([request])
        }
    }
    
}
