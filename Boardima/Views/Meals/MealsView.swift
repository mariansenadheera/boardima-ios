import SwiftUI

struct MealsView: View {
    @Environment(MealsViewModel.self) private var viewModel
    @Environment(CartViewModel.self) private var cart
    @State private var showCart = false

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                AppHeader()

                ScrollView {
                    LazyVStack(spacing: 14) {
                        HStack {
                            Text("Meals").font(.title2.bold())
                            Spacer()
                            cartButton
                        }

                        SearchField(prompt: "Search meals or vendors", text: $model.searchText)

                        Picker("Category", selection: $model.selectedCategory) {
                            Text("All").tag(String?.none)
                            ForEach(model.categories, id: \.self) { category in
                                Text(category).tag(String?.some(category))
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(8)
                        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))

                        ForEach(model.filtered) { meal in
                            MealRow(meal: meal)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom)
                }
                .scrollDismissesKeyboard(.interactively)
                .refreshable { await model.load(force: true) }
                .overlay {
                    if model.isLoading {
                        ProgressView()
                    } else if model.filtered.isEmpty {
                        ContentUnavailableView("No meals found", systemImage: "fork.knife",
                                               description: Text("Try a different search or category."))
                    }
                }
            }
            .background(Theme.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCart) { CartView() }
            .task { await model.load() }
        }
    }

    private var cartButton: some View {
        Button {
            showCart = true
        } label: {
            CircleIcon(symbol: "cart")
                .overlay(alignment: .topTrailing) {
                    if cart.itemCount > 0 {
                        Text("\(cart.itemCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .frame(minWidth: 18)
                            .background(Color.red, in: Capsule())
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .accessibilityLabel("Cart, \(cart.itemCount) items")
    }
}
