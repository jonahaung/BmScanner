//
//  FoldersView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import SwiftUI

struct FoldersView: View {
    
    @FetchRequest(fetchRequest: Folder.homeViewFetchRequest)
    private var folders: FetchedResults<Folder>
    
    var body: some View {
        List {
            Section(header: Text(folders.count.description + " items")) {
                ForEach(folders) {
                    FolderCell(folder: $0)
                }
                .onDelete(perform: removeRows(at:))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("All Folders")
        .navigationBarItems(trailing: EditButton())
    }
    private func removeRows(at offsets: IndexSet) {
        AlertPresenter.show(title: "Are you sure you want to delete this folder?", message: nil) { bool in
            if bool {
                offsets.forEach { i in
                    let object = folders[i]
                    PersistenceController.shared.container.viewContext.delete(object)
                    
                }
            }
        }
    }
}
