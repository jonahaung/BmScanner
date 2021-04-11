//
//  BmScannerApp.swift
//  BmScanner
//
//  Created by Aung Ko Min on 11/4/21.
//

import SwiftUI

@main
struct BmScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
