//
//  NoteCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 3/3/21.
//

import SwiftUI

struct NoteCell: View {
    
    let note: Note
    @State private var attributedText: NSAttributedString?
    
    var body: some View {
        NavigationLink(destination: destination(note: note)) {
            VStack(alignment: .leading){
                AttributedLabelView(attributedText: attributedText ?? note.attributedText)
                if let folderName = note.folder?.name, let date = note.created {
                    HStack {
                        Label(folderName, systemImage: "folder.fill")
                            
                        Spacer()
                        Text("\(date, formatter: DateFormatter.relativeDateFormatter)")
                    }
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
                    .padding(.top, 3)
                    
                }
                
            }
            .padding(.vertical, 7)
        }.onAppear{
            attributedText = note.attributedText
        }
    }
    
    private func destination(note: Note) -> some View {
        return TextEditorView(note: note) { hasChanges in
            if hasChanges {
                attributedText = note.attributedText
            }
        }
    }
}