//
//  TextView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 18/2/21.
//

import SwiftUI
import UIKit

struct SUITextView: UIViewRepresentable {
    
    @StateObject var manager: TextEditorManger
    
    func makeUIView(context: Context) -> AutoCompleteTextView {
        let x = manager.textView
        return x
    }
    
    func updateUIView(_ uiView: AutoCompleteTextView, context: Context) {

    }

}
