//
//  DocPickerView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 13/12/20.
//

import SwiftUI
import MobileCoreServices
import PDFKit


struct DocPickerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIDocumentPickerViewController
    
    var onPickImage: (UIImage) -> Void
    var onGetText: (NSAttributedString) -> Void
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocPickerView>) -> UIDocumentPickerViewController {
        
        let x = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .image, .rtf, .png, .jpeg, .html])
        x.delegate = context.coordinator
        
        return x
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerView>) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        
        private let parent: DocPickerView
        
        init(_ parent: DocPickerView) {
            self.parent = parent
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first, url.startAccessingSecurityScopedResource() {
                defer {
                    DispatchQueue.main.async {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                guard let docType = url.lastPathComponent.components(separatedBy: ".").last,
                      let data = try? Data(contentsOf: url) else {
                    return
                }
                
                switch docType {
                case "pdf":
                    if let pdf = PDFDocument(url: url) {
                        let pageCount = pdf.pageCount
                        let documentContent = NSMutableAttributedString()
                        
                        for i in 1 ..< pageCount {
                            guard let page = pdf.page(at: i) else { continue }
                            guard let pageContent = page.attributedString else { continue }
                            documentContent.append(pageContent)
                        }
                        if !documentContent.string.isWhitespace {
                            parent.onGetText(documentContent)
                        }else if let image = drawPDFfromURL(url: url.absoluteURL) {
                            parent.onPickImage(image)
                        }
                    }
                case "rtf":
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.rtf]
                    do {
                        let attributedText = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                        parent.onGetText(attributedText)
                    } catch {
                        print(error)
                    }
                case "html":
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html]
                    do {
                        let attributedText = try NSAttributedString(data: data, options: options, documentAttributes: nil)
                        parent.onGetText(attributedText)
                    } catch {
                        print(error)
                    }
                case "png", "jpg":
                    if let image = UIImage(contentsOfFile: url.path) {
                        parent.onPickImage(image)
                    }
                default:
                    break
                }
                controller.dismiss(animated: true, completion: nil)
            }
        }
        
        private func drawPDFfromURL(url: URL) -> UIImage? {
            guard let document = CGPDFDocument(url as CFURL) else { return nil }
            guard let page = document.page(at: 1) else { return nil }
            
            let pageRect = page.getBoxRect(.artBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)
                
                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                
                ctx.cgContext.drawPDFPage(page)
            }
            let ciImage = CIImage(image: img)
            let cgOrientation = CGImagePropertyOrientation(img.imageOrientation)
            let orientedImage = ciImage?.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
            return orientedImage?.uiImage ?? img
        }
        
        deinit {
            Log("Deinit")
        }
    }
}
