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
            .trim(from: 0, to: 0.75)
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .butt, lineJoin: .round))
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
            .animation(Animation.linear(duration: 0.75).repeatForever(autoreverses: false))
            .onAppear() {
                self.isLoading = true
        }
            
            .padding()
            .background(BlurredView())
            .clipShape(Circle())
            .shadow(radius: 5)
    }
}
