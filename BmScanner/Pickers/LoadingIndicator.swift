//
//  LoadingIndicator.swift
//  BmCamera
//
//  Created by Aung Ko Min on 28/3/21.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var isLoading = false
    let color: Color
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.5)
            .stroke(color, lineWidth: 2)
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear() {
                self.isLoading = true
        }
    }
}
