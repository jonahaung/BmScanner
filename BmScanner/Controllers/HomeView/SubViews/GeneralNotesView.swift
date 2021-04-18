//
//  GeneralNotesView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 18/4/21.
//

import SwiftUI

struct GeneralNotesView: View {
    
    @FetchRequest(fetchRequest: Note.generalFetchRequest)
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
        .navigationTitle("General Notes")
        .navigationBarItems(trailing: EditButton())
    }
    
    private func removeRows(at offsets: IndexSet) {
        AlertPresenter.show(title: "Are you sure you want to delete this folder?", message: nil) { bool in
            if bool {
                offsets.forEach { i in
                    let object = notes[i]
                    object.delete()
                }
            }
        }
    }
}
