//
//  ScannerButton_Manager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 6/5/21.
//

import UIKit

final class ScannerButton_Manager: ObservableObject {
    var pickedImage: UIImage?
    var note: Note?
    
    @Published var fullScreenType: FullScreenType?
    @Published var actionSheetType: ActionSheetType?
    
    enum FullScreenType: Identifiable {
        var id: FullScreenType { return self }
        case PhotoLibrary, FileDocument, DocumentScanner, Camera, OCR, TextEditor
    }
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case ScannerMenu
    }
}
