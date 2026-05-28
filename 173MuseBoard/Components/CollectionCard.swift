import SwiftUI

struct CollectionCard: View {
    let collection: Collection
    let coverImageName: String

    var body: some View {
        HStack(spacing: 14) {
            MusePhotoView(imageName: coverImageName, contentMode: .fill)
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                        .stroke(MuseDesign.accentGradient, lineWidth: 1.5)
                        .opacity(0.45)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(MuseDesign.accentGradient)
                        .font(.caption)
                    Text(collection.name)
                        .font(.headline)
                        .foregroundColor(.museDeep)
                        .lineLimit(1)
                }

                if !collection.description.isEmpty {
                    Text(collection.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                MuseIconBadge(icon: "photo.stack", text: "\(collection.imageIds.count) photos")
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.museAccent)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.museSoftFill))
        }
        .padding(14)
        .museElevatedShell(shadow: .medium)
    }
}
