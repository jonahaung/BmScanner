//
//  ProcessorOneView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

struct ImageEditorView: View {
    
    let image: UIImage?
    var completion: (UIImage?) -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var manager = ProcessorOneManager()
    @StateObject private var imageEditManager = ImageEditManager()
    
    var body: some View {
        VStack {
            EditImageViewRepresentable(manager: _imageEditManager)
            Spacer()
            BottomBar
                .padding(.horizontal)
                .padding(.bottom)
        }
        .font(.system(size: CGFloat(UserDefaultManager.shared.appFontSize), design: UserDefaultManager.shared.appFontDesign.design))
        .accentColor(UserDefaultManager.shared.appTintColor.color)
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        imageEditManager.start(image)
    }
}

extension ImageEditorView {
    
    
    
    private var UndoButton: some View {
        return Button(action: {
            imageEditManager.undoChanges()
        }, label: {
            Image(systemName: "gobackward")
                .background(Text((imageEditManager.editedImages.count - 1).description).font(.caption))
        })
        .disabled(imageEditManager.editedImages.count <= 1)
    }
    
    private var BottomBar: some View {
        return HStack {
            UndoButton
            Spacer()
            Button(action: {
                manager.actionSheetType = .FilterMenu
            }, label: {
                Image(systemName: "camera.filters").padding()
            })
            .actionSheet(item: $manager.actionSheetType) { type in
                getFilterActionSheet(type)
            }
            Spacer()
            Button(action: {
                if imageEditManager.imageQuad == nil {
                    imageEditManager.detectTextBox()
                } else {
                    
                    imageEditManager.imageQuad = nil
                }
            }, label: {
                Image(systemName: "crop").padding()
            })
            
            Spacer()
            Button(action: {
                if imageEditManager.imageQuad == nil {
                    completion(imageEditManager.editedImage)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    imageEditManager.save()
                }
            }, label: {
                Text(imageEditManager.imageQuad == nil ? "Done" : "Apply")
            })
        }
        .disabled(imageEditManager.isEditing)
    }
    
    
    private func getFilterActionSheet(_ type: ProcessorOneManager.ActionSheetType) -> ActionSheet {
        ActionSheet(title: Text("Filter"), message: Text("Filter MEnu"), buttons: [
            .default(Text("GrayScaled"), action: {
                imageEditManager.applyNoirFilter()
            }),
            .default(Text("Black & White"), action: {
                imageEditManager.applyBlackAndWhiteFilter()
            }),
            .cancel()
        ])
    }
}
