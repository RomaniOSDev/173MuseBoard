import PhotosUI
import SwiftUI

struct MultiPhotoSourceSection: View {
    @Binding var usesDevicePhotos: Bool
    @Binding var deviceImages: [UIImage]
    @Binding var selectedBuiltinIndex: Int
    var existingImageNames: [String] = []

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var editingIndex: Int?
    @State private var showEditor = false

    var body: some View {
        Section(header: Text("Photos").foregroundColor(.gray)) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.museAccent)
                    Text("Choose from Device")
                        .foregroundColor(.museDeep)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            if !deviceImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(deviceImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipped()
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        editingIndex = index
                                        showEditor = true
                                    }

                                Button {
                                    deviceImages.remove(at: index)
                                    if deviceImages.isEmpty { usesDevicePhotos = false }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.red))
                                }
                                .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
                .frame(height: 90)
            } else if !existingImageNames.isEmpty, usesDevicePhotos {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(existingImageNames, id: \.self) { name in
                            MusePhotoView(imageName: name, contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 90)
            }

            primaryPreview
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)

            Text("Or pick from built-in gallery")
                .font(.caption)
                .foregroundColor(.gray)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...20, id: \.self) { index in
                        Image("girl\(index)")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 72, height: 72)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        !usesDevicePhotos && selectedBuiltinIndex == index
                                            ? Color.museAccent : Color.clear,
                                        lineWidth: 3
                                    )
                            )
                            .onTapGesture {
                                usesDevicePhotos = false
                                deviceImages = []
                                selectedPhotoItem = nil
                                selectedBuiltinIndex = index
                            }
                    }
                }
            }
            .frame(height: 88)
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task { await loadDevicePhoto(from: newItem) }
        }
        .sheet(isPresented: $showEditor) {
            if let editingIndex, deviceImages.indices.contains(editingIndex) {
                ImageEditorView(
                    sourceImage: deviceImages[editingIndex],
                    onApply: { edited in
                        deviceImages[editingIndex] = edited
                        self.editingIndex = nil
                    },
                    onCancel: { self.editingIndex = nil }
                )
            }
        }
    }

    @ViewBuilder
    private var primaryPreview: some View {
        if usesDevicePhotos, let first = deviceImages.first {
            Image(uiImage: first)
                .resizable()
                .scaledToFill()
        } else if !usesDevicePhotos {
            Image("girl\(selectedBuiltinIndex)")
                .resizable()
                .scaledToFill()
        } else if let first = existingImageNames.first {
            MusePhotoView(imageName: first, contentMode: .fill)
        } else {
            Rectangle()
                .fill(Color.museAccent.opacity(0.1))
                .overlay {
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.museAccent)
                }
        }
    }

    private func loadDevicePhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        await MainActor.run {
            usesDevicePhotos = true
            deviceImages.append(uiImage)
            selectedPhotoItem = nil
        }
    }
}
