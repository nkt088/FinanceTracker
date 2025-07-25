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
    @State private var showMain = false

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
            ZStack {
                if showMain {
                    RootView()
                } else {
                    LaunchAnimationView {
                        withAnimation {
                            showMain = true
                        }
                    }
                    .ignoresSafeArea()
                    .background(Color.white)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
