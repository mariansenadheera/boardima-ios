import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Nearby boardings") {
                    ForEach(Boarding.samples) { boarding in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(boarding.title).font(.headline)
                            Text("Rs. \(boarding.monthlyRent)/month · \(boarding.distanceToUniversityKm, specifier: "%.1f") km")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Popular meals") {
                    ForEach(Meal.samples) { meal in
                        HStack {
                            Text(meal.name)
                            Spacer()
                            Text("Rs. \(meal.price)").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Boardima")
        }
    }
}

#Preview { DashboardView() }
