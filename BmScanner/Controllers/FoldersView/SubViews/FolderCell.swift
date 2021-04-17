//
//  FolderCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 4/3/21.
//

import SwiftUI

struct FolderCell: View {
    
    let folder: Folder
    
    var body: some View {
        NavigationLink(destination: FolderView(folder: folder)) {
            HStack{
                let count = folder.notes?.count ?? 0
                let imageName = count == 0 ? "folder" : "folder.fill"
                Label(folder.name ?? "", systemImage: imageName)
                Spacer()
                let text = count == 0 ? String() : count.description
                Text(text)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        
    }
}
