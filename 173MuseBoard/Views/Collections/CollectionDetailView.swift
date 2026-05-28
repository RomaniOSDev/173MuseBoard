import SwiftUI

struct CollectionDetailView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let collection: Collection

    @State private var selectedImage: MuseImage?
    @State private var editMode: EditMode = .inactive

    private var currentCollection: Collection {
        viewModel.collections.first { $0.id == collection.id } ?? collection
    }

    private var collectionImages: [MuseImage] {
        viewModel.images(for: currentCollection)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                coverHeader

                MuseSectionHeader(
                    title: "Photos",
                    subtitle: "\(collectionImages.count) in collection",
                    actionTitle: editMode.isEditing ? "Done" : "Reorder",
                    action: { editMode = editMode.isEditing ? .inactive : .active }
                )

                if collectionImages.isEmpty {
                    MuseEmptyState(
                        icon: "photo.on.rectangle",
                        title: "No Photos",
                        message: "Add looks from the feed to fill this collection."
                    )
                    .frame(height: 220)
                } else {
                    List {
                        ForEach(collectionImages) { image in
                            MuseListImageCell(image: image, showChevron: editMode.isEditing)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if editMode == .inactive { selectedImage = image }
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        guard var updated = viewModel.collections.first(where: { $0.id == currentCollection.id }) else { return }
                                        updated.imageIds.removeAll { $0 == image.id }
                                        viewModel.updateCollection(updated)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                        .onMove { source, destination in
                            viewModel.moveCollectionImage(collectionId: currentCollection.id, from: source, to: destination)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: CGFloat(collectionImages.count) * 88)
                }
            }
            .padding(.vertical, 8)
        }
        .musePageBackground()
        .environment(\.editMode, $editMode)
        .navigationTitle(currentCollection.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedImage) { image in
            NavigationStack {
                ImageDetailView(viewModel: viewModel, image: image)
            }
        }
    }

    private var coverHeader: some View {
        HStack(spacing: 14) {
            MusePhotoView(
                imageName: viewModel.collectionCoverName(for: currentCollection),
                contentMode: .fill
            )
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
            .museShadow(.lite)
            .museGradientBorder(radius: MuseDesign.cellRadius)

            VStack(alignment: .leading, spacing: 6) {
                Text(currentCollection.name)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.museDeep)
                if !currentCollection.description.isEmpty {
                    Text(currentCollection.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                MuseIconBadge(icon: "photo.stack", text: "\(collectionImages.count) photos")
            }
            Spacer(minLength: 0)
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }
}
