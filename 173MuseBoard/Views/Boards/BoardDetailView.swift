import SwiftUI

struct BoardDetailView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let board: Board

    @State private var selectedImage: MuseImage?
    @State private var editMode: EditMode = .inactive
    @State private var moodBoardGrid: MoodBoardRenderer.GridSize = .two
    @State private var exportMessage: String?

    private var currentBoard: Board {
        viewModel.boards.first { $0.id == board.id } ?? board
    }

    private var boardImages: [MuseImage] {
        viewModel.images(for: currentBoard)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                coverHero

                exportSection

                MuseSectionHeader(
                    title: "Board Photos",
                    subtitle: editMode.isEditing ? "Drag to reorder" : "\(boardImages.count) items",
                    actionTitle: editMode.isEditing ? "Done" : "Reorder",
                    action: { editMode = editMode.isEditing ? .inactive : .active }
                )

                if boardImages.isEmpty {
                    MuseEmptyState(
                        icon: "photo.stack",
                        title: "Empty Board",
                        message: "Add photos from the feed using “Add to Board”."
                    )
                    .frame(height: 220)
                } else {
                    List {
                        ForEach(boardImages) { image in
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
                                        viewModel.removeImageFromBoard(imageId: image.id, boardId: currentBoard.id)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                        }
                        .onMove { source, destination in
                            viewModel.moveBoardImage(boardId: currentBoard.id, from: source, to: destination)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: CGFloat(boardImages.count) * 88)
                }
            }
            .padding(.vertical, 8)
        }
        .musePageBackground()
        .environment(\.editMode, $editMode)
        .navigationTitle(currentBoard.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedImage) { image in
            NavigationStack {
                ImageDetailView(viewModel: viewModel, image: image)
            }
        }
    }

    private var coverHero: some View {
        ZStack(alignment: .bottomLeading) {
            MusePhotoView(imageName: currentBoard.coverImageName, contentMode: .fill)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 6) {
                Text(currentBoard.name)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                if !currentBoard.description.isEmpty {
                    Text(currentBoard.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                MuseIconBadge(
                    icon: currentBoard.isPublic ? "globe" : "lock.fill",
                    text: currentBoard.isPublic ? "Public" : "Private",
                    tint: .white
                )
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous))
        .museShadow(.elevated)
        .museGradientBorder()
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var exportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Board Collage")
                .font(.headline)
                .foregroundColor(.museDeep)

            Picker("Grid", selection: $moodBoardGrid) {
                Text("2×2").tag(MoodBoardRenderer.GridSize.two)
                Text("3×3").tag(MoodBoardRenderer.GridSize.three)
            }
            .pickerStyle(.segmented)

            MusePrimaryButton(title: "Save to Photos", icon: "square.and.arrow.down") {
                exportMoodBoard()
            }

            if let exportMessage {
                Text(exportMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private func exportMoodBoard() {
        let names = boardImages.map(\.primaryImageName)
        guard let collage = MoodBoardRenderer.collage(imageNames: names, grid: moodBoardGrid) else {
            exportMessage = "Add photos to the board first."
            return
        }
        PhotoLibrarySaver.save(collage) { success in
            exportMessage = success ? "Collage saved to Photos." : "Could not save. Check permissions."
        }
    }
}
