//
//  SettingsManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import UIKit
import StoreKit

final class SettingManager: ObservableObject {
    
    enum SheetType: Identifiable {
        var id: SheetType { return self }
        case eulaView, onboardingView, mailCompose, activityView, instructionsView, folderPicker
    }
    @Published var sheetType: SheetType?
    @Published var currentFolderName = Folder.getCurrentFolder()?.name ?? "General Folder"

    func gotoPrivacyPolicy() {
        UIApplication.shared.open(AppInfo.privacyURL, options: [:], completionHandler: nil)
    }
    
    func rateApp() {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                if let windowScene = scene as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                break
            }
        }
    }
    
    func gotoDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:]) { _ in
                
            }
        }
    }
}

