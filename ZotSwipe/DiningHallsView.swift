//
//  DiningHallsView.swift
//  ZotSwipe
//
//  Created by Han Wang on 26/09/2024.
//

import SwiftUI

struct DiningHallsView: View {
    let diningHalls = ["anteatery", "brandywine"]
    @StateObject private var viewModel = RestaurantViewModel()
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Dining Hall Data...")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(diningHalls, id: \.self) { hall in
                                RestaurantCard(location: hall, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dining Halls")
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        await viewModel.fetchAllMenus()
        isLoading = false
    }
}

struct RestaurantCard: View {
    let location: String
    @ObservedObject var viewModel: RestaurantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(location.capitalized)
                .font(.title)
                .fontWeight(.bold)
            
            if viewModel.isLoading[location] == true {
                ProgressView()
            } else if let restaurant = viewModel.restaurants[location] {
                RestaurantContent(restaurant: restaurant)
            } else if let error = viewModel.errors[location] {
                ErrorView(error: error)
            } else {
                Text("No data available")
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

struct RestaurantContent: View {
    let restaurant: Restaurant
    @State private var expandedStations: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CurrentMealSection(restaurant: restaurant)
            
            ForEach(restaurant.all, id: \.station) { station in
                StationSection(station: station, isExpanded: expandedStations.contains(station.station)) {
                    if expandedStations.contains(station.station) {
                        expandedStations.remove(station.station)
                    } else {
                        expandedStations.insert(station.station)
                    }
                }
            }
        }
    }
}

struct CurrentMealSection: View {
    let restaurant: Restaurant
    
    var body: some View {
        Section(header: Text("Current Meal").font(.headline)) {
            Text("Meal: \(restaurant.currentMeal.capitalized)")
            Text("Date: \(restaurant.date)")
            Text("Price: $\(restaurant.price[restaurant.currentMeal] ?? 0.0, specifier: "%.2f")")
        }
    }
}

struct StationSection: View {
    let station: Station
    let isExpanded: Bool
    let toggleExpansion: () -> Void
    
    var body: some View {
        Section(header: 
            Button(action: toggleExpansion) {
                HStack {
                    Text(station.station).font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
        ) {
            if isExpanded {
                ForEach(station.menu, id: \.category) { menu in
                    MenuView(menu: menu)
                }
            }
        }
    }
}

struct MenuView: View {
    let menu: Menu
    
    var body: some View {
        ForEach(menu.items) { meal in
            MealRow(meal: meal)
        }
    }
}

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meal.name)
                .font(.headline)
            Text(meal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let calories = meal.nutrition?.calories {
                Text("Calories: \(calories)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        Text("Error: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [String: Restaurant] = [:]
    @Published var isLoading: [String: Bool] = [:]
    @Published var errors: [String: Error] = [:]
    @Published var activeError: Error?
    
    private let diningHalls = ["anteatery", "brandywine"]
    
    var isAnyLocationLoading: Bool {
        isLoading.values.contains(true)
    }
    
    func fetchAllMenus() async {
        for hall in diningHalls {
            await fetchMenu(for: hall)
        }
    }
    
    private func fetchMenu(for location: String) async {
        await MainActor.run { isLoading[location] = true }
        defer { Task { await MainActor.run { isLoading[location] = false } } }
        
        guard let url = URL(string: "https://zotmeal-backend.vercel.app/api?location=\(location)") else {
            await MainActor.run {
                self.errors[location] = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                self.activeError = self.errors[location]
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let restaurant = try JSONDecoder().decode(Restaurant.self, from: data)
            await MainActor.run {
                self.restaurants[location] = restaurant
            }
        } catch {
            await MainActor.run {
                self.errors[location] = error
                self.activeError = error
            }
        }
    }
}

struct Restaurant: Codable {
    let all: [Station]
    let currentMeal: String
    let date: String
    let price: [String: Double]
    let restaurant: String
    let schedule: [String: MealTime]
}

struct Station: Codable, Identifiable {
    let id = UUID()
    let menu: [Menu]
    let station: String
}

struct Menu: Codable, Identifiable {
    let id = UUID()
    let category: String
    let items: [Meal]
}

struct Meal: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let nutrition: Nutrition?
}

struct Nutrition: Codable {
    let calories: String?
    let protein: String?
}

struct MealTime: Codable {
    let start: Int
    let end: Int
}

#Preview {
    DiningHallsView()
}