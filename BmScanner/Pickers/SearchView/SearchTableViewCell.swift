//
//  SearchTableViewCell.swift
//  BmScanner
//
//  Created by Aung Ko Min on 26/4/21.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "SearchTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: SearchTableViewCell.reuseIdentifier)
        textLabel?.numberOfLines = 3
        textLabel?.font = UIFont.myanmarFont
        detailTextLabel?.textColor = UIColor.tertiaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ note: Note) {
        textLabel?.text = note.text
        detailTextLabel?.text = note.folder?.name
    }
}
