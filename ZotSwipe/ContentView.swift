//
//  ContentView.swift
//  ZotSwipe
//
//  Created by Han Wang on 25/09/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1
    @EnvironmentObject private var firebaseService: FirebaseService

    var body: some View {
        TabView(selection: $selectedTab) {
            DiningHallsView()
                .tabItem {
                    Label("Dining Halls", systemImage: "fork.knife")
                }
                .tag(0)
            
            MarketplaceView()
                .tabItem {
                    Label("Swipe Market", systemImage: "cart")
                }
                .tag(1)
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirebaseService())
    }
}
