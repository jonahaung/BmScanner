//
//  WordTagger.swift
//  Myanmar Text Grabber
//
//  Created by Aung Ko Min on 10/11/20.
//

import Foundation
import NaturalLanguage

typealias TagLabel = (tag: String, label: String)

final class WordSegmentationManager {
    
    static let shared = WordSegmentationManager()
    
    let customTagScheme = NLTagScheme("AKM")
    
    private lazy var tagger: NLTagger = {
        let mlModel = (try! MyanEmbedding (configuration: .init()))
        
        let customModel = try! NLModel(mlModel: mlModel.model)
        let tagger = NLTagger(tagSchemes: [.tokenType, customTagScheme])
        tagger.setModels([customModel], forTagScheme: customTagScheme)
        
        return tagger
    }()
    
    func tag(_ text: String) -> [TagLabel] {
        tagger.string = text
        tagger.setLanguage(.burmese, range: text.startIndex..<text.endIndex)
        var tagLabels = [TagLabel]()
         tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: customTagScheme, options: [.omitOther, .omitPunctuation, .omitWhitespace, .joinContractions, .joinNames]) { tag, range  in
            if let tag = tag {
                let string = String(text[range])
                let tagLabel = TagLabel(string, tag.rawValue)
                tagLabels.append(tagLabel)
            }
            return true
        }
        
        return tagLabels
        
    }
}
