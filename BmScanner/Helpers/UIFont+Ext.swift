//
//  UIFont+Ext.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 4/12/20.
//

import UIKit

extension UIFont {
    static let myanmarFont = UIFont(name:"MyanmarSansPro", size: 0)!
    static let engFont = UIFont.preferredCustomFont(family: "Times New Roman", weight: .regular)
    static let myanmarNoto = UIFont.preferredCustomFont(family: "Noto Sans Myanmar", weight: .regular)
}


extension UIFont {
    static func preferredCustomFont(family: String, weight: Weight) -> UIFont {
        let size = UIFont.labelFontSize
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
        let fontDescriptor = UIFontDescriptor(fontAttributes: [.size: size, .family: family, .traits: traits])
        return UIFont(descriptor: fontDescriptor, size: 0)
    }
}
