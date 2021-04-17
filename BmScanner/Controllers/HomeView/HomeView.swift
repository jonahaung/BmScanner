//
//  ContentView.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

struct HomeView: View {
    
    @State private var fullScreenType: FullScreenType?
    @State private var actionSheetType: ActionSheetType?
    @StateObject private var manager = Home_Manager()
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("System")) {
                    Home_SystemItemsView()
                }
                Section(header: Text("Folders")) {
                    Button {
                        Folder.createNewFolder()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create New Folder")
                        }
                    }
                    Home_RecentFoldersView()
                }
                
                Section(header: Text("Recent Items")) {
                    Home_RecentNotesView()
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        actionSheetType = .ScannerMenu
                    } label: {
                        Image(systemName: "plus").modifier(RoundedButton())
                    }
                    .actionSheet(item: $actionSheetType, content: getActionSheet(_:))
                }
            }.padding()
        }
        
        .navigationTitle("Home")
        .navigationBarItems(leading: NavigationItemLeading, trailing: NavigationItemTrailing)
        .fullScreenCover(item: $fullScreenType, content: getFullScreen(_:))
    }
    
    
}

// SubViews
extension HomeView {
    
    private var NavigationItemTrailing: some View {
        return NavigationLink(destination: SettingsView()) {
            Image(systemName: "scribble").padding()
        }
    }
    
    private var NavigationItemLeading: some View {
        return HStack {
            EditButton()
        }
    }
}

// Full Screen
extension HomeView {
    
    enum FullScreenType: Identifiable {
        var id: FullScreenType { return self }
        case PhotoLibrary, FileDocument, DocumentScanner, OCR, TextEditor
    }
    
    private func getFullScreen(_ type: FullScreenType) -> some View {
        return Group {
            switch type {
            case .PhotoLibrary:
                ImagePicker(onPickImage: onPickedImage(_:))
            case .FileDocument:
                DocPickerView(onPickImage: onPickedImage(_:))
            case .DocumentScanner:
                DocumentScannerView(onPickImage: onPickedImage(_:))
                    .edgesIgnoringSafeArea(.all)
            case .OCR:
                OCRView(image: manager.pickedImage) { x in
                    if let x = x {
                        DispatchQueue.main.async {
                            manager.note = Note.create(text: x)
                        }
                    }
                }
                .onDisappear(perform: onDisappearOCR)
            case .TextEditor:
                if let note = manager.note {
                    NavigationView{
                        TextEditorView(note: note)
                    }
                }
            }
        }
        .font(UserDefaultManager.shared.font())
        .accentColor(UserDefaultManager.shared.appTintColor.color) 
    }
    
    private func onDisappearOCR() {
        guard manager.note != nil else { return }
    
        fullScreenType = .TextEditor
    }
    private func onPickedImage(_ image: UIImage) {
        manager.pickedImage = image
        fullScreenType = .OCR
    }
}
// ActionSheet
extension HomeView {
    
    enum ActionSheetType: Identifiable {
        var id: ActionSheetType { return self }
        case ScannerMenu
    }
    
    private func getActionSheet(_ type: ActionSheetType) -> ActionSheet {
        switch type {
        case .ScannerMenu:
            return ActionSheet(title: Text("Scanner Menu"), message: Text("Please chose"), buttons: [
                .default(Text("Document Scanner"), action: {
                    fullScreenType = .DocumentScanner
                }),
                .default(Text("Photo Library"), action: {
                    fullScreenType = .PhotoLibrary
                }),
                .default(Text("File Documents"), action: {
                    fullScreenType = .FileDocument
                }),
                .cancel()
            ])
        }
    }
}
