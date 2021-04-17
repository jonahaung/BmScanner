//
//  LanguageMode.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 11/12/20.
//

import Foundation
import SwiftyTesseract

enum LanguageMode: Int, CaseIterable, Identifiable {
    var id: LanguageMode { return self }
    
    
    case Myanmar, English, Mixed
    
    var description: String {
        switch self {
        case .Myanmar:
            return "Myanmar"
        case .English:
            return "English"
        case .Mixed:
            return "Mixed"
        }
    }
    
    var recognitionLanguage: [RecognitionLanguage] {
        switch self {
        case .Myanmar:
            return [.burmese]
        case .English:
            return [.english]
        case .Mixed:
            return [.burmese, .english]
        }
    }
    static var current: LanguageMode {
        let hashValue = UserDefaults.standard.integer(forKey: "languageMode")
        return LanguageMode(rawValue: hashValue) ?? .Myanmar
    }
    var toggle: LanguageMode {
        switch self {
        case .Myanmar:
            return .English
        case .English:
            return .Mixed
        case .Mixed:
            return .Myanmar
        }
    }
}
