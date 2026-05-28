import SwiftUI

struct MuseCard: View {
    let image: MuseImage
    let onToggleFavorite: () -> Void
    let onToggleSaved: () -> Void
    /// Lite shadow for feed grids — smoother scrolling.
    var shadowLevel: MuseShadowLevel = .lite

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                    .frame(height: 210)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.2), Color.black.opacity(0.58)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(image.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    MuseIconBadge(icon: image.mood.icon, text: image.mood.rawValue, tint: .white)
                        .background(Capsule().fill(Color.white.opacity(0.16)))
                }
                .padding(12)

                VStack {
                    HStack {
                        if image.imageNames.count > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up.fill")
                                Text("\(image.imageNames.count)")
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.black.opacity(0.35)))
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            cardActionButton(
                                systemName: image.isFavorite ? "heart.fill" : "heart",
                                isActive: image.isFavorite,
                                action: onToggleFavorite
                            )
                            cardActionButton(
                                systemName: image.isSaved ? "bookmark.fill" : "bookmark",
                                isActive: image.isSaved,
                                action: onToggleSaved
                            )
                        }
                    }
                    Spacer()
                }
                .padding(10)
            }
            .museCornerRadius(MuseDesign.cardRadius, corners: [.topLeft, .topRight])

            HStack(spacing: 6) {
                ForEach(image.styles.prefix(2), id: \.self) { style in
                    MuseStyleTag(text: style.rawValue, icon: style.icon, compact: true)
                }
                if let occasion = image.occasion {
                    MuseStyleTag(text: occasion.rawValue, icon: occasion.icon, compact: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(MuseDesign.cardHighlightGradient)
        }
        .background(Color.museSurfaceFill)
        .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous))
        .museShadow(shadowLevel)
        .museGradientBorder(radius: MuseDesign.cardRadius)
    }

    private func cardActionButton(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.caption.weight(.bold))
                .foregroundColor(isActive ? .museAccent : .white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isActive ? Color.white : Color.black.opacity(0.28))
                )
        }
        .buttonStyle(.plain)
    }
}
