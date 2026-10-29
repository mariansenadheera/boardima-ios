import Testing
import CoreLocation
import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins
@testable import Boardima

// MARK: - Mocks

private enum MockError: Error { case failed }

@MainActor
private struct MockOrderRepository: OrderRepositoryProtocol {
    var shouldFail = false
    func place(_ order: Order) async throws {
        if shouldFail { throw MockError.failed }
    }
}

@MainActor
private struct MockBoardingRepository: BoardingRepositoryProtocol {
    func fetchBoardings() async throws -> [Boarding] { Boarding.samples }
}

@MainActor
private struct MockAuthService: AuthServiceProtocol {
    var shouldFail = false
    var currentUserID: String? { nil }
    var currentEmail: String? { "test@example.com" }

    func signUp(fullName: String, university: String, email: String, password: String) async throws {
        if shouldFail { throw AuthFailure(message: "An account with this email already exists.") }
    }
    func signIn(email: String, password: String) async throws {
        if shouldFail { throw AuthFailure(message: "Incorrect email or password.") }
    }
    func signOut() throws {}
    func fetchFullName() async -> String? { "Test Student" }
}

// MARK: - Cart

@MainActor
struct CartViewModelTests {
    private func makeCart() -> CartViewModel {
        CartViewModel(repository: MockOrderRepository())
    }

    @Test func addingSameMealTwiceIncreasesQuantity() {
        let cart = makeCart()
        let meal = Meal.samples[0]
        cart.add(meal)
        cart.add(meal)
        #expect(cart.quantity(of: meal) == 2)
        #expect(cart.lines.count == 1)
    }

    @Test func removingLastItemRemovesTheLine() {
        let cart = makeCart()
        let meal = Meal.samples[0]
        cart.add(meal)
        cart.remove(meal)
        #expect(cart.lines.isEmpty)
    }

    @Test func totalIsSumOfLineTotals() {
        let cart = makeCart()
        let first = Meal.samples[0]
        let second = Meal.samples[1]
        cart.add(first)
        cart.add(first)
        cart.add(second)
        #expect(cart.total == first.price * 2 + second.price)
        #expect(cart.itemCount == 3)
    }

    @Test func orderWithoutAddressIsRejected() async {
        let cart = makeCart()
        cart.add(Meal.samples[0])
        let order = await cart.placeOrder(address: "  ", phone: "0771234567", note: "")
        #expect(order == nil)
        #expect(cart.errorMessage == "Please enter a delivery address.")
    }

    @Test func orderWithShortPhoneIsRejected() async {
        let cart = makeCart()
        cart.add(Meal.samples[0])
        let order = await cart.placeOrder(address: "12 Lake Road", phone: "077", note: "")
        #expect(order == nil)
    }

    @Test func validOrderIsPlaced() async {
        let cart = makeCart()
        cart.add(Meal.samples[0])
        let order = await cart.placeOrder(address: "12 Lake Road", phone: "0771234567", note: "No chilli")
        #expect(order != nil)
        #expect(order?.total == Meal.samples[0].price)
    }
}

// MARK: - Boarding search and filters

@MainActor
struct BoardingListViewModelTests {
    private func makeLoadedViewModel() async -> BoardingListViewModel {
        let viewModel = BoardingListViewModel(repository: MockBoardingRepository(),
                                              campusStore: CampusStore(selected: .moratuwa))
        await viewModel.load()
        return viewModel
    }

    @Test func loadsAllBoardings() async {
        let viewModel = await makeLoadedViewModel()
        #expect(viewModel.boardings.count == Boarding.samples.count)
    }

    @Test func searchMatchesTitleOrAddress() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.searchText = "katubedda"
        #expect(viewModel.filtered.count == 2)
    }

    @Test func rentFilterHidesExpensiveBoardings() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.maxRent = 10000
        #expect(viewModel.filtered.allSatisfy { $0.monthlyRent <= 10000 })
        #expect(viewModel.filtered.count == 2)
    }

    @Test func roomTypeFilterWorks() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.selectedRoomType = "Single"
        #expect(viewModel.filtered.allSatisfy { $0.roomType == "Single" })
        #expect(viewModel.filtered.count == 2)
    }

    @Test func resultsAreSortedByDistance() async {
        let viewModel = await makeLoadedViewModel()
        let distances = viewModel.filtered.map(\.distanceToUniversityKm)
        #expect(distances == distances.sorted())
    }

    @Test func resetClearsFilters() async {
        let viewModel = await makeLoadedViewModel()
        viewModel.selectedRoomType = "Single"
        viewModel.maxRent = 8000
        viewModel.resetFilters()
        #expect(viewModel.hasActiveFilters == false)
    }
    @Test func distancesFollowTheSelectedCampus() async {
        let store = CampusStore(selected: .moratuwa)
        let viewModel = BoardingListViewModel(repository: MockBoardingRepository(), campusStore: store)
        await viewModel.load()
        let near = viewModel.boardings.first { $0.id == "6" }!.distanceToUniversityKm

        store.selected = .nibm
        let far = viewModel.boardings.first { $0.id == "6" }!.distanceToUniversityKm

        #expect(far > near)
        #expect(viewModel.filtered.isEmpty)   // Moratuwa boardings are far outside NIBM's search radius
    }
}

