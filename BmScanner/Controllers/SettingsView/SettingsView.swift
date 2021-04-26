//
//  SettingsView.swift
//  PictureSMS
//
//  Created by Aung Ko Min on 3/4/21.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(UserDefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserDefaultManager.shared.hasShownOnboarding
    @AppStorage(UserDefaultManager.shared._appFontDesign) private var appFontDesignIndex: Int = UserDefaultManager.shared.appFontDesign.rawValue
    @AppStorage(UserDefaultManager.shared._appFontSize) private var appFontSize: Double = UserDefaultManager.shared.appFontSize
    @AppStorage(UserDefaultManager.shared._appTintColor) private var appTintColorIndex: Int = UserDefaultManager.shared.appTintColor.rawValue
    @AppStorage(UserDefaultManager.shared._languageMode) private var languageModeIndex: Int = UserDefaultManager.shared.lanaguageMode.rawValue
    @StateObject private var manager = SettingManager()
    

    var body: some View {
        Form {
            Section(header: Text("App").foregroundColor(Color(.tertiaryLabel))) {
                Button {
                    manager.sheetType = .folderPicker
                } label: {
                    SettingCell(text: "Default Folder", subtitle: manager.currentFolderName, imageName: "folder")
                }
                Picker(selection: $languageModeIndex, label: Text("Language")) {
                    ForEach(LanguageMode.allCases) {
                        Label($0.description, systemImage: "circlebadge")
                            .tag($0.rawValue)
                    }
                }
            }
            
            Section(header: Text("Device Settings").foregroundColor(Color(.tertiaryLabel))) {
                
                Picker(selection: $appFontDesignIndex, label: Text("Font Design")) {
                    ForEach(AppFontDesign.allCases) {
                        Label($0.name, systemImage: "circlebadge")
                            .tag($0.rawValue)
                            .font(.system(size: CGFloat(appFontSize), design: $0.design))
                    }
                }
                
                HStack {
                    Text("Font Size")
                    Slider(value: $appFontSize, in: 14...30)
                }
                
                Picker(selection: $appTintColorIndex, label: Text("App Color")) {
                    ForEach(AppTintColor.allCases) {
                        Label($0.name, systemImage: "circle.fill")
                            .tag($0.rawValue)
                            .foregroundColor($0.color)
                    }
                }
                
                Button(action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }) {
                    Text("Open Device Settings")
                }
            }
            
            Section(header: Text("App Settings").foregroundColor(Color(.tertiaryLabel))) {
                SettingCell(text: "App Version", subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, imageName: "app.badge")
                    .foregroundColor(.secondary)
                Button(action: {
                    manager.sheetType = .onboardingView
                }) {
                    SettingCell(text: "App Walkthrough", subtitle: nil, imageName: "greetingcard")
                }
                Button(action: {
                    manager.sheetType = .instructionsView
                }) {
                    SettingCell(text: "Guide", subtitle: "video", imageName: "megaphone")
                }
                Button(action: {
                    manager.sheetType = .eulaView
                }) {
                    SettingCell(text: "User License Agreement", subtitle: nil, imageName: "scroll")
                }
                Button(action: {
                    manager.gotoPrivacyPolicy()
                }) {
                    SettingCell(text: "Privacy Policy Website", subtitle: nil, imageName: "exclamationmark.shield")
                }
            }
            
            Section(header: Text("App Informations").foregroundColor(Color(.tertiaryLabel))) {
                
                Button(action: {
                    manager.sheetType = .activityView
                }) {
                    SettingCell(text: "Share App", subtitle: nil, imageName: "app.gift")
                }
                Button(action: {
                    manager.rateApp()
                }) {
                    SettingCell(text: "Rate on AppStore", subtitle: nil, imageName: "line.horizontal.star.fill.line.horizontal")
                }
            }
            
            Section(header: Text("Contacts").foregroundColor(Color(.tertiaryLabel)), footer: Text("Aung Ko Min (iOS Developer)\nSingapore\n+65 88585229\njonahaung@gmail.com").foregroundColor(.secondary).padding()) {
                Button(action: {
                    manager.sheetType = .mailCompose
                }) {
                    SettingCell(text: "Contact Us", subtitle: nil, imageName: "mail")
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .navigationTitle("Settings")
        .sheet(item: $manager.sheetType) { type in getSheet(type) }
    }
}

extension SettingsView {
    
    private func getSheet(_ type: SettingManager.SheetType) -> some View {
        return Group {
            switch type {
            case .eulaView:
                EULAView(showAgreementButton: false)
            case .onboardingView:
                OnboardingView(isFirstTime: false)
            case .mailCompose:
                MailComposeView()
            case .activityView:
                ActivityView(activityItems: [AppInfo.appURL])
            case .instructionsView:
                InstructionsView()
            case .folderPicker:
                FolderPicker { folder in
                    UserDefaultManager.shared.currentFolderId = folder?.id
                    manager.currentFolderName = folder?.name ?? "General Folder"
                }
            }
        }
    }
}
