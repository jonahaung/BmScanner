//
//  TextEditorViewManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 12/4/21.
//

import Foundation

class TextEditorViewViewManager: ObservableObject {
    
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case ShareMenu, FontMenu, InfoSheet, AlignmentSheet
    }
    
    enum FullScreenType: Identifiable {
        var id: FullScreenType { return self }
        case ShareAttributedText, ShareAsPDF, PDFViewer, FolderPicker
    }

    @Published var sheetType: ActionSheetType?
    @Published var fullScreenType: FullScreenType?
    
    
    
}
