//
//  SearchView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 18/4/21.
//

import SwiftUI

struct SearchView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var manager = SearchManager()
    var onSearch: (Note) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            searchTextField.padding(3)
            List {
                if !manager.notes.isEmpty {
                    Section(header: Text("Results")) {
                        ForEach(manager.notes) { note in
                            Button {
                                onSearch(note)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                SearchCell(note: note)
                            }
                        }
                    }
                }
                
            }
            .foregroundColor(.primary)
        }
    }
    
    private var searchTextField: some View {
        return HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.tertiaryLabel))
                .padding(.horizontal, 6)
            
            TextField("Search", text: $manager.searchText).onChange(of: manager.searchText) { text in
                manager.search(text: text)
            }
        }
        .padding(9)
        .background(Color(.secondarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
    
}
