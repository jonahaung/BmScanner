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
                if manager.wrappedValue.textView.selectedRange.length > 0 {
                    Button {
                        manager.wrappedValue.textStylingManager.toggleHighlight(color: .systemYellow)
                    } label: {
                        Image(systemName: "highlighter")
                    }
                }
                
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
        .frame(maxHeight: 35)
        .padding(.leading, 10)
    }
}
