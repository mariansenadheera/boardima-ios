import SwiftUI

struct MealsView: View {
    @Environment(MealsViewModel.self) private var viewModel
    @Environment(CartViewModel.self) private var cart
    @State private var showCart = false

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            List {
                Section {
                    Picker("Category", selection: $model.selectedCategory) {
                        Text("All").tag(String?.none)
                        ForEach(model.categories, id: \.self) { category in
                            Text(category).tag(String?.some(category))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    ForEach(model.filtered) { meal in
                        MealRow(meal: meal)
                    }
                }
            }
            .overlay {
                if model.isLoading {
                    ProgressView()
                } else if model.filtered.isEmpty {
                    ContentUnavailableView("No meals found", systemImage: "fork.knife",
                                           description: Text("Try a different search or category."))
                }
            }
            .navigationTitle("Meals")
            .searchable(text: $model.searchText, prompt: "Search meals or vendors")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCart = true
                    } label: {
                        Image(systemName: "cart")
                            .overlay(alignment: .topTrailing) {
                                if cart.itemCount > 0 {
                                    Text("\(cart.itemCount)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(.red, in: Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                    }
                    .accessibilityLabel("Cart, \(cart.itemCount) items")
                }
            }
            .sheet(isPresented: $showCart) { CartView() }
            .refreshable { await model.load(force: true) }
            .task { await model.load() }
        }
    }
}
