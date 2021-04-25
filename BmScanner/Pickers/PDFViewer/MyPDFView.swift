//
//  PDFViewerView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import SwiftUI
import PDFKit

struct MyPDFView: UIViewRepresentable {
    
    var data: NSMutableData?

    func makeUIView(context: UIViewRepresentableContext<MyPDFView>) -> MyPDFView.UIViewType {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<MyPDFView>) {
        if let data = data {
            uiView.document = PDFDocument(data: data as Data)
        }
    }
}
