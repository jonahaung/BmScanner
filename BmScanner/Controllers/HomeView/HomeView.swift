//
//  ContentView.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        List {
            Section(header: Text("System")) {
                Home_SystemItemsView()
            }
            Section(header: Text("Folders")) {
                Button {
                    Folder.createNewFolder()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Create New Folder")
                    }
                }
                Home_RecentFoldersView()
            }
            
            Section(header: Text("Recent Items")) {
                Home_RecentNotesView()
            }
        }
        .navigationTitle("Home")
        .navigationBarItems(leading: NavigationItemLeading, trailing: NavigationItemTrailing)
        .overlay(SearchButton())
        .overlay(ScannerButton(), alignment: .bottomTrailing)
    }
}

// SubViews
extension HomeView {
    
    private var NavigationItemTrailing: some View {
        return NavigationLink(destination: SettingsView()) {
            Image(systemName: "scribble").padding()
        }
    }
    
    private var NavigationItemLeading: some View {
        return EditButton()
    }
}
