//
//  SuggesstionsView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 9/5/21.
//

import SwiftUI

struct SuggesstionsView: View {
    
    var manager: StateObject<TextEditorManger>
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .center, spacing: 3) {
    
                Section {
                    ForEach(manager.wrappedValue.wordPredictor.suggesstions, id: \.self) { item in
                        Button {
                            manager.wrappedValue.wordPredictor.applySuggesstion(word: item)
                        } label: {
                            Text(item)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.quaternaryLabel))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                    }
                }
            }
            .font(Font.custom("MyanmarSansPro", fixedSize: 14))
        }
        .frame(maxHeight: manager.wrappedValue.wordPredictor.suggesstions.isEmpty ? 0 : 35)
        .padding(.leading, 10)
    }
}
