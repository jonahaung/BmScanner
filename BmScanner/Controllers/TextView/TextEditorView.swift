//
//  TextEditorView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 7/3/21.
//

import SwiftUI

struct TextEditorView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewManager = TextEditorViewViewManager()
    private let manager: StateObject<TextEditorManger>
    private let note: Note
    private var onDismiss: ((Bool) -> Void)?
    
    init(note: Note, onDismiss: ((Bool) -> Void)? = nil ) {
        self.note = note
        self.onDismiss = onDismiss
        manager = StateObject(wrappedValue: TextEditorManger(note: note))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SUITextView(manager: manager.wrappedValue)
            TextEditorBottomBar(manager: manager.wrappedValue, viewManager: viewManager)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(DateFormatter.relativeDateFormatter.string(from: note.created ?? Date()))
        .navigationBarItems(leading: navBarLeading, trailing: navBarTrailing)
        .actionSheet(item: $viewManager.sheetType, content: getActionSheet)
        .sheet(item: $viewManager.fullScreenType, content: { type in getFullScreen(type) })
        .overlay(scannerButton.opacity(manager.wrappedValue.isEditing && manager.wrappedValue.isEditable ? 0 : 1))
    }
}


// SubViews
extension TextEditorView {
    
    private var scannerButton: some View {
        return ScannerButton(bottomSpace: 50) { note in
            guard let newText = note?.attributedText else { return }
            manager.wrappedValue.appendTexts(newText: newText)
        }
    }
    
    private var navBarTrailing: some View {
        return HStack {
            Button(action: {
                viewManager.sheetType = .InfoSheet
            }, label: {
                Image(systemName: "info").padding()
            })
            
            Button(action: {
                viewManager.sheetType = .ShareMenu
            }, label: {
                Image(systemName: "square.and.arrow.up").padding(.vertical)
            })
        }
    }
    
    private var navBarLeading: some View {
        return HStack(spacing: 0) {
            Button("Done") {
                if note.attributedText != manager.wrappedValue.attributedText {
                    note.attributedText = manager.wrappedValue.attributedText
                    note.text = note.attributedText?.string
                    note.edited = Date()
                    onDismiss?(true)
                    SoundManager.vibrate(vibration: .soft)
                }
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.vertical)
            
        }
    }
    
}

// Full Screen
extension TextEditorView {
    
    private func getFullScreen(_ type: TextEditorViewViewManager.FullScreenType) -> some View {
        return Group {
            switch type {
            case .ShareAttributedText:
                if let x = manager.wrappedValue.attributedText {
                    ActivityView(activityItems: [x])
                }
            case .ShareAsPDF:
                if let x = manager.wrappedValue.convertToPDF() {
                    ActivityView(activityItems: [x])
                }
            case .PDFViewer:
                PDFViewerView(data: manager.wrappedValue.convertToPDF())
            case .FolderPicker:
                FolderPicker { folder in
                    note.folder = folder
                }
            case .ShareAsImages:
                let images = manager.wrappedValue.convertToImages()
                ActivityView(activityItems: images)
            }
        }
    }
}

// Sheets
extension TextEditorView {
    
    private func getActionSheet(_ type: TextEditorViewViewManager.ActionSheetType) -> ActionSheet {
        switch type {
        case .FontMenu:
            return fontSheet()
        case .ShareMenu:
            return shareSheet()
        case .InfoSheet:
            return infoSheet()
        case .AlignmentSheet:
            return alignmentSheetSheet()
        }
    }
    private func shareSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Share Menu"),
            buttons: [
                .default(Text("View PDF"), action: {
                    viewManager.fullScreenType = .PDFViewer
                }),
                .default(Text("Export as PDF"), action: {
                    viewManager.fullScreenType = .ShareAsPDF
                }),
                .default(Text("Export as Image"), action: {
                    viewManager.fullScreenType = .ShareAsImages
                }),
                .default(Text("Export as Plain Text"), action: {
                    viewManager.fullScreenType = .ShareAttributedText
                }),
                .default(Text("Copy to Clipboard"), action: {
                    
                    UIPasteboard.general.string = manager.wrappedValue.attributedText.string
                }),
                .cancel()
            ]
        )
    }
    private func fontSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Font Design"),
            buttons: [
                .default(Text("Regular Font"), action: {
                    manager.wrappedValue.updateFont(currentFont: .Regular)
                }),
                .default(Text("Bold Font"), action: {
                    manager.wrappedValue.updateFont(currentFont: .Bold)
                }),
                .default(Text("Light Font"), action: {
                    manager.wrappedValue.updateFont(currentFont: .Light)
                }),
                .cancel()
            ]
        )
    }
    
    private func infoSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Info"),
            buttons: [
                .default(Text("Move folder to.."), action: {
                    viewManager.fullScreenType = .FolderPicker
                }),
                
    
                .destructive(Text("Delete this Note"), action: {
                    AlertPresenter.show(title: "Are you sure to delete this note?") { bool in
                        if bool {
                            note.delete()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }),
                .cancel()
            ]
        )
    }
    
    private func alignmentSheetSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Info"),
            buttons: [
                .cancel()
            ]
        )
    }
}
