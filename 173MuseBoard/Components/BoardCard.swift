import SwiftUI

struct BoardCard: View {
    let board: Board

    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                MusePhotoView(imageName: board.coverImageName, contentMode: .fill)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                            .stroke(MuseDesign.glassStrokeGradient, lineWidth: 1)
                    )

                Text("\(board.imageIds.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(MuseDesign.accentGradient))
                    .padding(6)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(board.name)
                    .font(.headline)
                    .foregroundColor(.museDeep)
                    .lineLimit(1)

                if !board.description.isEmpty {
                    Text(board.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {
                    MuseIconBadge(
                        icon: board.isPublic ? "globe" : "lock.fill",
                        text: board.isPublic ? "Public" : "Private",
                        tint: board.isPublic ? .museAccent : .museDeep
                    )
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.museAccent)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.museAccent.opacity(0.14), Color.museSoftFill],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        }
        .padding(14)
        .museElevatedShell(shadow: .medium)
    }
}
