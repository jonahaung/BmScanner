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
        VStack {
            SUITextView(manager: manager.wrappedValue)
            menuBar()
        }
        .navigationBarBackButtonHidden(true)
        .actionSheet(item: $viewManager.sheetType, content: getActionSheet)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: navBarLeading, trailing: navBarTrailing)
        .sheet(item: $viewManager.fullScreenType, content: { type in getFullScreen(type) })
        .onAppear(perform: onAppear)
    }
    
}
// Actions
extension TextEditorView {
    private func onAppear() {
        manager.wrappedValue.textView.attributedText = note.attributedText
    }
}

// SubViews
extension TextEditorView {
    
    private var toolBar: some ToolbarContent {
        return ToolbarItemGroup(placement: .bottomBar) {
            
        }
    }
    private var navBarTrailing: some View {
        return HStack {
            Button(action: {
                viewManager.sheetType = .InfoSheet
            }, label: {
                Image(systemName: "info")
            })
            
            Button(action: {
                viewManager.sheetType = .ShareMenu
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
        }.padding()
    }
    private var navBarLeading: some View {
        return HStack {
            Button("Done") {
                if note.attributedText != manager.wrappedValue.attributedText {
                    note.attributedText = manager.wrappedValue.textView.attributedText
                    note.edited = Date()
                    onDismiss?(true)
                }
                presentationMode.wrappedValue.dismiss()
            }
            Group {
                Text(manager.wrappedValue.currentFont.name)
                Text(manager.wrappedValue.fontSize.rounded().description)
            }.foregroundColor(Color(.tertiaryLabel)).font(.callout)
            
        }
    }
    private func menuBar() -> some View {
        return HStack {
            
            Button(action: {
                manager.wrappedValue.redo()
            }, label: {
                Text("Undo").padding()
            }).disabled(!manager.wrappedValue.hasHistory)
            
            Button(action: {
                manager.wrappedValue.selectAllTexts()
                UIPasteboard.general.string = manager.wrappedValue.attributedText.string
            }, label: {
                Image(systemName: "square.on.square").padding()
            })
            
            Spacer()
            
            Button(action: {
                manager.wrappedValue.downSize()
            }, label: {
                Image(systemName: "minus").padding(3)
            })
            Button(action: {
                manager.wrappedValue.upSize()
            }, label: {
                Image(systemName: "plus").padding(3)
            })
            
            Spacer()
            Button(action: {
                viewManager.sheetType = .FontMenu
            }, label: {
                Image(systemName: "textformat").padding()
            })
            
        }
    }
}
// Full Screen
extension TextEditorView {
    private func getFullScreen(_ type: TextEditorViewViewManager.FullScreenType) -> some View {
        
        return Group {
            switch type {
            case .ShareAttributedText:
                if let x = manager.wrappedValue.textView.attributedText {
                    ActivityView(activityItems: [x])
                }
            case .ShareAsPDF:
                if let x = manager.wrappedValue.convertToPDF() {
                    ActivityView(activityItems: [x])
                }
            case .PDFViewer:
                PDFViewerView(data: manager.wrappedValue.convertToPDF())
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
                .default(Text("View as PDF"), action: {
                    viewManager.fullScreenType = .PDFViewer
                }),
                .default(Text("Export as PDF"), action: {
                    viewManager.fullScreenType = .ShareAsPDF
                }),
                .default(Text("Export as Plain Text"), action: {
                    viewManager.fullScreenType = .ShareAttributedText
                }),
                .cancel()
            ]
        )
    }
    private func fontSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Font Menu"),
            buttons: [
                .default(Text("Regular"), action: {
                    manager.wrappedValue.currentFont = .Regular
                }),
                .default(Text("Bold"), action: {
                    
                    manager.wrappedValue.currentFont = .Bold
                }),
                .default(Text("Light"), action: {
                    
                    manager.wrappedValue.currentFont = .Light
                }),
                .cancel()
            ]
        )
    }
    
    private func infoSheet() -> ActionSheet {
        return ActionSheet(
            title: Text("Info"),
            buttons: [
                .default(Text("Copy Text"), action: {
                    manager.wrappedValue.selectAllTexts()
                    UIPasteboard.general.string = manager.wrappedValue.attributedText.string
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
