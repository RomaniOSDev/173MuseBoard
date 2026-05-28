import SwiftUI

struct BoardsView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @State private var selectedBoard: Board?
    @State private var showAddBoardSheet = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    MuseSectionHeader(
                        title: "Your Boards",
                        subtitle: "\(viewModel.boards.count) mood boards"
                    )

                    if viewModel.boards.isEmpty {
                        MuseEmptyState(
                            icon: "square.grid.2x2",
                            title: "No Boards Yet",
                            message: "Organize looks into themed boards for trips, evenings, or daily inspiration.",
                            buttonTitle: "Create Board",
                            action: { showAddBoardSheet = true }
                        )
                        .frame(minHeight: 320)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.boards) { board in
                                BoardCard(board: board)
                                    .onTapGesture { selectedBoard = board }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.deleteBoard(board)
                                        } label: {
                                            Label("Delete Board", systemImage: "trash")
                                        }
                                    }
                            }

                            MuseCreateCell(title: "Create New Board", icon: "plus")
                                .onTapGesture { showAddBoardSheet = true }
                        }
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    }
                }
                .padding(.vertical, 8)
            }
            .musePageBackground()
            .navigationTitle("Boards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddBoardSheet = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(MuseDesign.accentGradient)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddBoardSheet) {
                AddBoardView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedBoard) { board in
                BoardDetailView(viewModel: viewModel, board: board)
            }
        }
    }
}
