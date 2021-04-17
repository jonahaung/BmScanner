//
//  BmScannerApp.swift
//  BmScanner
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

@main
struct BmScannerApp: App {
    
    @AppStorage(UserDefaultManager.shared._appFontDesign) private var appFontDesign: Int = UserDefaultManager.shared.appFontDesign.rawValue
    @AppStorage(UserDefaultManager.shared._appFontSize) private var appFontSize: Double = UserDefaultManager.shared.appFontSize
    @AppStorage(UserDefaultManager.shared._appTintColor) private var appTintColor: Int = UserDefaultManager.shared.appTintColor.rawValue
    @AppStorage(UserDefaultManager.shared._hasShownOnboarding) private var hasShownOnboarding: Bool = UserDefaultManager.shared.hasShownOnboarding
    @Environment(\.scenePhase) private var scenePhase
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                if hasShownOnboarding {
                    HomeView()
                }else {
                    OnboardingView(isFirstTime: true)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .font(.system(size: CGFloat(appFontSize), design: AppFontDesign(rawValue: appFontDesign)!.design))
            .accentColor(AppTintColor(rawValue: appTintColor)?.color)
            
        }
        .onChange(of: scenePhase, perform: handleScenePhase(_:))
    }
    
    init() {
        let toolbar = UIToolbar.appearance()
        toolbar.isTranslucent = false
    }
}

extension BmScannerApp {
    private func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            print("active")
        case .inactive:
            persistenceController.save()
        case .background:
            print("background")
        @unknown default:
            print("unknown")
        }
    }
}
