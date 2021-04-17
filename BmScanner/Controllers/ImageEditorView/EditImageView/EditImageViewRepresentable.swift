//
//  QuadImageView.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 2/12/20.
//

import SwiftUI
import UIKit
import AVFoundation
import Combine

struct EditImageViewRepresentable: UIViewRepresentable {

    var manager: StateObject<ImageEditManager>
    
    func makeUIView(context: Context) -> QuadImageUIView {
        let view = QuadImageUIView()
        view.delegate = manager.wrappedValue
        return view
    }
    
    
    func updateUIView(_ uiView: QuadImageUIView, context: Context) {
        uiView.imageView.image = manager.wrappedValue.editedImage
        uiView.setNeedsLayout()
        uiView.quadView.drawQuadrilateral(quad: manager.wrappedValue.imageQuad?.applying(manager.wrappedValue.cameraTransform))
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

}
protocol QuadImageUIViewDelegate: class {
    
    func quadImageUIViewDelegate(_ view: QuadImageUIView, quadDidUpdate quad: Quadrilateral?)
    func quadImageUIViewDelegate(_ view: QuadImageUIView, didUpdateCameraTransform transform: CGAffineTransform)
    func quadImageUIViewDelegate(_ view: QuadImageUIView, gestureDidStart: Bool)
    
}

class QuadImageUIView: UIView {
    
    weak var delegate: QuadImageUIViewDelegate?
    
    let imageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    let quadView: QuadrilateralView = {
        return $0
    }(QuadrilateralView())
    
    deinit {
        print("quad image view")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(imageView)
        addSubview(quadView)
        let panGesture = UILongPressGestureRecognizer(target: self, action: #selector(handle(gesture:)))
        panGesture.minimumPressDuration = 0.0
        panGesture.delegate = self
        quadView.addGestureRecognizer(panGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    func updateLayout() {
        imageView.frame = bounds
        guard let image = imageView.image else {
            return }
        let imageFrame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadView.frame = imageFrame
        CurrentSession.videoSize = image.size
        CurrentSession.currentQuadViewSize = imageFrame.size
        let scaleT = CGAffineTransform(scaleX: quadView.bounds.width, y: -quadView.bounds.height)
        let translateT = CGAffineTransform(translationX: quadView.bounds.minX, y: quadView.bounds.maxY)
        let cameraTansform = scaleT.concatenating(translateT)
        delegate?.quadImageUIViewDelegate(self, didUpdateCameraTransform: cameraTansform)
    }
    
    private var previousPanPosition: CGPoint?
    private var closestCorner: CornerPosition?
}

extension QuadImageUIView: UIGestureRecognizerDelegate {
    
    
    
    @objc func handle(gesture: UIGestureRecognizer) {
        
        guard
            let drawnQuad = quadView.viewQuad,
            let image = imageView.image
        else {
            return
        }
        
        switch gesture.state {
        case .began:
            delegate?.quadImageUIViewDelegate(self, gestureDidStart: true)
        case .changed:
            
            let position = gesture.location(in: quadView)
            
//            let isTouchingInside = quadView.quadLineLayer.path?.boundingBoxOfPath.contains(position) == true
//            
//            guard isTouchingInside else {
//                return
//            }
            let previousPanPosition = self.previousPanPosition ?? position
            let closestCorner = self.closestCorner ?? position.closestCornerFrom(quad: drawnQuad)
            
            let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
            let cornerView = quadView.cornerViewForCornerPosition(position: closestCorner)
            let draggedCornerViewCenter = cornerView.center.applying(offset)
            
            quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
            
            self.previousPanPosition = position
            self.closestCorner = closestCorner
            
            let scale = image.size.width / quadView.bounds.size.width
            let scaledDraggedCornerViewCenter = CGPoint(x: draggedCornerViewCenter.x * scale, y: draggedCornerViewCenter.y * scale)
            guard let zoomedImage = image.scaledImage(atPoint: scaledDraggedCornerViewCenter, scaleFactor: 5, targetSize: quadView.bounds.size) else {
                return
            }
            quadView.highlightCornerAtPosition(position: closestCorner, with: zoomedImage)
            SoundManager.vibrate(vibration: .soft)
        case .ended:
            previousPanPosition = nil
            closestCorner = nil
            quadView.resetHighlightedCornerViews()
            delegate?.quadImageUIViewDelegate(self, quadDidUpdate: drawnQuad)
            delegate?.quadImageUIViewDelegate(self, gestureDidStart: false)
        default:
            break
        }
    }
}

