//
//  UserDefaultManager.swift
//  Starter SwiftUI
//
//  Created by Aung Ko Min on 11/4/21.
//

import Foundation
import SwiftUI

final class UserDefaultManager {
    
    static let shared = UserDefaultManager()
    private let manager = UserDefaults.standard
    
    let _hasShownOnboarding = "hasShownOnboarding"
    let _appFontDesign = "appFontDesign"
    let _appFontSize = "_appFontSize"
    
    let _appTintColor = "appTintColor"
    let _doneSetup = "doneSetup"
    let _languageMode = "languageMode"
    let _isAdaptiveFontSize = "_isAdaptiveFontSize"
    private let _currentFolderId = "_currentFolderId"
    
    
    var hasShownOnboarding: Bool {
        get { return manager.bool(forKey: _hasShownOnboarding) }
        set { manager.setValue(newValue, forKey: _hasShownOnboarding) }
    }
    
    var doneSetup: Bool {
        get { return manager.bool(forKey: _doneSetup) }
        set { manager.setValue(newValue, forKey: _doneSetup) }
    }
    
    var appFontDesign: AppFontDesign {
        get {
            return AppFontDesign(rawValue: manager.integer(forKey: _appFontDesign)) ?? .rounded
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _appFontDesign)
        }
    }
    
    var appFontSize: Double {
        get {
            var size = manager.double(forKey: _appFontSize)
            if size == 0 {
                size = Double(UIFont.buttonFontSize)
                manager.setValue(size, forKey: _appFontSize)
            }
            return size
        }
        set {
            manager.setValue(newValue, forKey: _appFontSize)
        }
    }
    
    func font() -> Font {
        return .system(size: CGFloat(appFontSize), design: appFontDesign.design)
    }
    
    var appTintColor: AppTintColor {
        get {
            return AppTintColor(rawValue: manager.integer(forKey: _appTintColor)) ?? .Blue
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _appTintColor)
        }
    }
    
    var lanaguageMode: LanguageMode {
        get {
            return LanguageMode(rawValue: manager.integer(forKey: _languageMode)) ?? .Mixed
        }
        set {
            manager.setValue(newValue.rawValue, forKey: _languageMode)
        }
    }
    
    var currentFolderId: String? {
        get {
            return manager.string(forKey: _currentFolderId)
        }
        set {
            manager.setValue(newValue, forKey: _currentFolderId)
        }
    }
}
