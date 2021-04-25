//
//  Note+Ext.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import CoreData
import UIKit

extension Note {
    
    static var allFetchRequest: NSFetchRequest<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "edited", ascending: false)]
        return request
    }
    static var generalFetchRequest: NSFetchRequest<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "folder == NULL")
        request.sortDescriptors = [NSSortDescriptor(key: "edited", ascending: false)]
        return request
    }
    static var homeViewFetchRequest: NSFetchRequest<Note> {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.fetchLimit = 8
        request.sortDescriptors = [NSSortDescriptor(key: "edited", ascending: false)]
        return request
    }
    
    static func fetchRequest(for folder: Folder) -> NSFetchRequest<Note>{
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "edited", ascending: false)]
        request.predicate = NSPredicate(format: "folder == %@", folder)
        return request
    }
    static func fetchRequest(for text: String) -> NSFetchRequest<Note>{
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "text CONTAINS[cd] %@", text)
        return request
    }
    static func create(text: String, _ folder: Folder? = nil) -> Note {
       
        let attributedText = text.noteAttributedText
        
        let viewContext = PersistenceController.shared.container.viewContext
        let note = Note(context: viewContext)
        note.id = UUID()
        note.attributedText = attributedText
        note.text = attributedText.string
        note.created = Date()
        note.edited = Date()
        folder?.edited = Date()
        note.folder = folder ?? Folder.getCurrentFolder()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return note
    }
    static func create(text: NSAttributedString, _ folder: Folder? = nil) -> Note {
    
        let viewContext = PersistenceController.shared.container.viewContext
        let note = Note(context: viewContext)
        note.id = UUID()
        note.attributedText = text
        note.text = text.string
        note.created = Date()
        note.edited = Date()
        folder?.edited = Date()
        note.folder = folder ?? Folder.getCurrentFolder()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return note
    }
    static func delete(note: Note) {
        PersistenceController.shared.container.viewContext.delete(note)
        
    }
}

extension NSManagedObject {
    func delete() {
        PersistenceController.shared.container.viewContext.delete(self)
        PersistenceController.shared.save()
    }
}
