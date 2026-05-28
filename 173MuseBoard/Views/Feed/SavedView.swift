import SwiftUI

struct SavedView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @State private var selectedImage: MuseImage?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedImages.isEmpty {
                    MuseEmptyState(
                        icon: "bookmark.fill",
                        title: "No Saved Photos",
                        message: "Bookmark looks from the feed to build your personal saved library."
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            MuseSectionHeader(
                                title: "Saved Library",
                                subtitle: "\(viewModel.savedImages.count) bookmarked looks"
                            )

                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                                spacing: 14
                            ) {
                                ForEach(viewModel.savedImages) { image in
                                    MuseCard(
                                        image: image,
                                        onToggleFavorite: { viewModel.toggleFavorite(image) },
                                        onToggleSaved: { viewModel.toggleSaved(image) }
                                    )
                                    .onTapGesture { selectedImage = image }
                                }
                            }
                            .padding(.horizontal, MuseDesign.horizontalPadding)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .musePageBackground()
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selectedImage) { image in
                NavigationStack {
                    ImageDetailView(viewModel: viewModel, image: image)
                }
            }
        }
    }
}
