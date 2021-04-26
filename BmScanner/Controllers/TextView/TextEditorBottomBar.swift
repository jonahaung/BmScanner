//
//  TextEditorBottomBar.swift
//  BmScanner
//
//  Created by Aung Ko Min on 25/4/21.
//

import SwiftUI

struct TextEditorBottomBar: View {
    
    @StateObject var manager: TextEditorManger
    @StateObject var viewManager: TextEditorViewViewManager
    
    var body: some View {
        Group {
            if manager.isEditable {
                editableBar
            }else {
                unEditableBar
            }
        }
    }
    
    private var editableBar: some View {
        return HStack {
            Spacer()
            
            Button(action: {
                manager.isEditing.toggle()
            }, label: {
                Image(systemName: manager.isEditing ? "chevron.down" : "square.and.pencil")
                    .padding()
            })
        }
    }
    
    private var unEditableBar: some View {
        return HStack {
            Button(action: {
                manager.redo()
            }, label: {
                Text("Undo").padding(.leading)
            })
            .disabled(!manager.hasHistory)
            
            Spacer()
            Button(action: {
                manager.downSize()
            }, label: {
                Image(systemName: "minus")
                    .padding(4)
            })
            
            Button(action: {
                manager.upSize()
            }, label: {
                Image(systemName: "plus")
                    .padding(4)
            })
            Spacer()
            Button(action: {
                viewManager.sheetType = .EditMenuSheet
            }, label: {
                Image(systemName: "tuningfork")
                    .padding()
            })
            .disabled(!manager.hasSelectedText)
            Spacer()
            Button(action: {
                manager.isEditable.toggle()
                if manager.isEditable {
                    manager.isEditing = true
                    manager.textView.ensureCaretToTheEnd()
                }
            }, label: {
                Image(systemName: "pencil.and.outline")
                    .padding()
            })
        }
    }
}
