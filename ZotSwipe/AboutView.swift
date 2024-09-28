//
//  AboutView.swift
//  ZotSwipe
//
//  Created by Han Wang on 26/09/2024.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Buy & Sell Swipes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                        .foregroundColor(.primary)
                    
                    Text("As requested by A LOT of users, you can now easily buy and sell swipes using ZotSwipe! Here's how it works.")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    StepView(number: 1, title: "Buyers Create a Listing", description: "People who are looking to buy swipes create listings where they specify when and where they would like to buy swipes, as well as how much they are looking to pay.")
                    
                    StepView(number: 2, title: "Sellers Contact the Buyer", description: "Sellers get notified of the listing or browse the market, and find the ones that are compatible with their schedule. They then get in touch with the buyers using the contact information provided in the listing.")
                    
                    StepView(number: 3, title: "Meet Up & Nom Nom", description: "Buyer & seller agree on when and where to meet to be swiped in, and voilà! 🍽️")
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color.blue
    }
}

struct StepView: View {
    let number: Int
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 30, height: 30)
                Text("\(number)")
                    .foregroundColor(numberColor)
                    .font(.headline)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }
    
    var circleColor: Color {
        colorScheme == .dark ? Color.blue : Color.white
    }
    
    var numberColor: Color {
        colorScheme == .dark ? Color.white : Color.blue
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutView()
                .preferredColorScheme(.light)
            AboutView()
                .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    AboutView()
}

