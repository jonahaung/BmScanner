//
//  FontPickerView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 6/5/21.
//
import SwiftUI

struct FontPickerController: View {
    
    var onPickFont: (UIFont) -> Void
    @Environment(\.presentationMode) private var presentationMode
    var body: some View {
        NavigationView{
            FontPickerView(onPickFont: onPickFont)
                .navigationBarItems(trailing: Button("Cancel", action: {
                    presentationMode.wrappedValue.dismiss()
                }))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Font Picker")
        }
    }
}


private struct FontPickerView: UIViewControllerRepresentable {
    
    var onPickFont: (UIFont) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<FontPickerView>) -> UIFontPickerViewController {
        let picker = UIFontPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIFontPickerViewController, context: UIViewControllerRepresentableContext<FontPickerView>) {}
}

extension FontPickerView {
    
    class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        
        private let parent: FontPickerView
        
        init(_ parent: FontPickerView) {
            self.parent = parent
        }
        func fontPickerViewControllerDidCancel(_ viewController: UIFontPickerViewController) {
            viewController.dismiss(animated: true)
        }
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            
            let font = UIFont(descriptor: descriptor, size: 36)
            
            parent.onPickFont(font)
            viewController.dismiss(animated: true)
        }
        deinit {
            Log("Deinit")
        }
    }
}
