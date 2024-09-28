import Foundation
import FirebaseFirestore

class FirebaseService: ObservableObject {
    @Published var listings: [SwipeListing] = []
    @Published var isLoading = false
    private var db = Firestore.firestore()
    
    @MainActor
    func fetchListings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("listings")
                .order(by: "listedTime", descending: true)
                .limit(to: 20) // 限制初始加载的数量
                .getDocuments()
            listings = snapshot.documents.compactMap { try? $0.data(as: SwipeListing.self) }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func addListing(_ listing: SwipeListing) async {
        do {
            let _ = try await db.collection("listings").addDocument(from: listing)
            await fetchListings()
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
