//
//  ViewModifiers.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

struct PrimaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.accentColor)
            .foregroundColor(Color(.systemBackground))
    }
}

struct RoundedButton: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .clipShape(Circle())
            .shadow(radius: 5)
    }
}

struct SquareButton: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 7)
            .background(Color.accentColor)
            .foregroundColor(Color(.systemBackground))
            .cornerRadius(4)
    }
}
