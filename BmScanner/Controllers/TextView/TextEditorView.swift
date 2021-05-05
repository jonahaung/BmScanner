//
//  TextEditorView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 7/3/21.
//

import SwiftUI

struct TextEditorView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    private let manager: StateObject<TextEditorManger>
    private let note: Note
    
    
    init(note: Note, onDismiss: ((Bool) -> Void)? = nil ) {
        self.note = note
        manager = StateObject(wrappedValue: TextEditorManger(note: note))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SUITextView(textView: manager.wrappedValue.textView)
            
            Divider().padding(.horizontal)
            TextEditorBottomBar(manager: manager.wrappedValue)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(DateFormatter.relativeDateFormatter.string(from: note.created ?? Date()))
        .navigationBarItems(leading: navBarLeading, trailing: navBarTrailing)
        .actionSheet(item: manager.projectedValue.sheetType, content: getActionSheet)
        .sheet(item: manager.projectedValue.fullScreenType, content: { type in getFullScreen(type) })
        .overlay(scannerButton)
    }
}


// SubViews
extension TextEditorView {
    
    private var scannerButton: some View {
        return ScannerButton(alignment: .trailing) { txt in
            guard let newText = txt else { return }
            manager.wrappedValue.appendTexts(newText: newText)
        }
    }
    
    private var navBarTrailing: some View {
        return HStack {
            
            Button(action: {
                manager.wrappedValue.sheetType = .InfoSheet
            }, label: {
                Image(systemName: "info").padding()
            })
            
            Button(action: {
                manager.wrappedValue.sheetType = .ShareMenu
            }, label: {
                Image(systemName: "square.and.arrow.up").padding(.vertical)
            })
        }
    }
    
    private var navBarLeading: some View {
        return Group {
            Button("Done") {
                manager.wrappedValue.save()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Full Screen
extension TextEditorView {
    
    private func getFullScreen(_ type: TextEditorManger.FullScreenType) -> some View {
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
    
    private func getActionSheet(_ type: TextEditorManger.ActionSheetType) -> ActionSheet {
        switch type {
        case .ShareMenu:
            return shareSheet()
        case .InfoSheet:
            return infoSheet()
        case .EditMenuSheet:
            return editMenuSheet()
        case .AlignmentSheet:
            return alignmentSheet()
        case .FontWeightSheet:
            return fontSheet()
        }
    }
    
    private func shareSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Share Menu"),
            buttons: [
                .default(Text("View PDF"), action: {
                    manager.wrappedValue.fullScreenType = .PDFViewer
                }),
                .default(Text("Export as PDF"), action: {
                    manager.wrappedValue.fullScreenType = .ShareAsPDF
                }),
                .default(Text("Export as Image"), action: {
                    manager.wrappedValue.fullScreenType = .ShareAsImages
                }),
                .default(Text("Export as Plain Text"), action: {
                    manager.wrappedValue.fullScreenType = .ShareAttributedText
                }),
                .default(Text("Copy to Clipboard"), action: {
                    
                    UIPasteboard.general.string = manager.wrappedValue.attributedText.string
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
                    manager.wrappedValue.fullScreenType = .FolderPicker
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
    
    private func editMenuSheet() -> ActionSheet {
        var buttons = [Alert.Button]()
        if let textRange = manager.wrappedValue.textView.selectedTextRange, let text = manager.wrappedValue.textView.text(in: textRange), text.components(separatedBy: .newlines).count > 1 {
            let joinTextsButton = Alert.Button.default(Text("Join text-lines")) {
                manager.wrappedValue.joinTexts()
            }
            
            buttons.append(joinTextsButton)
        }
        
        buttons.append(.default(Text("Text Alignment"), action: {
            manager.wrappedValue.sheetType = .AlignmentSheet
        }))
        buttons.append(.default(Text("Font Style"), action: {
            manager.wrappedValue.sheetType = .FontWeightSheet
        }))
        buttons.append(.default(Text("Highlight"), action: {
            manager.wrappedValue.highlight()
        }))
        buttons.append(.cancel())
        return ActionSheet( title: Text("Edit Text"), buttons: buttons)
    }
    
    private func alignmentSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Text Alignment"),
            buttons: [
                .default(Text("Left"), action: {
                    manager.wrappedValue.updateAlignment(alignment: .left)
                }),
                .default(Text("Right"), action: {
                    manager.wrappedValue.updateAlignment(alignment: .right)
                }),
                .default(Text("Center"), action: {
                    manager.wrappedValue.updateAlignment(alignment: .center)
                }),
                .default(Text("Justify"), action: {
                    manager.wrappedValue.updateAlignment(alignment: .justified)
                }),
                .cancel()
            ]
        )
    }
    private func fontSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Font Weights"),
            buttons: [
                .default(Text("Regular"), action: {
                    manager.wrappedValue.updateFont(weight: .regular)
                }),
                .default(Text("Bold"), action: {
                    manager.wrappedValue.updateFont(weight: .bold)
                }),
                .default(Text("Light"), action: {
                    manager.wrappedValue.updateFont(weight: .light)
                }),
                .cancel()
            ]
        )
    }
}
