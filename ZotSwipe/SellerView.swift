import SwiftUI

struct SellerView: View {
    @EnvironmentObject private var firebaseService: FirebaseService
    @State private var selectedListing: SwipeListing?
    @Environment(\.colorScheme) var colorScheme
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            Group {
                if firebaseService.isLoading {
                    ProgressView("Loading listings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if firebaseService.listings.isEmpty {
                    Text("No listings available")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(firebaseService.listings) { listing in
                                ListingRow(listing: listing)
                                    .onTapGesture {
                                        selectedListing = listing
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.gray.opacity(0.1))
            .navigationTitle("Sell Swipes")
            .refreshable {
                await refreshListings()
            }
        }
        .sheet(item: $selectedListing) { listing in
            NavigationView {
                ListingDetailView(listing: listing)
            }
        }
        .task {
            if firebaseService.listings.isEmpty {
                await firebaseService.fetchListings()
            }
        }
    }
    
    private func refreshListings() async {
        isRefreshing = true
        await firebaseService.fetchListings()
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay for better UX
        isRefreshing = false
    }
}