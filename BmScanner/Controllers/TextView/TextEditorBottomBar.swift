//
//  TextEditorBottomBar.swift
//  BmScanner
//
//  Created by Aung Ko Min on 25/4/21.
//

import SwiftUI

struct TextEditorBottomBar: View {
    
    @StateObject var manager: TextEditorManger
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        unEditableBar
            .edgesIgnoringSafeArea(.bottom)
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
                manager.sheetType = .EditMenuSheet
            }, label: {
                Image(systemName: "function")
                    .padding()
            }).disabled(manager.textView.selectedRange.length == 0)
            
            Spacer()
            Button(action: {
                editMode?.wrappedValue.toggle()
            }, label: {
                Image(systemName: editMode?.wrappedValue == .active ? "keyboard.chevron.compact.down" : "square.and.pencil")
                    .padding()
                    
            })
        }
        .font(.system(size: UIFont.buttonFontSize, weight: .semibold))
        .onChange(of: editMode?.wrappedValue) { newValue in
            if let mode = newValue {
                self.manager.editingChanged(isEditing: mode.isEditing)
            }
        }
    }
}


extension EditMode {

    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
