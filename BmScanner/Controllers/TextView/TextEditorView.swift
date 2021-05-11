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
    
    init(note: Note, onDismiss: ((Bool) -> Void)? = nil ) {
        manager = StateObject(wrappedValue: TextEditorManger(note: note))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SUITextView(textView: manager.wrappedValue.textView)
                .sheet(item: manager.projectedValue.sheetType, content: { type in getFullScreen(type) })
                .overlay(scannerButton, alignment: .bottomLeading)
                .edgesIgnoringSafeArea(.bottom)
            TextEditorBar(manager: manager)
                
                .actionSheet(item: manager.projectedValue.actionSheetType, content: getActionSheet)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(DateFormatter.relativeDateFormatter.string(from: manager.wrappedValue.note.created ?? Date()))
        .navigationBarItems(leading: navBarLeading, trailing: navBarTrailing)
    }
}

// SubViews
extension TextEditorView {
    
    private var scannerButton: some View {
        return ScannerButton { txt in
            guard let newText = txt else { return }
            manager.wrappedValue.textStylingManager.appendTexts(appendingTexts: newText)
        }
        .opacity(manager.wrappedValue.textView.isEditable ? 0 : 1)
    }
    
    private var navBarTrailing: some View {
        return HStack(spacing: 0) {
            
            Button(action: {
                manager.wrappedValue.actionSheetType = .InfoSheet
            }, label: {
                Image(systemName: "info")
                    .padding()
            })
            
            Button(action: {
                manager.wrappedValue.actionSheetType = .ShareMenu
            }, label: {
                Image(systemName: "square.and.arrow.up")
                    .padding(.vertical)
            })
            
        }
    }
    
    private var navBarLeading: some View {
        return HStack {
            Button(action: {
                manager.wrappedValue.saveChanges()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Done")
            })
            
        }
    }
}

// Full Screen
extension TextEditorView {
    
    private func getFullScreen(_ type: TextEditorManger.FullScreenType) -> some View {
        return Group {
            switch type {
            case .ShareAttributedText:
                if let x = manager.wrappedValue.textView.attributedText {
                    ActivityView(activityItems: [x])
                }
            case .PDFViewer:
                if let url = manager.wrappedValue.tempSavedDocumentUrl {
                    PDFViewerView(url: url)
                }
            case .FolderPicker:
                FolderPicker { folder in
                    manager.wrappedValue.note.folder = folder
                }
            case .ShareAsImages:
                let images = manager.wrappedValue.textView.attributedText.mutable.convertToImages()
                ActivityView(activityItems: images)
            case .FontPicker:
                FontPickerController { font in
                    manager.wrappedValue.textStylingManager.updateFont(newFont: font)
                }
            case .ShareUrl:
                if let url = manager.wrappedValue.tempSavedDocumentUrl {
                    
                    ActivityView(activityItems: [url])
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .font(UserDefaultManager.shared.font())
        .accentColor(UserDefaultManager.shared.appTintColor.color)
    }
}

// Action Sheets

extension TextEditorView {
    
    private func getActionSheet(_ type: TextEditorManger.ActionSheetType) -> ActionSheet {
        switch type {
        case .ShareMenu:
            return shareActionSheet()
        case .InfoSheet:
            return infoActionSheet()
        case .EditMenuSheet:
            return moreEditingActionSheet()
        case .AlignmentSheet:
            return alignmentActionSheet()
        case .FontWeightSheet:
            return textWeightActionSheet()
        case .ColorPicker:
            return colorPickerActionSheet()
        }
    }
    // Share
    private func shareActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Export & share as .."),
            buttons: [
                .default(Text("PDF Document"), action: {
                    if let pdfData = manager.wrappedValue.textView.attributedText.convertToPDF() {
                        let fileName = "\(Date().description).pdf"
                        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
                        do {
                            try pdfData.write(to: url)
                            manager.wrappedValue.tempSavedDocumentUrl = url
                            manager.wrappedValue.sheetType = .PDFViewer
                        }catch {
                            print(error)
                        }
                    }
                }),
                .default(Text("RTF Document"), action: {
                    if let attributedText = manager.wrappedValue.textView.attributedText,
                       let rtfData = try? attributedText.data(from: attributedText.range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                        let fileName = "\(Date().description).rtf"
                        
                        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
                        do {
                            try rtfData.write(to: url)
                            manager.wrappedValue.tempSavedDocumentUrl = url
                            manager.wrappedValue.sheetType = .ShareUrl
                        }catch {
                            print(error)
                        }
                    }
                }),
                .default(Text("HTML Document"), action: {
                    if let attributedText = manager.wrappedValue.textView.attributedText,
                       let rtfData = try? attributedText.data(from: attributedText.range, documentAttributes: [.documentType: NSAttributedString.DocumentType.html]) {
                        let fileName = "\(Date().description).html"
                        
                        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName)
                        do {
                            try rtfData.write(to: url)
                            manager.wrappedValue.tempSavedDocumentUrl = url
                            manager.wrappedValue.sheetType = .ShareUrl
                        }catch {
                            print(error)
                        }
                    }
                }),
                .default(Text("Plain Text"), action: {
                    manager.wrappedValue.sheetType = .ShareAttributedText
                }),
                .default(Text("As Images"), action: {
                    manager.wrappedValue.sheetType = .ShareAsImages
                }),
                .cancel()
            ]
        )
    }
    
