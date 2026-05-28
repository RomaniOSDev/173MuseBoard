import SwiftUI

struct AddImageView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var usesDevicePhotos = false
    @State private var deviceImages: [UIImage] = []
    @State private var selectedBuiltinIndex = 1
    @State private var title = ""
    @State private var description = ""
    @State private var selectedStyles: Set<StyleCategory> = []
    @State private var mood: Mood = .happy
    @State private var occasion: Occasion?
    @State private var tagsString = ""
    @State private var photographer = ""
    @State private var location = ""
    @State private var dateTaken = Date()
    @State private var includeDateTaken = false
    @State private var isFavorite = false
    @State private var saveErrorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                MultiPhotoSourceSection(
                    usesDevicePhotos: $usesDevicePhotos,
                    deviceImages: $deviceImages,
                    selectedBuiltinIndex: $selectedBuiltinIndex
                )

                Section {
                    TextField("Title", text: $title)
                        .foregroundColor(.museDeep)
                    TextEditor(text: $description)
                        .frame(height: 80)
                        .foregroundColor(.museDeep)
                }

                Section(header: Text("Styles").foregroundColor(.gray)) {
                    stylePicker
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
                    Toggle("Add to favorites", isOn: $isFavorite)
                        .tint(.museAccent)
                }
            }
            .scrollContentBackground(.hidden)
            .musePageBackground()
            .navigationTitle("New Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.museAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveImage() }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.museAccent)
                        .cornerRadius(8)
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

    private var stylePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(StyleCategory.allCases, id: \.self) { style in
                    FilterChip(
                        title: style.rawValue,
                        isSelected: selectedStyles.contains(style),
                        color: .museAccent
                    )
                    .onTapGesture { toggleStyle(style) }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (usesDevicePhotos ? !deviceImages.isEmpty : true)
    }

    private func toggleStyle(_ style: StyleCategory) {
        if selectedStyles.contains(style) {
            selectedStyles.remove(style)
        } else {
            selectedStyles.insert(style)
        }
    }

    private func saveImage() {
        let tags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let id = UUID()
        var imageNames: [String] = []

        do {
            if usesDevicePhotos {
                for (index, image) in deviceImages.enumerated() {
                    let name = try MuseImageStorage.saveImage(image, imageId: id, index: index)
                    imageNames.append(name)
                }
            } else {
                imageNames = ["girl\(selectedBuiltinIndex)"]
            }
        } catch {
            saveErrorMessage = "Failed to save photos from your device."
            return
        }

        let museImage = MuseImage(
            id: id,
            imageNames: imageNames,
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            styles: Array(selectedStyles),
            mood: mood,
            occasion: occasion,
            tags: tags,
            photographer: photographer.isEmpty ? nil : photographer,
            location: location.isEmpty ? nil : location,
            dateTaken: includeDateTaken ? dateTaken : nil,
            isFavorite: isFavorite,
            isSaved: false,
            createdAt: Date()
        )
        viewModel.addImage(museImage)
        dismiss()
    }
}
