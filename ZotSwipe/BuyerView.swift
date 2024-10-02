import SwiftUI
import FirebaseFirestore

struct BuyerView: View {
    @EnvironmentObject private var firebaseService: FirebaseService
    @State private var swipeAmount = 1
    @State private var pricePerSwipe = 10
    @State private var selectedDates: Set<Date> = []
    @State private var selectedMeals: Set<String> = []
    @State private var selectedLocations: Set<String> = []
    @State private var buyerName = ""
    @State private var contactInfo = ""
    @State private var note = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.colorScheme) var colorScheme

    let meals = ["Breakfast", "Lunch", "Dinner"]
    let locations = ["Anteatery", "Brandywine"]

    var isFormValid: Bool {
        swipeAmount > 0 &&
        pricePerSwipe > 0 &&
        !selectedDates.isEmpty &&
        !selectedMeals.isEmpty &&
        !selectedLocations.isEmpty &&
        !buyerName.isEmpty &&
        isValidPhoneNumber(contactInfo)
    }

    var body: some View {
        Form {
            Section(header: Text("Swipe Details")) {
                Stepper("Amount: \(swipeAmount)", value: $swipeAmount, in: 1...10)
                Stepper("Price per swipe: $\(pricePerSwipe)", value: $pricePerSwipe, in: 1...20)
            }

            Section(header: Text("Dates")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(getNextNDays(14), id: \.self) { date in
                            DateButton(date: date, isSelected: selectedDates.contains(date)) {
                                toggleDateSelection(date)
                            }
                        }
                    }
                }
            }

            Section(header: Text("Meals")) {
                ForEach(meals, id: \.self) { meal in
                    Button(action: {
                        toggleSelection(meal, in: &selectedMeals)
                    }) {
                        HStack {
                            Text(meal)
                            Spacer()
                            if selectedMeals.contains(meal) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section(header: Text("Locations")) {
                ForEach(locations, id: \.self) { location in
                    Button(action: {
                        toggleSelection(location, in: &selectedLocations)
                    }) {
                        HStack {
                            Text(location)
                            Spacer()
                            if selectedLocations.contains(location) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }

            Section(header: Text("Contact Information")) {
                TextField("Your Name", text: $buyerName)
                TextField("Phone Number", text: $contactInfo)
                    .keyboardType(.phonePad)
                    .onChange(of: contactInfo) { newValue in
                        contactInfo = formatPhoneNumber(newValue)
                    }
            }

            Section(header: Text("Note (Optional)")) {
                TextField("Add a note", text: $note)
            }

            Section {
                Button(action: submitForm) {
                    Text("Submit")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.blue.gradient : Color.gray.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: isFormValid ? .blue.opacity(0.3) : .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .disabled(!isFormValid)
                .animation(.easeInOut, value: isFormValid)
            }
            .listRowBackground(Color.clear)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func submitForm() {
        if isFormValid {
            let newListing = SwipeListing(
                swipes: swipeAmount,
                pricePerSwipe: Double(pricePerSwipe),
                dates: Array(selectedDates),
                meals: Array(selectedMeals),
                locations: Array(selectedLocations),
                buyer: buyerName,
                listedTime: Date(),
                contactInfo: contactInfo,
                note: note
            )
            Task {
                await firebaseService.addListing(newListing)
                await MainActor.run {
                    clearForm()
                    showAlert = true
                    alertMessage = "Listing created successfully!"
                }
            }
        } else {
            showAlert = true
            alertMessage = "Please fill in all required fields and ensure your phone number is valid."
        }
    }

    private func toggleSelection(_ item: String, in set: inout Set<String>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }

    private func toggleDateSelection(_ date: Date) {
        if selectedDates.contains(date) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }

    private func getNextNDays(_ n: Int) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<n).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }

    private func clearForm() {
        swipeAmount = 1
        pricePerSwipe = 10
        selectedDates.removeAll()
        selectedMeals.removeAll()
        selectedLocations.removeAll()
        buyerName = ""
        contactInfo = ""
        note = ""
    }

    private func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX-XXXX"
        var result = ""
        var index = cleaned.startIndex
        for ch in mask where index < cleaned.endIndex {
            if ch == "X" {
                result.append(cleaned[index])
                index = cleaned.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^\\(\\d{3}\\) \\d{3}-\\d{4}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }

    private func backgroundForButton() -> Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
}

struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(date, format: .dateTime.weekday(.abbreviated))
                    .font(.caption)
                Text(date, format: .dateTime.day())
                    .font(.title3)
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
        .foregroundColor(isSelected ? .blue : .primary)
    }
}