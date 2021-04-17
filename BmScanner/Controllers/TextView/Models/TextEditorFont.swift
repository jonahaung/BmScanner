//
//  TextEditorFont.swift
//  BmScanner
//
//  Created by Aung Ko Min on 17/4/21.
//

import UIKit

enum TextEditorFont: CaseIterable, Identifiable {
    var id: TextEditorFont { return self }
    
    case Regular, Bold, Light
    
    var name: String {
        switch self {
        case .Regular:
            return "Regular"
        case .Bold:
            return "Bold"
        case .Light:
            return "Light"
        }
    }
    
    func font(for pointSize: CGFloat, isMyanmar: Bool) -> UIFont {
        switch self {
        case .Regular:
            return isMyanmar ? UIFont(name: "NotoSansMyanmar-Regular", size: pointSize)! : UIFont.preferredFont(forTextStyle: .body)
        case .Bold:
            return isMyanmar ? UIFont(name: "NotoSansMyanmar-Bold", size: pointSize)! : UIFont.preferredFont(forTextStyle: .headline)
        case .Light:
            return isMyanmar ? UIFont(name: "NotoSansMyanmar-Light", size: pointSize)! : UIFont.preferredFont(forTextStyle: .callout)
        }
    }
}
