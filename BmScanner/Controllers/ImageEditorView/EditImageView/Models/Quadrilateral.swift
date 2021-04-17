//
//  Quadrilateral.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import Vision
//import CoreGraphics

struct Quadrilateral: Transformable {
    
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
    
    var boundingBox: CGRect = .zero
    static var zero: Quadrilateral {
        return .init()
    }
    
    init() {
        self.init(rect: .zero)
    }
    init(rect: CGRect) {
        topLeft = CGPoint(x: rect.minX, y: rect.minY)
        topRight = CGPoint(x: rect.maxX, y: rect.minY)
        bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
       
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
        boundingBox = CGRect(x: topLeft.x, y: topLeft.y, width: topRight.x-topLeft.x, height: topRight.y-bottomRight.y)
    }
    init(rectangleObservation: VNRectangleObservation) {
        self.topLeft = rectangleObservation.topLeft
        self.topRight = rectangleObservation.topRight
        self.bottomLeft = rectangleObservation.bottomLeft
        self.bottomRight = rectangleObservation.bottomRight
    }
    var description: String {
        return "topLeft: \(topLeft), topRight: \(topRight), bottomRight: \(bottomRight), bottomLeft: \(bottomLeft)"
    }
    
    var path: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.close()
        return path
    }
    
    var regionRect: CGRect {
        let origin = CGPoint(
            x: max(topLeft.x,bottomLeft.x),
            y: max(topLeft.y, topRight.y))

        let size = CGSize(
            width: min(topRight.x, bottomRight.x) - origin.x,
            height: min(bottomLeft.y, bottomRight.y) - origin.y)
        return CGRect(origin: origin, size: size)
    }
    
    func applying(_ transform: CGAffineTransform) -> Quadrilateral {
        return Quadrilateral(topLeft: topLeft.applying(transform), topRight: topRight.applying(transform), bottomRight: bottomRight.applying(transform), bottomLeft: bottomLeft.applying(transform))
    }
    
    /// Reorganizes the current quadrilateal, making sure that the points are at their appropriate positions. For example, it ensures that the top left point is actually the top and left point point of the quadrilateral.
    mutating func reorganize() {
        let points = [topLeft, topRight, bottomRight, bottomLeft]
        let ySortedPoints = sortPointsByYValue(points)
        
        guard ySortedPoints.count == 4 else {
            return
        }
        let topMostPoints = Array(ySortedPoints[0..<2])
        let bottomMostPoints = Array(ySortedPoints[2..<4])
        let xSortedTopMostPoints = sortPointsByXValue(topMostPoints)
        let xSortedBottomMostPoints = sortPointsByXValue(bottomMostPoints)
        
        guard xSortedTopMostPoints.count > 1,
            xSortedBottomMostPoints.count > 1 else {
                return
        }
        
        topLeft = xSortedTopMostPoints[0]
        topRight = xSortedTopMostPoints[1]
        bottomRight = xSortedBottomMostPoints[1]
        bottomLeft = xSortedBottomMostPoints[0]
    }
    
    /// Scales the quadrilateral based on the ratio of two given sizes, and optionaly applies a rotation.
    ///
    /// - Parameters:
    ///   - fromSize: The size the quadrilateral is currently related to.
    ///   - toSize: The size to scale the quadrilateral to.
    ///   - rotationAngle: The optional rotation to apply.
    /// - Returns: The newly scaled and potentially rotated quadrilateral.
    func scale(_ fromSize: CGSize, _ toSize: CGSize, withRotationAngle rotationAngle: CGFloat = 0.0) -> Quadrilateral {
        var invertedfromSize = fromSize
        let rotated = rotationAngle != 0.0
        
        if rotated && rotationAngle != CGFloat.pi {
            invertedfromSize = CGSize(width: fromSize.height, height: fromSize.width)
        }
        
        var transformedQuad = self
        let invertedFromSizeWidth = invertedfromSize.width == 0 ? .leastNormalMagnitude : invertedfromSize.width
        
        let scale = toSize.width / invertedFromSizeWidth
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        transformedQuad = transformedQuad.applying(scaledTransform)
        
        if rotated {
            let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
            
            let fromImageBounds = CGRect(origin: .zero, size: fromSize).applying(scaledTransform).applying(rotationTransform)
            
            let toImageBounds = CGRect(origin: .zero, size: toSize)
            let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: fromImageBounds, toCenterOfRect: toImageBounds)
            
            transformedQuad = transformedQuad.applyTransforms([rotationTransform, translationTransform])
        }
        
        return transformedQuad
    }
    
    // Convenience functions
    
    /// Sorts the given `CGPoints` based on their y value.
    /// - Parameters:
    ///   - points: The poinmts to sort.
    /// - Returns: The points sorted based on their y value.
    private func sortPointsByYValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.y < point2.y
        }
    }
    
    /// Sorts the given `CGPoints` based on their x value.
    /// - Parameters:
    ///   - points: The points to sort.
    /// - Returns: The points sorted based on their x value.
    private func sortPointsByXValue(_ points: [CGPoint]) -> [CGPoint] {
        return points.sorted { (point1, point2) -> Bool in
            point1.x < point2.x
        }
    }
    
