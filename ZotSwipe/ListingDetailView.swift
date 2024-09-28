import SwiftUI

struct ListingDetailView: View {
    let listing: SwipeListing
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var showingContactAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(listing.swipes) Swipe\(listing.swipes > 1 ? "s" : "")")
                            .font(.system(size: 28, weight: .bold))
                        Text("$\(String(format: "%.2f", listing.pricePerSwipe)) per swipe")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("$\(String(format: "%.2f", Double(listing.swipes) * listing.pricePerSwipe))")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Details
                VStack(alignment: .leading, spacing: 15) {
                    detailRow(icon: "calendar", title: "Dates", value: formatDates(listing.dates))
                    detailRow(icon: "clock", title: "Meals", value: listing.meals.joined(separator: ", "))
                    detailRow(icon: "mappin.and.ellipse", title: "Locations", value: listing.locations.joined(separator: ", "))
                    detailRow(icon: "person.circle", title: "Buyer", value: listing.buyer)
                    detailRow(icon: "clock.arrow.circlepath", title: "Listed", value: formatListedTime(listing.listedTime))
                    if !listing.note.isEmpty {
                        detailRow(icon: "note.text", title: "Note", value: listing.note)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Contact Button
                Button(action: {
                    contactBuyer()
                }) {
                    Text("Contact Buyer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitle("Listing Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        })
        .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color.gray.opacity(0.1))
    }
    
    private func contactBuyer() {
        let phoneNumber = listing.contactInfo.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        let message = "Hi, I saw your listing of buying swipes on ZotSwipe."
        let urlString = "sms:\(phoneNumber)&body=\(message)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            showingContactAlert = true
        }
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        DetailRow(icon: icon, title: title, value: value)
    }
    
    private func formatDates(_ dates: [Date]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return dates.map { formatter.string(from: $0) }.joined(separator: ", ")
    }
    
    private func formatListedTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
