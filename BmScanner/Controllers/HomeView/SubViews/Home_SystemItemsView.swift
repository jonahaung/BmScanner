//
//  Home+SystemItemsView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import SwiftUI
import CoreData

struct Home_SystemItemsView: View {
    
    @StateObject private var manager = Home_SystemItemsManager()
    
    var body: some View {
        Group {
            NavigationLink(destination: AllNotesView()) {
                cell(text: "All Notes", count: manager.allNotesCount)
            }
            NavigationLink(destination: GeneralNotesView()) {
                cell(text: "General Notes", count: manager.generalNotesCount)
            }
            NavigationLink(destination: FoldersView()) {
                cell(text: "All Folders", count: manager.allFoldersCount)
            }
        }
    }
    
    private func cell(text: String, count: Int) -> some View {
        return HStack {
            Text(text)
                .fontWeight(.medium)
            Spacer()
            if count > 0 {
                Text(count.description)
                    .fontWeight(.light)
                    .foregroundColor(Color(.tertiaryLabel))
            }
            
        }
    }
}

private class Home_SystemItemsManager: ObservableObject {
    
    @Published var allNotesCount = 0
    @Published var allFoldersCount = 0
    @Published var generalNotesCount = 0
    @Published var deletedNotesCount = 0
    
    private let context = PersistenceController.shared.container.viewContext
    private var observer: CoreDataContextObserver?
    init() {
        observeNotification()
        fetch()
    }
    
    deinit {
        unobserveNotifications()
        Log("Deinit")
    }
    
    func fetch() {
        fetchAllNotesCount()
        fetchAllFoldersCount()
        fetchGeneralNotesCount()
    }
    
    private func fetchAllNotesCount() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            allNotesCount = try context.count(for: request)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func fetchAllFoldersCount() {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        do {
            allFoldersCount = try context.count(for: request)
        } catch {
            print(error.localizedDescription)
        }
    }
    private func fetchGeneralNotesCount() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "folder == NULL")
        do {
            generalNotesCount = try context.count(for: request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func observeNotification() {
        observer = CoreDataContextObserver(context: context)
        
        observer?.contextChangeBlock = { [weak self] (context, changes) in
            DispatchQueue.main.async {
                if changes.count > 0 {
                    self?.fetch()
                }
            }
        }
    }

    private func unobserveNotifications() {
        observer?.unobserveAllObjects()
    }
}