//    func smoothed(with previous: inout [Quadrilateral]) -> Quadrilateral {
//
//        let allFeatures = [self] + previous
//        let smoothed = allFeatures.average
//        previous = Array(allFeatures.prefix(10))
//
//        return smoothed
//    }
//
//    func difference(to: Quadrilateral) -> CGFloat {
//        abs(to.topLeft - topLeft) +
//        abs(to.topRight - topRight) +
//        abs(to.bottomLeft - bottomLeft) +
//        abs(to.bottomRight - bottomRight)
//    }
//
//    /// This isn't the real area, but enables correct comparison
//    private var areaQualifier: CGFloat {
//        let diagonalToLeft = (topRight - bottomLeft)
//        let diagonalToRight = (topLeft - bottomRight)
//        let phi = diagonalToLeft.x * diagonalToRight.x
//            + diagonalToLeft.y * diagonalToRight.y
//            / (diagonalToLeft.length * diagonalToRight.length)
//        return sqrt(1 - phi * phi) * diagonalToLeft.length * diagonalToRight.length
//    }
}

extension Quadrilateral {
    
    /// Converts the current to the cartesian coordinate system (where 0 on the y axis is at the bottom).
    ///
    /// - Parameters:
    ///   - height: The height of the rect containing the quadrilateral.
    /// - Returns: The same quadrilateral in the cartesian corrdinate system.
    func toCartesian(withHeight height: CGFloat) -> Quadrilateral {
        let topLeft = self.topLeft.cartesian(withHeight: height)
        let topRight = self.topRight.cartesian(withHeight: height)
        let bottomRight = self.bottomRight.cartesian(withHeight: height)
        let bottomLeft = self.bottomLeft.cartesian(withHeight: height)
        
        return Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
    }
    static let defaultQuad = Quadrilateral(rect: CGRect(x: 0.05, y: 0.05, width: 0.9, height: 0.9))
    static let fullQuad = Quadrilateral(rect: CGRect(x: 0, y: 0, width: 1, height: 1))
}

extension Quadrilateral: Equatable {
    static func == (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
        return lhs.topLeft == rhs.topLeft && lhs.topRight == rhs.topRight && lhs.bottomRight == rhs.bottomRight && lhs.bottomLeft == rhs.bottomLeft
    }
}
//extension Quadrilateral: Comparable {
//    public static func < (lhs: Quadrilateral, rhs: Quadrilateral) -> Bool {
//        lhs.areaQualifier < rhs.areaQualifier
//    }
//}


//extension CGSize {
//    var aspectRatio: CGFloat {
//        width / height
//    }
//}
//
//extension CGPoint {
//    func distorted(by distortion: CGVector) -> CGPoint {
//        CGPoint(x: x * distortion.dx, y: y * distortion.dy)
//    }
//
//    func yAxisInverted(_ maxY: CGFloat) -> CGPoint {
//        CGPoint(x: x, y: maxY - y)
//    }
//
//    func shifted(by shiftAmount: CGPoint) -> CGPoint {
//        CGPoint(x: x + shiftAmount.x, y: y + shiftAmount.y)
//    }
//
//    var length: CGFloat {
//        sqrt(x * x + y * y)
//    }
//}
