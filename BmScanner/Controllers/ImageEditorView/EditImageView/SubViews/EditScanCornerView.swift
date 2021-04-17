//
//  EditScanCornerView.swift
//  WeScan
//
//  Created by Boris Emorine on 3/5/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// A UIView used by corners of a quadrilateral that is aware of its position.
final class EditScanCornerView: UIView {
    
    let position: CornerPosition
    
    /// The image to display when the corner view is highlighted.
    private var image: UIImage?
    private let fillColor = UIColor.systemYellow.cgColor
    
    private(set) var isHighlighted = false {
        didSet {
            circleLayer.fillColor = isHighlighted ? nil : fillColor
        }
    }
    
    private let circleLayer: CAShapeLayer = {
        $0.lineWidth = 0
        $0.opacity = 1
        return $0
    }(CAShapeLayer())
    
    init(frame: CGRect, position: CornerPosition) {
        self.position = position
        super.init(frame: frame)
        circleLayer.fillColor = fillColor
        
        clipsToBounds = true
        layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2.0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let bezierPath = UIBezierPath(ovalIn: rect.insetBy(dx: circleLayer.lineWidth, dy: circleLayer.lineWidth))
        circleLayer.frame = rect
        circleLayer.path = bezierPath.cgPath
        image?.draw(in: rect)
    }
    
    func highlightWithImage(_ image: UIImage) {
        
        self.image = image
        self.setNeedsDisplay()
        isHighlighted = true
    }
    
    func reset() {
        
        image = nil
        setNeedsDisplay()
        isHighlighted = false
    }
    
}
