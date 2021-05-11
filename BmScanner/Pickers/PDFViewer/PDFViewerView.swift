//
//  PDFViewerView.swift
//  BmScanner
//
//  Created by Aung Ko Min on 16/4/21.
//

import SwiftUI
import PDFKit

struct PDFViewerView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    @State private var showActivityView = false
    let url: URL
    
    var body: some View {
        NavigationView {
            MyPDFView(pdfDocument: PDFDocument(url: url))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: NavigationItemLeading, trailing: NavigationItemTrailing)
                .sheet(isPresented: $showActivityView, content: {
                    ActivityView(activityItems: [url])
                })
        }
    }
    
    private var NavigationItemTrailing: some View {
        return HStack {
            Button {
                showActivityView.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    private var NavigationItemLeading: some View {
        return HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Close")
            }
        }
    }
}


