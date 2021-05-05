//
//  RecentsFoldersView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 2/3/21.
//

import SwiftUI

struct Home_RecentFoldersView: View {
    
    @FetchRequest(fetchRequest: Folder.homeViewFetchRequest)
    private var folders: FetchedResults<Folder>
    
    var body: some View {
        ForEach(folders) {
            FolderCell(folder: $0)
        }
        .onDelete(perform: removeRows(at:))
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
