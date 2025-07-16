//
//  FinanceTrackerApp.swift
//  FinanceTracker
//
//  Created by MakhovN @nktmahov
//

import SwiftUI
import SwiftData

@main
struct FinanceTrackerApp: App {
    init() {
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents directory: \(documentsURL.path)")
        }
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
    
}
