import SwiftUI

struct AddCollectionView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedImageIds: Set<UUID> = []
    @State private var coverImageName: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 70)
                }

                if !viewModel.images.isEmpty {
                    Section(header: Text("Photos").foregroundColor(.gray)) {
                        ForEach(viewModel.images) { image in
                            HStack {
                                MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .cornerRadius(6)

                                VStack(alignment: .leading) {
                                    Text(image.title)
                                    if coverImageName == image.primaryImageName {
                                        Text("Cover")
                                            .font(.caption2)
                                            .foregroundColor(.museAccent)
                                    }
                                }

                                Spacer()

                                if selectedImageIds.contains(image.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.museAccent)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedImageIds.contains(image.id) {
                                    selectedImageIds.remove(image.id)
                                    if coverImageName == image.primaryImageName {
                                        coverImageName = nil
                                    }
                                } else {
                                    selectedImageIds.insert(image.id)
                                    if coverImageName == nil {
                                        coverImageName = image.primaryImageName
                                    }
                                }
                            }
                            .contextMenu {
                                Button("Set as Cover") {
                                    selectedImageIds.insert(image.id)
                                    coverImageName = image.primaryImageName
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .musePageBackground()
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCollection() }
                        .foregroundColor(.museAccent)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveCollection() {
        let collection = Collection(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            coverImageName: coverImageName,
            imageIds: Array(selectedImageIds),
            createdAt: Date()
        )
        viewModel.addCollection(collection)
        dismiss()
    }
}
