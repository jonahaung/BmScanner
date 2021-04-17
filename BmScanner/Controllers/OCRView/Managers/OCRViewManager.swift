//
//  ProcessorTwoViewManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 12/4/21.
//

import Foundation

final class OCRViewManager: ObservableObject {
    
    enum ScreenType: Identifiable {
        var id: ScreenType { return self }
        case ShareImage, ImageEditorView
    }
    
    @Published var screenType: ScreenType?
}
