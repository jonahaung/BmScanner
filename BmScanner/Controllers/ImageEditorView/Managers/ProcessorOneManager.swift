//
//  ProcessorOneManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 11/4/21.
//

import Foundation

class ProcessorOneManager: ObservableObject {
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        
        case FilterMenu
    }
    @Published var actionSheetType: ActionSheetType?
    
}
