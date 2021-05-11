//
//  PaddingLabel.swift
//  BmScanner
//
//  Created by Aung Ko Min on 10/5/21.
//

import UIKit

class PaddingLabel: UIView {
    
    var text: String? {
        get {
            return label.text
        }
        set {
            isHidden = true
            label.text = newValue
            layoutSubviews()
        
        }
    }
    let inset = UIEdgeInsets(top: 3, left: 9, bottom: 3, right: 9)
    
    private let label: UILabel = {
        $0.font = UIFont(name:"MyanmarSansPro", size: 13)
        $0.textColor = UIColor.white
        $0.preferredMaxLayoutWidth = 300
        return $0
    }(UILabel())
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.5, alpha: 0.9)
        addSubview(label)
        
        layer.cornerRadius = 7
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        label.frame = bounds.inset(by: inset)
        let labelSize = label.intrinsicContentSize
        frame.size = CGSize(width: labelSize.width + inset.left + inset.right, height: labelSize.height + inset.top + inset.bottom)
        isHidden = text == nil
    }
}