    // Info
    private func infoActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Info"),
            buttons: [
                .default(Text("Move folder to.."), action: {
                    manager.wrappedValue.sheetType = .FolderPicker
                }),
                .destructive(Text("Delete this Note"), action: {
                    AlertPresenter.show(title: "Are you sure to delete this note?") { bool in
                        if bool {
                            manager.wrappedValue.note.delete()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }),
                .cancel()
            ]
        )
    }
    
    // Alignment
    private func colorPickerActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Color Styles"),
            buttons: [
                .default(Text("Text Color"), action: {
                    manager.wrappedValue.textStylingManager.updateTextColor(color: UIColor(cgColor: manager.wrappedValue.styleColor))
                }),
                .default(Text("Highlight"), action: {
                    manager.wrappedValue.textStylingManager.toggleHighlight(color: UIColor(cgColor: manager.wrappedValue.styleColor))
                }),
                
                .cancel()
            ]
        )
    }
    
    // Alignment
    private func alignmentActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Text Alignment"),
            buttons: [
                .default(Text("Left"), action: {
                    manager.wrappedValue.textStylingManager.updateAlignment(alignment: .left)
                }),
                .default(Text("Right"), action: {
                    manager.wrappedValue.textStylingManager.updateAlignment(alignment: .right)
                }),
                .default(Text("Center"), action: {
                    manager.wrappedValue.textStylingManager.updateAlignment(alignment: .center)
                }),
                .default(Text("Justify"), action: {
                    manager.wrappedValue.textStylingManager.updateAlignment(alignment: .justified)
                }),
                .cancel()
            ]
        )
    }
    
    // Text Weight
    private func textWeightActionSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Font Weights"),
            buttons: [
                .default(Text("Toggle Bold"), action: {
                    manager.wrappedValue.textView.toggleBoldface(nil)
                }),
                .default(Text("Toggle Italic"), action: {
                    manager.wrappedValue.textView.toggleItalics(nil)
                }),
                .default(Text("Toggle Underline"), action: {
                    manager.wrappedValue.textView.toggleUnderline(nil)
                }),
                .default(Text("Toggle Strikethrough"), action: {
                    manager.wrappedValue.textStylingManager.toggleStrikeThrough()
                }),
                
                .cancel()
            ]
        )
    }
    
    // More
    private func moreEditingActionSheet() -> ActionSheet {
        var buttons = [Alert.Button]()
        if let textRange = manager.wrappedValue.textView.selectedTextRange, let text = manager.wrappedValue.textView.text(in: textRange), text.components(separatedBy: .newlines).count > 1 {
            let joinTextsButton = Alert.Button.default(Text("Join text-lines")) {
                manager.wrappedValue.textStylingManager.joinSelectedTexts()
            }
            
            buttons.append(joinTextsButton)
        }
        
        buttons.append(.default(Text("Change Font"), action: {
            manager.wrappedValue.sheetType = .FontPicker
        }))
        
        buttons.append(.default(Text("Select All Texts"), action: {
            manager.wrappedValue.textView.selectAll(nil)
        }))
        buttons.append(.default(Text("Cleanup Myanmar Texts"), action: {
            manager.wrappedValue.textStylingManager.cleanUpTexts()
        }))
        buttons.append(.destructive(Text("Reset All Attributes"), action: {
            manager.wrappedValue.textView.attributedText = manager.wrappedValue.textView.attributedText.string.noteAttributedText
        }))
        
        buttons.append(.cancel())
        return ActionSheet( title: Text("Edit Text"), buttons: buttons)
    }
}
