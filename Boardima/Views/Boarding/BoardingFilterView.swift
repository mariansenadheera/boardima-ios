import SwiftUI

struct BoardingFilterView: View {
    @Environment(BoardingListViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            Form {
                Section("Room type") {
                    Picker("Room type", selection: $model.selectedRoomType) {
                        Text("Any").tag(String?.none)
                        ForEach(model.roomTypes, id: \.self) { type in
                            Text(type).tag(String?.some(type))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Maximum rent: Rs. \(Int(model.maxRent))") {
                    Slider(value: $model.maxRent, in: 5000...50000, step: 1000)
                        .accessibilityLabel("Maximum monthly rent")
                }

                Section {
                    Button("Reset filters", role: .destructive) {
                        model.resetFilters()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
