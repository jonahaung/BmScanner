//
//  AttributedLabel.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import SwiftUI

struct AttributedLabelView: UIViewRepresentable {
    
    let attributedText: NSAttributedString?

    func makeUIView(context: UIViewRepresentableContext<AttributedLabelView>) -> UILabel {
        let x = UILabel()
        x.numberOfLines = 4
        x.lineBreakMode = .byWordWrapping
        x.allowsDefaultTighteningForTruncation = true
        x.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 100
        x.attributedText = attributedText
        return x
    }

    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<AttributedLabelView>) {
        uiView.attributedText = attributedText
    }
}
