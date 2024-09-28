//
//  MarketplaceView.swift
//  ZotSwipe
//
//  Created by Han Wang on 26/09/2024.
//

import SwiftUI
import FirebaseFirestore
import MessageUI

struct MarketplaceView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var firebaseService: FirebaseService
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top title and tabs
                VStack {
                    Text("Buy & Sell Swipes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Picker("", selection: $selectedTab) {
                        Text("For Buyers").tag(0)
                        Text("For Sellers").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                
                if selectedTab == 0 {
                    BuyerView()
                } else {
                    SellerView()
                }
            }
            .navigationBarItems(trailing: Image(systemName: "bell"))
            .navigationBarHidden(true)
        }
    }
}

struct MarketplaceView_Previews: PreviewProvider {
    static var previews: some View {
        MarketplaceView()
            .environmentObject(FirebaseService())
    }
}

