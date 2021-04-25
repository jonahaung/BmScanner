//
//  FolderPicker.swift
//  BmScanner
//
//  Created by Aung Ko Min on 18/4/21.
//

import SwiftUI

struct FolderPicker: View {
    
    @FetchRequest(fetchRequest: Folder.homeViewFetchRequest)
    private var folders: FetchedResults<Folder>
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = String()
    var onPickFolder: (Folder?) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(folders) { folder in
                        FolderPickerCell(folder: folder).onTapGesture {
                            SoundManager.vibrate(vibration: .soft)
                            onPickFolder(folder)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                Section {
                    Button {
                        onPickFolder(nil)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Default Folder")
                    }

                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Foler Picker")
        }
        .font(UserDefaultManager.shared.font())
        .accentColor(UserDefaultManager.shared.appTintColor.color)
    }
}
struct FolderPickerCell: View {
    
    let folder: Folder
    
    var body: some View {
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
