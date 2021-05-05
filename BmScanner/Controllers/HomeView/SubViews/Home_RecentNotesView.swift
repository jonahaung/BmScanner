//
//  RecentsNotesView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 2/3/21.
//

import SwiftUI

struct Home_RecentNotesView: View {
    
    @FetchRequest(fetchRequest: Note.homeViewFetchRequest)
    private var notes: FetchedResults<Note>
    
    var body: some View {
        ForEach(notes) { note in
            NoteCell(note: note)
        }
        .onDelete(perform: removeRows(at:))
    }
    
    private func removeRows(at offsets: IndexSet) {
        offsets.forEach { i in
            AlertPresenter.show(title: "Are you sure you want to delete this folder?", message: nil) { bool in
                if bool {
                    let object = notes[i]
                    object.delete()
                }
            }
        }
    }
}
