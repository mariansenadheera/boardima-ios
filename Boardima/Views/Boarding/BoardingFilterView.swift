import SwiftUI

struct BoardingFilterView: View {
    @Environment(BoardingListViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    private let rentPresets = [10000, 15000, 20000, 30000]

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    section("Room type") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(title: "Any", isSelected: model.selectedRoomType == nil) {
                                    model.selectedRoomType = nil
                                }
                                ForEach(model.roomTypes, id: \.self) { type in
                                    FilterChip(title: type, isSelected: model.selectedRoomType == type) {
                                        model.selectedRoomType = type
                                    }
                                }
                            }
                        }
                    }

                    section("Maximum rent") {
                        Text("Up to Rs. \(Int(model.maxRent).formatted()) / month")
                            .font(.title3.bold())
                        Slider(value: $model.maxRent, in: 5000...50000, step: 1000)
                            .tint(Theme.navy)
                            .accessibilityLabel("Maximum monthly rent")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(rentPresets, id: \.self) { preset in
                                    FilterChip(title: "< Rs. \((preset / 1000))k",
                                               isSelected: Int(model.maxRent) == preset) {
                                        model.maxRent = Double(preset)
                                    }
                                }
                                FilterChip(title: "Any", isSelected: model.maxRent >= 50000) {
                                    model.maxRent = 50000
                                }
                            }
                        }
                    }

                    section("Sort") {
                        Toggle(isOn: $model.sortByMatch) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Best match first").font(.body.weight(.medium))
                                Text("Uses your budget and room type in Profile.")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(Theme.navy)
                        .cardStyle()
                    }
                }
                .padding()
            }
            .background(Theme.background)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Reset") { model.resetFilters() }
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
                    Button {
                        dismiss()
                    } label: {
                        Text("Show \(model.filtered.count) boardings")
                    }
                    .buttonStyle(BrandButtonStyle())
                }
                .padding()
                .background(.regularMaterial)
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

    private func section<Content: View>(_ title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }
}
