//
//  SettingCell.swift
//  MyanScan
//
//  Created by Aung Ko Min on 3/3/21.
//

import SwiftUI

struct SettingCell: View {
    
    let text: String
    let subtitle: String?
    let imageName: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(.accentColor)
            Text(text)
            if let x = subtitle {
                Spacer()
                Text(x)
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}
