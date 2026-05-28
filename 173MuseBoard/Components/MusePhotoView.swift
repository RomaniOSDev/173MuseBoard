import SwiftUI

struct MusePhotoView: View {
    let imageName: String
    var contentMode: ContentMode = .fill

    var body: some View {
        Group {
            if let uiImage = MuseImageStorage.uiImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.museAccent.opacity(0.12))
            .overlay {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
    }
}
