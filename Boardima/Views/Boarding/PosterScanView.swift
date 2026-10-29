import SwiftUI
import PhotosUI

struct PosterScanView: View {
    @Environment(BoardingListViewModel.self) private var listViewModel
    @Environment(SavedViewModel.self) private var saved
    @Environment(MatchViewModel.self) private var match
    @Environment(\.dismiss) private var dismiss

    @State private var model = PosterScanViewModel()
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.ink)
                        .accessibilityHidden(true)

                    Text("Scan a boarding poster").font(.title2.bold())
                    Text("Choose a photo of a Boardima poster. The QR code is read on your device with Apple's Vision framework, and the boarding opens.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose poster photo", systemImage: "photo.on.rectangle")
                    }
                    .buttonStyle(BrandButtonStyle())

                    resultView
                }
                .readableContentWidth(560)
                .padding()
            }
            .background(Theme.background)
            .navigationTitle("Scan poster")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: pickerItem) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await listViewModel.load()
                        await model.scan(imageData: data, boardings: listViewModel.boardings)
                    } else {
                        model.showFailure("That photo couldn't be loaded.")
                    }
                    pickerItem = nil
                }
            }
        }
    }

    @ViewBuilder
    private var resultView: some View {
        switch model.state {
        case .idle:
            EmptyView()
        case .scanning:
            ProgressView("Reading QR code…")
        case .found(let boarding):
            VStack(alignment: .leading, spacing: 12) {
                Label("Poster recognised", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(Theme.green)
                NavigationLink {
                    BoardingDetailView(boarding: boarding)
                } label: {
                    BoardingRow(boarding: boarding,
                                isSaved: saved.isSaved(boarding.id),
                                match: match.score(for: boarding),
                                onToggleSave: { saved.toggle(boarding) })
                }
                .buttonStyle(.plain)
            }
        case .notABoardimaCode:
            message("This QR code isn't a Boardima poster.", symbol: "exclamationmark.triangle")
        case .boardingMissing:
            message("That boarding isn't listed any more.", symbol: "questionmark.circle")
        case .noCode:
            message("No QR code found in that photo. Try a clearer, straight-on photo.", symbol: "qrcode")
        case .failed(let text):
            message(text, symbol: "xmark.octagon")
        }
    }

    private func message(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            .accessibilityElement(children: .combine)
    }
}
