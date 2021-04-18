//
//  Note+Ext.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import CoreData
import UIKit

extension Note {
    var title: String { return attributedText?.string.lines().first ?? ""}
    
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
    
    static func create(text: String, _ folder: Folder? = nil) -> Note {
        let para = NSMutableParagraphStyle()
        para.lineBreakMode = .byWordWrapping
        let font = text.language == "my" ? UIFont.myanmarNoto : UIFont.preferredFont(forTextStyle: .body)
        let attributedText = NSAttributedString(string: text, attributes: [.font: font, .paragraphStyle: para])
        
        let viewContext = PersistenceController.shared.container.viewContext
        let note = Note(context: viewContext)
        note.id = UUID()
        note.attributedText = attributedText
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
