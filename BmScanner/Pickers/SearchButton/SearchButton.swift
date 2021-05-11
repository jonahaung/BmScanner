//
//  SearchButton.swift
//  BmScanner
//
//  Created by Aung Ko Min on 6/5/21.
//

import SwiftUI

struct SearchButton: View {
    
    @StateObject private var manager = ShearchButtonManager()
    
    var body: some View {
        EmptyView()
            .overlay(searchButton, alignment: .topTrailing)
            .fullScreenCover(item: $manager.sheetType, content: { type in
                Group{
                    if type == .SearchController {
                        SearchViewControllerRepresentable {
                            manager.note = $0
                            manager.sheetType = .TextEditor
                        }
                    } else {
                        if let note = manager.note {
                            NavigationView{
                                TextEditorView(note: note)
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .font(UserDefaultManager.shared.font())
                .accentColor(UserDefaultManager.shared.appTintColor.color)
            })
    }
    
    private var searchButton: some View {
        return Button {
            manager.sheetType = .SearchController
        } label: {
            Image(systemName: "magnifyingglass")
                .padding(6)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(radius: 5)
                .padding()
        }
    }
}
