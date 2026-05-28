import PhotosUI
import SwiftUI

struct PhotoSourceSection: View {
    @Binding var usesDevicePhoto: Bool
    @Binding var devicePreview: UIImage?
    @Binding var selectedBuiltinIndex: Int
    var existingImageName: String?

    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Section(header: Text("Photo").foregroundColor(.gray)) {
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

            photoPreview
                .frame(maxWidth: .infinity)
                .frame(height: 200)
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
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        !usesDevicePhoto && selectedBuiltinIndex == index
                                            ? Color.museAccent
                                            : Color.clear,
                                        lineWidth: 3
                                    )
                            )
                            .onTapGesture {
                                usesDevicePhoto = false
                                devicePreview = nil
                                selectedPhotoItem = nil
                                selectedBuiltinIndex = index
                            }
                    }
                }
            }
            .frame(height: 100)
        }
        .onChange(of: selectedPhotoItem) { newItem in
            Task { await loadDevicePhoto(from: newItem) }
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        if usesDevicePhoto, let devicePreview {
            Image(uiImage: devicePreview)
                .resizable()
                .scaledToFill()
        } else if !usesDevicePhoto {
            Image("girl\(selectedBuiltinIndex)")
                .resizable()
                .scaledToFill()
        } else if let existingImageName {
            MusePhotoView(imageName: existingImageName, contentMode: .fill)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.museAccent.opacity(0.1))
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.museAccent)
                    Text("Select a photo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
    }

    private func loadDevicePhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        await MainActor.run {
            devicePreview = uiImage
            usesDevicePhoto = true
        }
    }
}
