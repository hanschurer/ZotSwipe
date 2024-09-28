import SwiftUI
import FirebaseFirestore

struct SwipeListing: Identifiable, Codable {
    @DocumentID var id: String?
    let swipes: Int
    let pricePerSwipe: Double
    let dates: [Date]
    let meals: [String]
    let locations: [String]
    let buyer: String
    let listedTime: Date
    let contactInfo: String
    let note: String
}