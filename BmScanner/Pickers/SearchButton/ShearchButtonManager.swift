//
//  ShearchButtonManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 6/5/21.
//

import Foundation

final class ShearchButtonManager: ObservableObject {
    
    var note: Note?
    
    enum SheetType: Identifiable {
        var id: SheetType { return self }
        
        case SearchController, TextEditor
    }
    @Published var sheetType: SheetType?
}
