import PhotosUI
import SwiftUI

struct AddBoardView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var coverIndex = 1
    @State private var usesDeviceCover = false
    @State private var deviceCover: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isPublic = true
    @State private var selectedTemplate: BoardTemplate?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Templates").foregroundColor(.gray)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(BoardTemplate.presets) { template in
                                VStack(alignment: .leading, spacing: 4) {
                                    Image(template.coverImageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 64)
                                        .clipped()
                                        .cornerRadius(8)
                                    Text(template.name)
                                        .font(.caption)
                                        .foregroundColor(.museDeep)
                                }
                                .padding(6)
                                .background(
                                    selectedTemplate?.name == template.name
                                        ? Color.museAccent.opacity(0.15)
                                        : Color.clear
                                )
                                .cornerRadius(8)
                                .onTapGesture { applyTemplate(template) }
                            }
                        }
                    }
                    .frame(height: 110)
                }

                Section {
                    TextField("Board name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 70)
                }

                Section(header: Text("Cover").foregroundColor(.gray)) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Cover from Device", systemImage: "photo")
                            .foregroundColor(.museAccent)
                    }

                    if let deviceCover {
                        Image(uiImage: deviceCover)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(1...20, id: \.self) { index in
                                Image("girl\(index)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                !usesDeviceCover && coverIndex == index
                                                    ? Color.museAccent : Color.clear,
                                                lineWidth: 3
                                            )
                                    )
                                    .onTapGesture {
                                        usesDeviceCover = false
                                        deviceCover = nil
                                        coverIndex = index
                                    }
                            }
                        }
                    }
                    .frame(height: 80)
                }

                Section {
                    Toggle("Public board", isOn: $isPublic)
                        .tint(.museAccent)
                }
            }
            .scrollContentBackground(.hidden)
            .musePageBackground()
            .navigationTitle("New Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveBoard() }
                        .foregroundColor(.museAccent)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: selectedPhotoItem) { item in
                Task {
                    guard let data = try? await item?.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    await MainActor.run {
                        deviceCover = image
                        usesDeviceCover = true
                    }
                }
            }
        }
    }

    private func applyTemplate(_ template: BoardTemplate) {
        selectedTemplate = template
        name = template.name
        description = template.description
        isPublic = template.isPublic
        usesDeviceCover = false
        deviceCover = nil
        if let index = Int(template.coverImageName.replacingOccurrences(of: "girl", with: "")) {
            coverIndex = index
        }
    }

    private func saveBoard() {
        let boardId = UUID()
        var coverName = "girl\(coverIndex)"

        if usesDeviceCover, let deviceCover {
            coverName = (try? MuseImageStorage.saveBoardCover(deviceCover, boardId: boardId)) ?? coverName
        }

        let board = Board(
            id: boardId,
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            coverImageName: coverName,
            imageIds: [],
            isPublic: isPublic,
            createdAt: Date()
        )
        viewModel.addBoard(board)
        dismiss()
    }
}
