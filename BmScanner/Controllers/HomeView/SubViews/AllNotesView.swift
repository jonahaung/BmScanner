//
//  AllNotesView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import SwiftUI

struct AllNotesView: View {
    
    @FetchRequest(fetchRequest: Note.allFetchRequest)
    private var notes: FetchedResults<Note>
    
    var body: some View {
        List {
            Section(header: Text(notes.count.description + " items")) {
                ForEach(notes) { note in
                    NoteCell(note: note)
                }
                .onDelete(perform: removeRows(at:))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("All Notes")
        .navigationBarItems(trailing: EditButton())
    }
    
    private func removeRows(at offsets: IndexSet) {
        AlertPresenter.show(title: "Are you sure you want to delete this folder?", message: nil) { bool in
            if bool {
                offsets.forEach { i in
                    let object = notes[i]
                    object.state = 1
                }
            }
        }
    }
}
