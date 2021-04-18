//
//  FolderCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 4/3/21.
//

import SwiftUI

struct FolderCell: View {
    
    let folder: Folder
    @State private var notesCount = 0
    @State var observer = CoreDataContextObserver(context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        NavigationLink(destination: FolderView(folder: folder)) {
            HStack{
                let imageName = notesCount == 0 ? "folder" : "folder.fill"
                Label(folder.name ?? "", systemImage: imageName)
                Spacer()
                let text = notesCount == 0 ? String() : notesCount.description
                Text(text)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    private func onAppear() {
        updateNotesCount()
        
        observer.observeObject(object: folder, completionBlock: { (obj, state) in
            Async.main {
                self.updateNotesCount()
            }
        })
    }
    private func onDisappear() {
        observer.unobserveObject(object: folder)
    }
    private func updateNotesCount() {
        notesCount = folder.notes?.count ?? 0
    }
    
    private func observe() {
        
    }
}
