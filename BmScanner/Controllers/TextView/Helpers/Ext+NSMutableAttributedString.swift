//
//  Ext+NSMutableAttributedString.swift
//  BmScanner
//
//  Created by Aung Ko Min on 7/5/21.
//

import UIKit

extension NSAttributedString {
    func convertToPDF() -> NSMutableData? {
        let printFormatter = UISimpleTextPrintFormatter(attributedText: self)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
//                let ratio = 841.8 / 595.2
//                let pageSize = CGSize(width: textView.frame.size.width, height: textView.frame.size.width * CGFloat(ratio))
//                let pageMargins = textView.textContainerInset
        
        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)
        
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        
        return pdfData
    }
    
    func convertToImages()  -> [UIImage] {
        if let data = convertToPDF(), let cgData = CGDataProvider(data: data) {
            guard let document = CGPDFDocument(cgData) else { return [] }
            var images = [UIImage]()
            for i in (1..<document.numberOfPages+1) {
                guard let page = document.page(at: i) else { continue }
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
                if let orientedImage = ciImage?.oriented(forExifOrientation: Int32(cgOrientation.rawValue)).uiImage {
                    images.append(orientedImage)
                }
            }
            return images
        }
        return []
    }
}
