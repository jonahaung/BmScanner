//
//  MailComposeView.swift
//  PictureSMS
//
//  Created by Aung Ko Min on 5/4/21.
//

import SwiftUI
import MessageUI

struct MailComposeView: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailComposeView>) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setSubject("\(AppInfo.appName): Feedback")
        mail.setToRecipients(["jonahaung@gmail.com"])
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailComposeView>) {}
}


extension MailComposeView {
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        private let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                switch result {
                case .sent:
                    AlertPresenter.show(title: "Thank you for contacting us. I will get back to you soon. Have a nice day.\nAung Ko Min")
                case .failed:
                    AlertPresenter.show(title: "Failed to send Mail")
                default:
                    break
                }
            }
        }
    }
}
