//
//  FolderView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 2/3/21.
//

import SwiftUI

struct FolderView: View {
    
    let folder: Folder
    
    @State private var notes: [Note] = []
    
    
    var body: some View {
        List {
            Section(header: Text("\(notes.count) items")) {
                ForEach(notes) { note in
                   NoteCell(note: note)
                }
                .onDelete(perform: onDelete(offsets:))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(folder.name ?? "")
        .navigationBarItems(trailing: EditButton())
        .onAppear{
            let request = Note.fetchRequest(for: folder)
            do {
                notes = try PersistenceController.shared.container.viewContext.fetch(request)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func onDelete(offsets: IndexSet) {
        offsets.forEach { i in
            let object = notes[i]
            notes.remove(at: i)
            object.state = 1
        }
    }
}
