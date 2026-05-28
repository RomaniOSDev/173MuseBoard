import SwiftUI

struct CollectionsView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @State private var selectedCollection: Collection?
    @State private var showAddCollectionSheet = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MuseSectionHeader(
                        title: "Collections",
                        subtitle: "\(viewModel.collections.count) curated sets"
                    )

                    if viewModel.collections.isEmpty {
                        MuseEmptyState(
                            icon: "folder.fill",
                            title: "No Collections",
                            message: "Group related looks into collections with custom covers and descriptions.",
                            buttonTitle: "Create Collection",
                            action: { showAddCollectionSheet = true }
                        )
                        .frame(minHeight: 320)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.collections) { collection in
                                CollectionCard(
                                    collection: collection,
                                    coverImageName: viewModel.collectionCoverName(for: collection)
                                )
                                .onTapGesture { selectedCollection = collection }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteCollection(collection)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }

                            MuseCreateCell(title: "Create Collection", icon: "folder.badge.plus")
                                .onTapGesture { showAddCollectionSheet = true }
                        }
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    }
                }
                .padding(.vertical, 8)
            }
            .musePageBackground()
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddCollectionSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(MuseDesign.accentGradient)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddCollectionSheet) {
                AddCollectionView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedCollection) { collection in
                CollectionDetailView(viewModel: viewModel, collection: collection)
            }
        }
    }
}
