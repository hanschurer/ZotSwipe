import SwiftUI

struct DateSelectionButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(date, format: .dateTime.day())
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(isSelected ? .blue : .primary)
    }
}

struct ListingRow: View {
    let listing: SwipeListing
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(listing.swipes) Swipe\(listing.swipes > 1 ? "s" : "")")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", listing.pricePerSwipe))
                    .padding(4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text(formatDates(listing.dates))
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.green)
                Text(listing.meals.joined(separator: ", "))
            }
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                Text(listing.locations.joined(separator: ", "))
            }
            
            HStack {
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                Text("\(listing.buyer) • Listed \(listing.listedTime, style: .relative)")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
    private func formatDates(_ dates: [Date]) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return dates.map { formatter.string(from: $0) }.joined(separator: ", ")
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}