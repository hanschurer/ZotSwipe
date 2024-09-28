//
//  ZotSwipeApp.swift
//  ZotSwipe
//
//  Created by Han Wang on 25/09/2024.
//

import SwiftUI
import Firebase

@main
struct ZotSwipeApp: App {
    @StateObject private var firebaseService = FirebaseService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseService)
                .task {
                    await loadInitialData()
                }
        }
    }

    private func loadInitialData() async {
        await firebaseService.fetchListings()
    }
}
