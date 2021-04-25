//
//  ViewModifiers.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI


struct RoundedButton: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(BlurredView())
            .clipShape(Circle())
            .shadow(radius: 5)
    }
}
