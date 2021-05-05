//
//  TextView.swift
//  MyanScan
//
//  Created by Aung Ko Min on 18/2/21.
//

import SwiftUI
import UIKit

struct SUITextView: UIViewRepresentable {
    
    let textView: AutoCompleteTextView
    
    func makeUIView(context: Context) -> AutoCompleteTextView {
        return textView
    }
    
    func updateUIView(_ uiView: AutoCompleteTextView, context: Context) {

    }

}
