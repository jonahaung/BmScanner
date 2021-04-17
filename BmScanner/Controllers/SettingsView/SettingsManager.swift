//
//  SettingsManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 17/3/21.
//

import UIKit
import MessageUI
import StoreKit

final class SettingManager: NSObject {
    
    static let shared = SettingManager()
    
    func gotoPrivacyPolicy() {
        guard let url = URL(string: "https://photosms-1bc29.web.app") else {
            return //be safe
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

