import SwiftUI

struct EditImageView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let image: MuseImage

    @Environment(\.dismiss) private var dismiss

    @State private var usesDevicePhotos: Bool
    @State private var deviceImages: [UIImage]
    @State private var selectedBuiltinIndex: Int
    @State private var title: String
    @State private var description: String
    @State private var selectedStyles: Set<StyleCategory>
    @State private var mood: Mood
    @State private var occasion: Occasion?
    @State private var tagsString: String
    @State private var photographer: String
    @State private var location: String
    @State private var dateTaken: Date
    @State private var includeDateTaken: Bool
    @State private var isFavorite: Bool
    @State private var isSaved: Bool
    @State private var saveErrorMessage: String?

    init(viewModel: MuseBoardViewModel, image: MuseImage) {
        self.viewModel = viewModel
        self.image = image

        let hasLocal = image.imageNames.contains(where: MuseImageStorage.isLocal)
        let builtinIndex = Int(image.imageNames.first?.replacingOccurrences(of: "girl", with: "") ?? "1") ?? 1

        _usesDevicePhotos = State(initialValue: hasLocal)
        _deviceImages = State(initialValue: [])
        _selectedBuiltinIndex = State(initialValue: builtinIndex)
        _title = State(initialValue: image.title)
        _description = State(initialValue: image.description)
        _selectedStyles = State(initialValue: Set(image.styles))
        _mood = State(initialValue: image.mood)
        _occasion = State(initialValue: image.occasion)
        _tagsString = State(initialValue: image.tags.joined(separator: ", "))
        _photographer = State(initialValue: image.photographer ?? "")
        _location = State(initialValue: image.location ?? "")
        _dateTaken = State(initialValue: image.dateTaken ?? Date())
        _includeDateTaken = State(initialValue: image.dateTaken != nil)
        _isFavorite = State(initialValue: image.isFavorite)
        _isSaved = State(initialValue: image.isSaved)
    }

    var body: some View {
        NavigationStack {
            Form {
                MultiPhotoSourceSection(
                    usesDevicePhotos: $usesDevicePhotos,
                    deviceImages: $deviceImages,
                    selectedBuiltinIndex: $selectedBuiltinIndex,
                    existingImageNames: deviceImages.isEmpty ? image.imageNames : []
                )

                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 80)
                }

                Section(header: Text("Styles").foregroundColor(.gray)) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(StyleCategory.allCases, id: \.self) { style in
                                FilterChip(
                                    title: style.rawValue,
                                    isSelected: selectedStyles.contains(style),
                                    color: .museAccent
                                )
                                .onTapGesture {
                                    if selectedStyles.contains(style) {
                                        selectedStyles.remove(style)
                                    } else {
                                        selectedStyles.insert(style)
                                    }
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Mood").foregroundColor(.gray)) {
                    Picker("Mood", selection: $mood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Label(mood.rawValue, systemImage: mood.icon).tag(mood)
                        }
                    }
                    .tint(.museAccent)
                }

                Section(header: Text("Occasion").foregroundColor(.gray)) {
                    Picker("Occasion", selection: $occasion) {
                        Text("None").tag(Optional<Occasion>.none)
                        ForEach(Occasion.allCases, id: \.self) { item in
                            Label(item.rawValue, systemImage: item.icon).tag(Optional(item))
                        }
                    }
                    .tint(.museAccent)
                }

                Section(header: Text("Tags").foregroundColor(.gray)) {
                    TagAutocompleteField(tagsString: $tagsString, suggestions: viewModel.allTags)
                }

                Section(header: Text("Details").foregroundColor(.gray)) {
                    TextField("Photographer", text: $photographer)
                    TextField("Location", text: $location)
                    Toggle("Include shoot date", isOn: $includeDateTaken)
                        .tint(.museAccent)
                    if includeDateTaken {
                        DatePicker("Date taken", selection: $dateTaken, displayedComponents: .date)
                            .tint(.museAccent)
                    }
                }

                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                        .tint(.museAccent)
                    Toggle("Saved", isOn: $isSaved)
                        .tint(.museAccent)
                }
            }
            .scrollContentBackground(.hidden)
            .musePageBackground()
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(.museAccent)
                        .disabled(!canSave)
                }
            }
            .alert("Could Not Save Photo", isPresented: Binding(
                get: { saveErrorMessage != nil },
                set: { if !$0 { saveErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveErrorMessage ?? "")
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (usesDevicePhotos ? (!deviceImages.isEmpty || !image.imageNames.isEmpty) : true)
    }

    private func saveChanges() {
        let tags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let oldNames = image.imageNames
        var newNames: [String] = []

        do {
            if usesDevicePhotos, !deviceImages.isEmpty {
                MuseImageStorage.deleteAllLocal(names: oldNames)
                for (index, uiImage) in deviceImages.enumerated() {
                    let name = try MuseImageStorage.saveImage(uiImage, imageId: image.id, index: index)
                    newNames.append(name)
                }
            } else if usesDevicePhotos {
                newNames = oldNames
            } else {
                MuseImageStorage.deleteAllLocal(names: oldNames)
                newNames = ["girl\(selectedBuiltinIndex)"]
            }
        } catch {
            saveErrorMessage = "Failed to save photos."
            return
        }

        var updated = image
        updated.imageNames = newNames
        updated.title = title.trimmingCharacters(in: .whitespaces)
        updated.description = description.trimmingCharacters(in: .whitespaces)
        updated.styles = Array(selectedStyles)
        updated.mood = mood
        updated.occasion = occasion
        updated.tags = tags
        updated.photographer = photographer.isEmpty ? nil : photographer
        updated.location = location.isEmpty ? nil : location
        updated.dateTaken = includeDateTaken ? dateTaken : nil
        updated.isFavorite = isFavorite
        updated.isSaved = isSaved

        viewModel.updateImage(updated)
        dismiss()
    }
}
