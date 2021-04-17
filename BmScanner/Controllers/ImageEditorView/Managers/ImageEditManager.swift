//
//  ImageCropManager.swift
//  BmScanner
//
//  Created by Aung Ko Min on 12/4/21.
//

import UIKit
import Vision

final class ImageEditManager: ObservableObject {
    
    @Published var editedImage: UIImage?
    @Published var isEditing = false
    @Published var imageQuad: Quadrilateral?
    @Published var editedImages = [UIImage]()
    var cameraTransform = CGAffineTransform.identity
    
    func start(_ image: UIImage?) {
        editedImage = image
        updatedEditedImages()
        
    }
    
    func undoChanges() {
        if editedImages.count > 1 {
            editedImages.removeLast()
            editedImage = editedImages.last
        }else {
            editedImage = editedImages.last
        }
        SoundManager.vibrate(vibration: .soft)
    }

    func save() {
        applyCropping()
        updatedEditedImages()
    }
    
    private func updatedEditedImages() {
        if let edited = editedImage {
            editedImages.append(edited)
            SoundManager.vibrate(vibration: .soft)
        }
    }
    
    deinit {
        Log("Deinit")
    }
}

extension ImageEditManager {
    func detectTextBox() {
        isEditing = true
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        Async.userInitiated{ [weak self] in
            guard let image = self?.editedImage,
                  let buffer = image.pixelBuffer()
            else {
                Async.main { self?.isEditing = false }
                return
            }
            
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
            
            do {
                try handler.perform([request])
            } catch {
                Async.main { self?.isEditing = false }
                print(error)
            }
        }.main { [weak self] in
            guard
                let sself = self,
                let results = request.results as? [VNRecognizedTextObservation],
                !results.isEmpty
            else {
                self?.imageQuad = Quadrilateral.fullQuad
                self?.isEditing = false
                return
            }
            let boxes = results.map{$0.boundingBox}
            let rect = boxes.reduce(CGRect.null, {$0.union($1)})
            sself.imageQuad = Quadrilateral(rect: rect)
            sself.isEditing = false
            SoundManager.vibrate(vibration: .soft)
        }
    }
    
    func applyBlackAndWhiteFilter() {
        guard let image = editedImage else { return }
        let ciImage = CIImage(image: image)
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage?.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        editedImage = orientedImage?.applyingAdaptiveThreshold()?.uiImage ?? image
        updatedEditedImages()
    }
    
    func applyNoirFilter() {
        guard let image = editedImage, let openGLContext = EAGLContext(api: .openGLES2) else { return }
        let ciContext = CIContext(eaglContext: openGLContext)
        
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return }
        currentFilter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
           let cgImage = ciContext.createCGImage(output, from: output.extent) {
            editedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
            updatedEditedImages()
        }
    }
    
    private func applyCropping() {
        guard let image = editedImage, let quad = imageQuad else { return  }
        let scaledQuad = quad.applying(cameraTransform).scale(CurrentSession.currentQuadViewSize, image.size)
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()
        
        guard let ciImage = CIImage(image: image) else { return }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        
        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
            "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
            "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
            "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
        ])
        editedImage = filteredImage.uiImage
        imageQuad = nil
    }
}

extension ImageEditManager: QuadImageUIViewDelegate {
    
    func quadImageUIViewDelegate(_ view: QuadImageUIView, gestureDidStart gestureDidBegan: Bool) {
        isEditing = gestureDidBegan
    }
    
    func quadImageUIViewDelegate(_ view: QuadImageUIView, quadDidUpdate quad: Quadrilateral?) {
        imageQuad = quad?.applying(cameraTransform.inverted())
    }
    
    func quadImageUIViewDelegate(_ view: QuadImageUIView, didUpdateCameraTransform transform: CGAffineTransform) {
        cameraTransform = transform
    }
}
