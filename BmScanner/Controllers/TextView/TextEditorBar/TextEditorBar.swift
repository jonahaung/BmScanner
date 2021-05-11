//
//  TextEditorBar.swift
//  BmScanner
//
//  Created by Aung Ko Min on 10/5/21.
//

import SwiftUI

struct TextEditorBar: View {
    
    var manager: StateObject<TextEditorManger>
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                SuggesstionsView(manager: manager)
                editButton
            }
            bottomBar
        }
    }
    
    private var editButton: some View {
        return Button {
            manager.wrappedValue.textView.toggleKeyboard()
        } label: {
            let imageName = manager.wrappedValue.textView.isEditable ? "chevron.down.circle.fill" : "pencil.circle.fill"
            Image(systemName: imageName)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .padding(5)
        }
    }
    
    // Botom Bar
    private var bottomBar: some View {
        return HStack(spacing: 10) {
            Group {
                Button(action: {
                    manager.wrappedValue.textView.undoManager?.undo()
                }, label: {
                    Image(systemName: "arrow.counterclockwise")
                })
                .disabled(manager.wrappedValue.textView.undoManager?.canUndo == false)
                Button(action: {
                    manager.wrappedValue.textView.undoManager?.redo()
                }, label: {
                    Image(systemName: "arrow.clockwise")
                })
                .disabled(manager.wrappedValue.textView.undoManager?.canRedo == false)
            }
            
            Spacer()
            
            Group {
                Button(action: {
                    manager.wrappedValue.textStylingManager.updateFontSize(diff: -0.5)
                }, label: {
                    Image(systemName: "minus")
                    
                })
                Button(action: {
                    manager.wrappedValue.textStylingManager.updateFontSize(diff: 0.5)
                }, label: {
                    Image(systemName: "plus")
                })
                
            }
            
            Spacer()
            
            ColorPicker(String(), selection: manager.projectedValue.styleColor, supportsOpacity: true)
            Spacer()
            Group {
                
                Button(action: {
                    manager.wrappedValue.actionSheetType = .AlignmentSheet
                }, label: {
                    Image(systemName: "text.alignleft")
                })
                Button(action: {
                    manager.wrappedValue.actionSheetType = .FontWeightSheet
                }, label: {
                    Image(systemName: "bold.italic.underline")
                })
            }
            .disabled(manager.wrappedValue.textView.selectedRange.length == 0)
            Spacer()
            Button(action: {
                manager.wrappedValue.actionSheetType = .EditMenuSheet
            }, label: {
                Image(systemName: "ellipsis")
            })
        }
        .padding()
        .font(.system(size: 17, weight: .medium, design: .serif))
    }
}
