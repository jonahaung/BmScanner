//
//  NoteCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 3/3/21.
//

import SwiftUI

struct NoteCell: View {
    
    let note: Note
    
    var body: some View {
        NavigationLink(destination: TextEditorView(note: note)) {
            VStack(alignment: .leading){
                AttributedLabelView(attributedText: note.attributedText, numberOfLines: 4)
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
        }
    }
}
