//
//  Folder+Ext.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import UIKit
import CoreData

extension Folder {
    
    static func getCurrentFolder() -> Folder {
        if let folder = Folder.fetchFolder(id: UserDefaultManager.shared.currentFolderId) {
            return folder
        }else if let folder = Folder.fetchFolder(name: "General") {
            return folder
        }
        
        Folder.create(name: "General")
        return getCurrentFolder()
    }
    
    static func fetchFolder(name: String) -> Folder? {
        return Folder.fetchFolder(name: name).first
    }
    static func fetchFolder(id: String) -> Folder? {
        let viewContext = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request).first
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func fetchFolder(name: String) -> [Folder] {
        let viewContext = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        do {
            return try viewContext.fetch(request)
        }catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    static var allFetchRequest: NSFetchRequest<Folder> {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        return request
      }
    static var homeViewFetchRequest: NSFetchRequest<Folder> {
        let request: NSFetchRequest<Folder> = Folder.fetchRequest()
        request.fetchLimit = 5
        request.sortDescriptors = [NSSortDescriptor(key: "edited", ascending: false)]
        return request
      }
    static func create(name: String) {
        let viewContext = PersistenceController.shared.container.viewContext
        let id = UUID().uuidString
        let folder = Folder(context: viewContext)
        folder.id = id
        folder.name = name
        folder.created = Date()
        folder.edited = Date()
        do {
            try viewContext.save()
            UserDefaultManager.shared.currentFolderId = id
        } catch {
           
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    static func createNewFolder() {
        let alert = UIAlertController(title: "New Folder", message: "Please enter folder name", preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.autocapitalizationType = .words
            textField.placeholder = "Folder Name"
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                Folder.create(name: text)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        UIApplication.getTopViewController()?.present(alert, animated: true)
    }
}
