//
//  ScannerButton.swift
//  BmScanner
//
//  Created by Aung Ko Min on 18/4/21.
//

import SwiftUI

struct ScannerButton: View {
    
    var folder: Folder?
    var onDetectTexts: ((NSAttributedString?) -> Void)? = nil
    
    @StateObject private var manager = ScannerButton_Manager()
    
    @State private var location = CGPoint(x: 50, y: UIScreen.main.bounds.height / 2)
    @GestureState private var fingerLocation: CGPoint? = nil
    @GestureState private var startLocation: CGPoint? = nil // 1
    

    var body: some View {
        scannerButton
//            .position(location)
//            .gesture( simpleDrag.simultaneously(with: fingerDrag) )
            .onTapGesture{ onTapButton()}
            .actionSheet(item: $manager.actionSheetType, content: getActionSheet(_:))
            .fullScreenCover(item: $manager.fullScreenType, content: getFullScreen(_:))
    }
    
    private func onPickedImage(_ image: UIImage) {
        manager.pickedImage = image
        manager.fullScreenType = .OCR
    }
    private func onGetAttributedTextText(_ attributedText: NSAttributedString?) {
        guard let attributedText = attributedText else { return }
        if let onDetectTexts = self.onDetectTexts {
            onDetectTexts(attributedText)
        } else {
            manager.note = Note.create(text: attributedText, folder)
            manager.fullScreenType = .TextEditor
        }
    }
    
    private func onGetText(_ text: String?) {
        guard let attributedText = text?.noteAttributedText else { return }
        
        if let onDetectTexts = self.onDetectTexts {
            onDetectTexts(attributedText)
            manager.fullScreenType = nil
        } else {
            manager.note = Note.create(text: attributedText, folder)
            manager.fullScreenType = .TextEditor
        }
    }
    
    private func onTapButton() {
        manager.actionSheetType = .ScannerMenu
        SoundManager.vibrate(vibration: .rigid)
    }
    private var scannerButton: some View {
        return Image(systemName: "plus")
            .foregroundColor(.accentColor)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(Circle())
            .shadow(radius: 5)
            .scaleEffect(fingerLocation == nil ? 1 : 2)
            .padding()
    }
    
    private var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
                SoundManager.vibrate(vibration: .soft)
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }
    }
    
    private var fingerDrag: some Gesture {
        DragGesture()
            .updating($fingerLocation) { (value, fingerLocation, transaction) in
                fingerLocation = value.location
            }
    }
    
    private func getFullScreen(_ type: ScannerButton_Manager.FullScreenType) -> some View {
        return Group {
            switch type {
            case .PhotoLibrary:
                ImagePicker(sourceType: .photoLibrary, onPickImage: onPickedImage(_:))
            case .FileDocument:
                DocPickerView(onPickImage: onPickedImage(_:), onGetText: onGetAttributedTextText(_:))
            case .DocumentScanner:
                DocumentScannerView(onPickImage: onPickedImage(_:))
            case .Camera:
                ImagePicker(sourceType: .camera, onPickImage: onPickedImage(_:))
            case .OCR:
                OCRView(image: manager.pickedImage, onGetTexts: onGetText(_:))
            case .TextEditor:
                if let note = manager.note {
                    NavigationView{ TextEditorView(note: note) }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .font(UserDefaultManager.shared.font())
        .accentColor(UserDefaultManager.shared.appTintColor.color)
    }
    
    private func getActionSheet(_ type: ScannerButton_Manager.ActionSheetType) -> ActionSheet {
        var buttons = [Alert.Button]()
        buttons.append(.default(Text("Document Scanner"), action: {
            manager.fullScreenType = .DocumentScanner
        }))
        buttons.append(.default(Text("Photo Library"), action: {
            manager.fullScreenType = .PhotoLibrary
        }))
        buttons.append(.default(Text("File Documents"), action: {
            manager.fullScreenType = .FileDocument
        }))
        buttons.append(.default(Text("Take Photo"), action: {
            manager.fullScreenType = .Camera
        }))
        if onDetectTexts == nil {
            buttons.append(.default(Text("Create Empty Note"), action: {
                if onDetectTexts != nil {
                    onDetectTexts?(NSAttributedString())
                } else {
                    manager.note = Note.create(text: String().noteAttributedText, folder)
                    manager.fullScreenType = .TextEditor
                }
            }))
        }
        buttons.append(.cancel())
        switch type {
        case .ScannerMenu:
            return ActionSheet(title: Text("Scanner Menu"), message: Text("Please select the scanner source"), buttons: buttons)
        }
    }
    
}
