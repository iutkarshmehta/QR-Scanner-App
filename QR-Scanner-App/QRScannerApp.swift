//
//  QR_Scanner_AppApp.swift
//  QR-Scanner-App
//
//  Created by Mehta, Utkarsh on 22/05/26.
//

import SwiftUI
import SwiftData

@main
struct QR_Scanner_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ScanRecord.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabbarView()
        }
        .modelContainer(sharedModelContainer)
    }
}
