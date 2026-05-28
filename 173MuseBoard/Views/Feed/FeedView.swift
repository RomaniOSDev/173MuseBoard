import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @State private var selectedImage: MuseImage?
    @State private var showAddImage = false
    @State private var showBoardPicker = false
    @State private var showCollectionPicker = false
    @State private var showCompare = false
    @State private var imageForBoard: MuseImage?
    @State private var imageForCollection: MuseImage?
    @State private var shareImageItem: MuseImage?
    @State private var showFilters = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        MuseScreenHeader(
                            title: "Inspiration Feed",
                            subtitle: "\(viewModel.filteredImages.count) of \(viewModel.images.count) looks",
                            trailingIcon: "square.split.2x1",
                            trailingAction: { showCompare = true }
                        )

                        MuseSearchBar(
                            text: $viewModel.searchText,
                            placeholder: "Search title, tags, mood…"
                        )

                        filterToolbar

                        if showFilters { advancedFilters }

                        MuseSectionHeader(title: "Overview", subtitle: "Your library at a glance")
                        statsSection

                        MuseSectionHeader(title: "Styles", subtitle: "Tap to filter the feed")
                        styleFiltersSection

                        MuseSectionHeader(
                            title: "Looks",
                            subtitle: viewModel.filteredImages.isEmpty ? "No matches" : "\(viewModel.filteredImages.count) shown"
                        )
                        gridSection
                    }
                    .padding(.bottom, 96)
                }

                MuseFloatingAddButton { showAddImage = true }
            }
            .musePageBackground()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddImage) {
                AddImageView(viewModel: viewModel)
            }
            .sheet(item: $selectedImage) { image in
                NavigationStack {
                    ImageDetailView(viewModel: viewModel, image: image)
                }
            }
            .sheet(isPresented: $showBoardPicker) {
                BoardPickerSheet(viewModel: viewModel, image: imageForBoard)
            }
            .sheet(isPresented: $showCollectionPicker) {
                CollectionPickerSheet(viewModel: viewModel, image: imageForCollection)
            }
            .sheet(isPresented: $showCompare) {
                CompareView(viewModel: viewModel)
            }
            .sheet(item: $shareImageItem) { image in
                ShareSheet(items: shareItems(for: image))
            }
        }
    }

    private var filterToolbar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Menu {
                    ForEach(FeedSortOption.allCases) { option in
                        Button(option.rawValue) { viewModel.feedSort = option }
                    }
                } label: {
                    MuseFilterBarButton(
                        title: viewModel.feedSort.rawValue,
                        icon: "arrow.up.arrow.down",
                        isActive: true,
                        action: {}
                    )
                }

                MuseFilterBarButton(
                    title: showFilters ? "Hide" : "Filters",
                    icon: "line.3.horizontal.decrease.circle",
                    isActive: showFilters,
                    action: { showFilters.toggle() }
                )
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)
        }
    }

    private var advancedFilters: some View {
        VStack(alignment: .leading, spacing: 12) {
            filterRow(title: "Library") {
                ForEach(FeedLibraryFilter.allCases) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.libraryFilter == filter,
                        color: .museAccent,
                        icon: filter == .favorites ? "heart.fill" : (filter == .saved ? "bookmark.fill" : "square.grid.2x2")
                    )
                    .onTapGesture { viewModel.libraryFilter = filter }
                }
            }

            filterRow(title: "Mood") {
                FilterChip(title: "All", isSelected: viewModel.selectedMood == nil, color: .museDeep)
                    .onTapGesture { viewModel.selectedMood = nil }
                ForEach(Mood.allCases, id: \.self) { mood in
                    FilterChip(
                        title: mood.rawValue,
                        isSelected: viewModel.selectedMood == mood,
                        color: .museDeep,
                        icon: mood.icon
                    )
                    .onTapGesture { viewModel.selectedMood = mood }
                }
            }

            filterRow(title: "Occasion") {
                FilterChip(title: "All", isSelected: viewModel.selectedOccasion == nil, color: .museAccent)
                    .onTapGesture { viewModel.selectedOccasion = nil }
                ForEach(Occasion.allCases, id: \.self) { occasion in
                    FilterChip(
                        title: occasion.rawValue,
                        isSelected: viewModel.selectedOccasion == occasion,
                        color: .museAccent,
                        icon: occasion.icon
                    )
                    .onTapGesture { viewModel.selectedOccasion = occasion }
                }
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private func filterRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.gray)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { content() }
            }
        }
    }

    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(title: "Total", value: "\(viewModel.images.count)", icon: "photo.fill", color: .museAccent, compact: true)
                    .frame(width: 140)
                StatCard(title: "Favorites", value: "\(viewModel.favoriteCount)", icon: "heart.fill", color: .museAccent, compact: true)
                    .frame(width: 140)
                StatCard(title: "Saved", value: "\(viewModel.savedCount)", icon: "bookmark.fill", color: .museDeep, compact: true)
                    .frame(width: 140)
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)
        }
    }

    private var styleFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: viewModel.selectedStyle == nil, color: .museAccent)
                    .onTapGesture { viewModel.selectedStyle = nil }
                ForEach(StyleCategory.allCases, id: \.self) { style in
                    FilterChip(
                        title: style.rawValue,
                        isSelected: viewModel.selectedStyle == style,
                        color: .museAccent,
                        icon: style.icon
                    )
                    .onTapGesture { viewModel.selectedStyle = style }
                }
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)
        }
    }

    @ViewBuilder
    private var gridSection: some View {
        if viewModel.filteredImages.isEmpty {
            MuseEmptyState(
                icon: "photo.on.rectangle.angled",
                title: "No Looks Found",
                message: "Try changing filters or add a new photo to your feed."
            )
            .frame(height: 280)
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                spacing: 14
            ) {
                ForEach(viewModel.filteredImages) { image in
                    MuseCard(
                        image: image,
                        onToggleFavorite: { viewModel.toggleFavorite(image) },
                        onToggleSaved: { viewModel.toggleSaved(image) }
                    )
                    .onTapGesture { selectedImage = image }
                    .contextMenu {
                        contextActions(for: image)
                    }
                }
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)
        }
    }

    @ViewBuilder
    private func contextActions(for image: MuseImage) -> some View {
        Button { viewModel.toggleFavorite(image) } label: {
            Label(image.isFavorite ? "Remove Favorite" : "Favorite", systemImage: "heart")
        }
        Button { viewModel.toggleSaved(image) } label: {
            Label(image.isSaved ? "Unsave" : "Save", systemImage: "bookmark")
        }
        Button {
            imageForBoard = image
            showBoardPicker = true
        } label: {
            Label("Add to Board", systemImage: "square.grid.2x2")
        }
        Button {
            imageForCollection = image
            showCollectionPicker = true
        } label: {
            Label("Add to Collection", systemImage: "folder.badge.plus")
        }
        Button { viewModel.duplicateImage(image) } label: {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }
        Button { shareImageItem = image } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
    }

    private func shareItems(for image: MuseImage) -> [Any] {
        var items: [Any] = ["\(image.title)\n\(image.description)"]
        if let uiImage = MuseImageStorage.uiImage(named: image.primaryImageName) {
            items.append(uiImage)
        }
        return items
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct BoardPickerSheet: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let image: MuseImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.boards.isEmpty {
                    MuseEmptyState(
                        icon: "square.grid.2x2",
                        title: "No Boards",
                        message: "Create a board first from the Boards tab."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.boards) { board in
                                Button {
                                    guard let image else { return }
                                    viewModel.addImageToBoard(imageId: image.id, boardId: board.id)
                                    dismiss()
                                } label: {
                                    BoardCard(board: board)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .musePageBackground()
            .navigationTitle("Add to Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
            }
        }
    }
}

struct CollectionPickerSheet: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let image: MuseImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.collections.isEmpty {
                    MuseEmptyState(
                        icon: "folder",
                        title: "No Collections",
                        message: "Create a collection first from the Collections tab."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.collections) { collection in
                                Button {
                                    guard let image else { return }
                                    viewModel.addImageToCollection(imageId: image.id, collectionId: collection.id)
                                    dismiss()
                                } label: {
                                    CollectionCard(
                                        collection: collection,
                                        coverImageName: viewModel.collectionCoverName(for: collection)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .musePageBackground()
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
            }
        }
    }
}
