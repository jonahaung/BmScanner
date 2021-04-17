//
//  RectangleView.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation


final class QuadrilateralView: UIView {

    private let quadLayer: CAShapeLayer = {
        return $0
    }(CAShapeLayer())

    let quadLineLayer: CAShapeLayer = {
        $0.fillColor = nil
        $0.lineWidth = 1.5
        $0.strokeColor = UIColor.systemYellow.cgColor
        return $0
    }(CAShapeLayer())
    private let fillColor = UIColor.systemBackground.cgColor
    private let quadView: UIView = {
        return $0
    }(UIView())
    
    private(set) var viewQuad: Quadrilateral?
    
    public var editable = true {
        didSet {
            guard oldValue != editable else { return }
            cornerViews(hidden: !editable)
        }
    }
    
    private var isHighlighted = false {
        didSet {
            guard oldValue != isHighlighted else { return }
            quadLayer.fillColor = isHighlighted ? UIColor.separator.cgColor : fillColor
            isHighlighted ? bringSubviewToFront(quadView) : sendSubviewToBack(quadView)
        }
    }
    
    lazy private var topLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topLeft)
    }()
    
    lazy private var topRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .topRight)
    }()
    
    lazy private var bottomRightCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomRight)
    }()
    
    lazy private var bottomLeftCornerView: EditScanCornerView = {
        return EditScanCornerView(frame: CGRect(origin: .zero, size: cornerViewSize), position: .bottomLeft)
    }()
    
    private let highlightedCornerViewSize = CGSize(width: 120, height: 120)
    private let cornerViewSize = CGSize(width: 15, height: 15)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        quadLayer.fillColor = fillColor
        addSubview(quadView)
        setupCornerViews()
        quadView.frame = bounds
        quadView.layer.addSublayer(quadLayer)
        quadView.layer.addSublayer(quadLineLayer)
    }
    
    private func setupCornerViews() {
        addSubview(topLeftCornerView)
        addSubview(topRightCornerView)
        addSubview(bottomRightCornerView)
        addSubview(bottomLeftCornerView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        quadView.frame = bounds
        guard quadLayer.frame != bounds else {
            return
        }
        let scale = bounds.width / quadLayer.frame.width
        quadLayer.frame = bounds
        let newQuad = viewQuad?.applying(CGAffineTransform(scaleX: scale, y: scale))
        drawQuadrilateral(quad: newQuad)
    }
    
    func drawQuadrilateral(quad: Quadrilateral?) {
        self.viewQuad = quad
        guard let quad = quad else {
            quadLayer.path = nil
            quadLineLayer.path = nil
            cornerViews(hidden: true)
            return
        }
        
        draw(quad, animated: !isHighlighted)
        if editable {
            cornerViews(hidden: false)
            layoutCornerViews(forQuad: quad)
        }
    }
    
    private func draw(_ quad: Quadrilateral, animated: Bool) {
        let path = quad.path
        quadLineLayer.path = path.cgPath
        if editable {
            let rectPath = UIBezierPath(rect: bounds)
            rectPath.usesEvenOddFillRule = true
            path.append(rectPath)
        }
        quadLayer.path = path.cgPath
        
        if animated == true {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = 0.2
            quadLayer.add(pathAnimation, forKey: "path")
        }
        
    }
    
    private func layoutCornerViews(forQuad quad: Quadrilateral) {
        topLeftCornerView.center = quad.topLeft
        topRightCornerView.center = quad.topRight
        bottomLeftCornerView.center = quad.bottomLeft
        bottomRightCornerView.center = quad.bottomRight
    }
    
    // MARK: - Actions
    
    func moveCorner(cornerView: EditScanCornerView, atPoint point: CGPoint) {
        guard let quad = viewQuad else {
            return
        }
        
        let validPoint = self.validPoint(point, forCornerViewOfSize: cornerView.bounds.size, inView: self)
        
        cornerView.center = validPoint
        let updatedQuad = update(quad, withPosition: validPoint, forCorner: cornerView.position)
        drawQuadrilateral(quad: updatedQuad)
//        self.quad = updatedQuad
//        drawQuad(updatedQuad, animated: false)
//        delegate?.quadrilateralView(self, quadrilateralDidUpdate: updatedQuad)
    }
    
    func highlightCornerAtPosition(position: CornerPosition, with image: UIImage) {
        guard editable else { return }
        isHighlighted = true
        
        let cornerView = cornerViewForCornerPosition(position: position)
        guard cornerView.isHighlighted == false else {
            cornerView.highlightWithImage(image)
            return
        }
        
        let origin = CGPoint(x: cornerView.frame.origin.x - (highlightedCornerViewSize.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y - (highlightedCornerViewSize.height - cornerViewSize.height) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: highlightedCornerViewSize)
        cornerView.highlightWithImage(image)
    }
    
    func resetHighlightedCornerViews() {
        isHighlighted = false
        resetHighlightedCornerViews(cornerViews: [topLeftCornerView, topRightCornerView, bottomLeftCornerView, bottomRightCornerView])
    }
    
    private func resetHighlightedCornerViews(cornerViews: [EditScanCornerView]) {
        cornerViews.forEach { (cornerView) in
            resetHightlightedCornerView(cornerView: cornerView)
        }
    }
    
    private func resetHightlightedCornerView(cornerView: EditScanCornerView) {
        cornerView.reset()
        let origin = CGPoint(x: cornerView.frame.origin.x + (cornerView.frame.size.width - cornerViewSize.width) / 2.0,
                             y: cornerView.frame.origin.y + (cornerView.frame.size.height - cornerViewSize.width) / 2.0)
        cornerView.frame = CGRect(origin: origin, size: cornerViewSize)
        cornerView.setNeedsDisplay()
    }
    
    // MARK: Validation
    
    /// Ensures that the given point is valid - meaning that it is within the bounds of the passed in `UIView`.
    ///
    /// - Parameters:
    ///   - point: The point that needs to be validated.
    ///   - cornerViewSize: The size of the corner view representing the given point.
    ///   - view: The view which should include the point.
    /// - Returns: A new point which is within the passed in view.
    private func validPoint(_ point: CGPoint, forCornerViewOfSize cornerViewSize: CGSize, inView view: UIView) -> CGPoint {
        var validPoint = point
        
        if point.x > view.bounds.width {
            validPoint.x = view.bounds.width
        } else if point.x < 0.0 {
            validPoint.x = 0.0
        }
        
        if point.y > view.bounds.height {
            validPoint.y = view.bounds.height
        } else if point.y < 0.0 {
            validPoint.y = 0.0
        }
        
        return validPoint
    }
    
    // MARK: - Convenience
    
    private func cornerViews(hidden: Bool) {
        topLeftCornerView.isHidden = hidden
        topRightCornerView.isHidden = hidden
        bottomRightCornerView.isHidden = hidden
        bottomLeftCornerView.isHidden = hidden
    }
    
    private func update(_ quad: Quadrilateral, withPosition position: CGPoint, forCorner corner: CornerPosition) -> Quadrilateral {
        var quad = quad
        
        switch corner {
        case .topLeft:
            quad.topLeft = position
        case .topRight:
            quad.topRight = position
        case .bottomRight:
            quad.bottomRight = position
        case .bottomLeft:
            quad.bottomLeft = position
        }
        
        return quad
    }
    
    func cornerViewForCornerPosition(position: CornerPosition) -> EditScanCornerView {
        switch position {
        case .topLeft:
            return topLeftCornerView
        case .topRight:
            return topRightCornerView
        case .bottomLeft:
            return bottomLeftCornerView
        case .bottomRight:
            return bottomRightCornerView
        }
    }
}
