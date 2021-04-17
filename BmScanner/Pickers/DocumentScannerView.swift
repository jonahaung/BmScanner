//  Created by Martin Mitrevski on 15.06.19.
//  Copyright © 2019 Mitrevski. All rights reserved.
//

import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    
    var onPickImage: (UIImage) -> Void

    typealias UIViewControllerType = VNDocumentCameraViewController
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentScannerView>) -> VNDocumentCameraViewController {
        let x = VNDocumentCameraViewController()
        x.delegate = context.coordinator
        
        return x
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<DocumentScannerView>) {
        
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        
        private let parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount > 0 else { return }
            let image = scan.imageOfPage(at: 0)
            controller.dismiss(animated: true) { [weak self] in
                self?.parent.onPickImage(image)
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        deinit {
            Log("deinit")
        }
    }
}
