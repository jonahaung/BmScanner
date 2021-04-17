//
//  ImagePickerView.swift
//  PictureSMS
//
//  Created by Aung Ko Min on 2/4/21.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    
    var onPickImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
}

extension ImagePicker {
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let pickedImage = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            if let image = pickedImage {
                picker.dismiss(animated: true) { [weak self] in
                    self?.parent.onPickImage(image)
                }
            }
        }
        
        deinit {
            Log("Deinit")
        }
    }
}
