//
//  ProcessorTwoView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

struct OCRView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @State var image: UIImage?
    var onGetTexts: (String?) -> Void
    @AppStorage(UserDefaultManager.shared._languageMode) private var languageModeIndex: Int = UserDefaultManager.shared.lanaguageMode.rawValue
    
    @StateObject private var manager = OCRManager()
    @StateObject private var viewManager = OCRViewManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                ImageView
                if manager.showLoading {
                    LoadingIndicator(color: .red)
                }
                Spacer()
                BottomBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Text Recognizer")
            .navigationBarItems(leading: NavigationItemLeading, trailing: NavigationItemTrailing)
            .sheet(item: $viewManager.screenType, content: { x in
                switch x {
                case .ShareImage:
                    ActivityView(activityItems: [image ?? UIImage()])
                case .ImageEditorView:
                    ImageEditorView(image: image, completion: { image in
                        self.image = image
                    })
                    
                }
            })
            .onAppear(perform: onAppear)
            
        }
    }
}

extension OCRView {
    
    private func onAppear() {
        manager.onGetTexts = { x in
            onGetTexts(x)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var LanguagePicker: some View {
        return Picker(selection: $languageModeIndex, label: Text("Language")) {
            ForEach(LanguageMode.allCases) {
                Text($0.description)
                    .tag($0.rawValue)
            }
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    private var ImageView: some View {
        return Group {
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    private var BottomBar: some View {
        return HStack {
            Button {
                viewManager.screenType = .ImageEditorView
            } label: {
                Image(systemName: "pencil.tip.crop.circle")
                    .modifier(RoundedButton())
            }
            
            LanguagePicker
            Button(action: {
                manager.recognizeText(image: image)
            }, label: {
                Image(systemName: "text.magnifyingglass")
                    .modifier(RoundedButton())
            }).disabled(manager.showLoading)
        }
        .padding(.horizontal)
    }
    
    private var NavigationItemTrailing: some View {
        return Button(action: {
            AlertPresenter.show(title: "Are you sure you want to exit?", message: "You will lost the current works") { bool in
                if bool {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }, label: {
            Text("Cancel")
        })
    }
    private var NavigationItemLeading: some View {
        return HStack {
            Button(action: {
                viewManager.screenType = .ShareImage
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })
        }
    }
}
