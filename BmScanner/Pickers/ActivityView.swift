//
//  ActivityView.swift
//  PictureSMS
//
//  Created by Aung Ko Min on 5/4/21.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let x = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return x
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}
