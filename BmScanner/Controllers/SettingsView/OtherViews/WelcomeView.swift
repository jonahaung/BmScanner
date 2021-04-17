//
//  Location.swift
//  Food
//
//  Created by BqNqNNN on 7/12/20.
//

import SwiftUI

struct WelcomeView: View {

    var body: some View {
        VStack {
            Spacer()
            Image("welcome")
                .resizable()
                .scaledToFit()
            Text("Hi, nice to meet you !")
                .font(.title)
                .bold()
            Text("We need the following permissions \nfrom you.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)))
                .padding(.all, 20)
            
            Spacer()
            Button {
                requestAccess()
            } label: {
                HStack {
                    Text("Allow Usages")
                        .bold()
                }
                .foregroundColor(.accentColor)
                .frame(width: 300, height: 60)
                .border(Color.accentColor, width: 3)
                .cornerRadius(5)
            }
            
            Button {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            } label: {
                Text("Select Manually")
                    .bold()
                    .underline()
                    .foregroundColor(.gray)
                    .padding()
            }
            Spacer()
        }
    }
    
    private func requestAccess() {
        UserDefaultManager.shared.hasShownOnboarding = true
    }
}