// MARK: - Login logic

@MainActor
struct AuthViewModelTests {
    @Test func invalidEmailIsRejected() async {
        let viewModel = AuthViewModel(service: MockAuthService())
        await viewModel.signIn(email: "not-an-email", password: "secret1")
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.errorMessage == "Please enter a valid email address.")
    }

    @Test func shortPasswordIsRejected() async {
        let viewModel = AuthViewModel(service: MockAuthService())
        await viewModel.signIn(email: "a@b.com", password: "123")
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.errorMessage == "Password must be at least 6 characters.")
    }

    @Test func successfulSignInAuthenticatesAndLoadsName() async {
        let viewModel = AuthViewModel(service: MockAuthService())
        await viewModel.signIn(email: "a@b.com", password: "secret1")
        #expect(viewModel.isAuthenticated)
        #expect(viewModel.fullName == "Test Student")
    }

    @Test func failedSignInShowsServiceMessage() async {
        let viewModel = AuthViewModel(service: MockAuthService(shouldFail: true))
        await viewModel.signIn(email: "a@b.com", password: "secret1")
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.errorMessage == "Incorrect email or password.")
    }

    @Test func signUpRequiresAName() async {
        let viewModel = AuthViewModel(service: MockAuthService())
        await viewModel.signUp(fullName: "  ", university: "UoM", email: "a@b.com", password: "secret1")
        #expect(viewModel.isAuthenticated == false)
        #expect(viewModel.errorMessage == "Please enter your full name.")
    }
}

// MARK: - Map radius

@MainActor
struct MapViewModelTests {
    @Test func smallRadiusFindsOnlyTheClosestBoarding() {
        let viewModel = MapViewModel()
        viewModel.radiusKm = 0.5
        let nearby = viewModel.nearby(Boarding.samples, around: Campus.moratuwa.coordinate)
        #expect(nearby.map(\.id) == ["6"])
    }

    @Test func largeRadiusIncludesEveryBoarding() {
        let viewModel = MapViewModel()
        viewModel.radiusKm = 5
        let nearby = viewModel.nearby(Boarding.samples, around: Campus.moratuwa.coordinate)
        #expect(nearby.count == Boarding.samples.count)
    }
}

struct AppearanceTests {
    @Test func appearanceModesMapToColourSchemes() {
        #expect(AppearanceMode.system.scheme == nil)
        #expect(AppearanceMode.light.scheme == .light)
        #expect(AppearanceMode.dark.scheme == .dark)
    }
}

// MARK: - Poster scan

@MainActor
struct PosterScanTests {
    @Test func readsBoardingIDFromPosterLink() {
        #expect(PosterLink.boardingID(from: "boardima://boarding/nibm-1") == "nibm-1")
        #expect(PosterLink.boardingID(from: "boardima://boarding/3") == "3")
    }

    @Test func ignoresLinksThatAreNotBoardimaPosters() {
        #expect(PosterLink.boardingID(from: "https://example.com/boarding/1") == nil)
        #expect(PosterLink.boardingID(from: "boardima://meal/1") == nil)
        #expect(PosterLink.boardingID(from: "boardima://boarding/") == nil)
        #expect(PosterLink.boardingID(from: "hello") == nil)
    }

    @Test func coreImageReadsAGeneratedQRCode() async throws {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data("boardima://boarding/3".utf8)
        let output = try #require(filter.outputImage?
            .transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            .samplingNearest())
        let context = CIContext()
        let cgImage = try #require(context.createCGImage(output, from: output.extent))

        let payloads = try await PosterScanner().payloads(in: UIImage(cgImage: cgImage))

        #expect(payloads == ["boardima://boarding/3"])
    }
}
