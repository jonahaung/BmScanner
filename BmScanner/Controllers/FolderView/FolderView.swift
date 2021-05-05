//
//  FolderView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 2/3/21.
//

import SwiftUI

enum FolderType {
    case Folder, General, All
    var description: String {
        switch self {
        case .All:
            return "All Notes"
        case .General:
            return "General Notes"
        default:
            return ""
        }
    }
}

struct FolderView: View {
    
    private let folder: Folder?
    private let folderType: FolderType
    private var fetchRequest: FetchRequest<Note>
    private var notes: FetchedResults<Note> { fetchRequest.wrappedValue }
    
    init(folder: Folder?, type: FolderType = .Folder) {
        self.folder = folder
        self.folderType = type
        switch type {
        case .Folder:
            if let folder = folder {
                fetchRequest = FetchRequest(fetchRequest: Note.fetchRequest(for: folder))
            } else {
                fetchRequest = FetchRequest(fetchRequest: Note.allFetchRequest)
            }
        case .All:
            fetchRequest = FetchRequest(fetchRequest: Note.allFetchRequest)
        case .General:
            fetchRequest = FetchRequest(fetchRequest: Note.generalFetchRequest)
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("\(notes.count) items")) {
                ForEach(notes) { note in
                   NoteCell(note: note)
                }
                .onDelete(perform: onDelete(offsets:))
            }
        }
        .navigationTitle(folder?.name ?? folderType.description)
        .navigationBarItems(trailing: EditButton())
        .overlay(scannerButton)
    }
    
    private var scannerButton: some View {
        return ScannerButton(folder: folder, showSearchBar: true)
    }
    
    private func onDelete(offsets: IndexSet) {
        AlertPresenter.show(title: "Are you sure you want to delete this note??", message: nil) { bool in
            if bool {
                offsets.forEach { i in
                    let object = notes[i]
                    object.delete()
                }
            }
        }
    }
}
