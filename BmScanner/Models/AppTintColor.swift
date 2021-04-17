//
//  AppTintColor.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

enum AppTintColor: Int, CaseIterable, Identifiable {
    var id: AppTintColor { return self }
    
    
    case Blue, Red, Orange, Pink, Indigo, Teal, Green, Yellow, Brown
    
    var color: Color {
        return Color(uiColor)
    }
    var uiColor: UIColor {
        switch self {
        case .Blue:
            return .systemBlue
        case .Red:
            return .systemRed
        case .Orange:
            return .systemOrange
        case .Pink:
            return .systemPink
        case .Indigo:
            return .systemIndigo
        case .Teal:
            return .systemTeal
        case .Green:
            return .systemGreen
        case .Yellow:
            return .systemYellow
        case .Brown:
            return .brown
        }
    }
    var name: String {
        switch self {
        case .Blue:
            return "Default"
        case .Red:
            return "Red"
        case .Orange:
            return "Orange"
        case .Pink:
            return "Pink"
        case .Indigo:
            return "Indigo"
        case .Teal:
            return "Teal"
        case .Green:
            return "Green"
        case .Yellow:
            return "Yellow"
        case .Brown:
            return "Brown"
        }
    }
    
}
