//
//  SearchManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 25/4/21.
//

import CoreData


class SearchManager: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published var pickerIndex = 0
    let context = PersistenceController.shared.container.viewContext
    
    @Published var notes = [Note]()
    
    func search(text: String) {
       
        let request = Note.fetchRequest(for: text)
        notes = (try? context.fetch(request) ) ?? []
    }
}
