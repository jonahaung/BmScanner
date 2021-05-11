//
//  PDFViewerView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import SwiftUI
import PDFKit

struct MyPDFView: UIViewRepresentable {
    
    let pdfDocument: PDFDocument?

    func makeUIView(context: UIViewRepresentableContext<MyPDFView>) -> MyPDFView.UIViewType {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.document = pdfDocument
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<MyPDFView>) {
//        uiView.document = pdfDocument
    }
}
