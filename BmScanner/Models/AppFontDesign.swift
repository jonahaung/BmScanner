//
//  FontDesign.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

enum AppFontDesign: Int, CaseIterable, Identifiable {
    
    var id: AppFontDesign { return self }
    
    case system, rounded, monoSpaced, serif
    
    var design: Font.Design {
        switch self {
        case .rounded:
            return .rounded
        case .monoSpaced:
            return .monospaced
        case .serif:
            return .serif
        case .system:
            return .default
        }
    }
    
    var name: String {
        switch self {
        case .monoSpaced:
            return "Monospaced"
        case .serif:
            return "Serif"
        case .rounded:
            return "Rounded"
        case .system:
            return "Default"
        }
    }
}

