//
//  UIFont+Ext.swift
//  MyTextGrabber
//
//  Created by Aung Ko Min on 4/12/20.
//

import UIKit

extension UIFont {
    static let myanmarFont = UIFont(name:"MyanmarSansPro", size: 0)!
    static let engFont = UIFont.preferredCustomFont(forTextStyle: .body, family: "Times", weight: .regular)
    static let myanmarNoto = UIFont.preferredCustomFont(forTextStyle: .body, family: "Noto Sans Myanmar", weight: .regular)
}


extension UIFont {
    static func preferredCustomFont(forTextStyle textStyle: TextStyle, family: String, weight: Weight) -> UIFont {
    
        let size = UIFont.labelFontSize
        
        let fontDescriptor = UIFontDescriptor(fontAttributes: [.size: size, .family: family, UIFontDescriptor.AttributeName.traits: [
            UIFontDescriptor.TraitKey.weight: weight
        ]])
        return UIFont(descriptor: fontDescriptor, size: 0)
    }
    
    func setWeight(weight: Weight) -> UIFont {
        let newFontDescriptor = UIFontDescriptor(fontAttributes: [.size: self.pointSize, .family: self.familyName, UIFontDescriptor.AttributeName.traits: [
            UIFontDescriptor.TraitKey.weight: weight
        ]])
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}
