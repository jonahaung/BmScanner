//
//  AttributedLabel.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import SwiftUI

struct AttributedLabelView: UIViewRepresentable {
    
    let attributedText: NSAttributedString?
    let numberOfLines: Int
    
    func makeUIView(context: UIViewRepresentableContext<AttributedLabelView>) -> UILabel {
        let x = UILabel()
        x.numberOfLines = numberOfLines
        x.lineBreakMode = .byWordWrapping
        x.allowsDefaultTighteningForTruncation = true
        x.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 100
        x.lineBreakMode = .byTruncatingTail
        x.attributedText = attributedText
        return x
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<AttributedLabelView>) {
        if let superView = uiView.superview {
            uiView.preferredMaxLayoutWidth = superView.intrinsicContentSize.width
        }
        uiView.attributedText = attributedText
    }
}
