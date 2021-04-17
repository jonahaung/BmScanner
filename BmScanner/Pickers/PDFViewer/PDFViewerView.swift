//
//  PDFViewerView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import SwiftUI

struct PDFViewerView: View {
    
    var data: NSMutableData?
    
    var body: some View {
        NavigationView {
            VStack {
                MyPDFView(data: data)
                bottomBar
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var bottomBar: some View {
        return HStack {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            Spacer()
        }
        .padding()
    }
}


extension NSAttributedString {
    func pdfData() -> NSMutableData? {
        
        let printFormatter = UISimpleTextPrintFormatter(attributedText: self)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        // A4 size
        let pageSize = CGSize(width: 595.2, height: 841.8)
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
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
}
