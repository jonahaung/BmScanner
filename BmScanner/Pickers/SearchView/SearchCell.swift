//
//  SearchCell.swift
//  BmScanner
//
//  Created by Aung Ko Min on 25/4/21.
//

import SwiftUI

struct SearchCell: View {
    let note: Note
    
    var body: some View {
        VStack(spacing: 0) {
            if let text = note.text {
                Text(text)
                    .lineLimit(2)
                    .font(.footnote)
            }
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
        }.padding(.vertical, 5)
    }
}
