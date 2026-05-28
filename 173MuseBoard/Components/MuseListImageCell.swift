import SwiftUI

struct MuseListImageCell: View {
    let image: MuseImage
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.museSoftStroke.opacity(0.5), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(image.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.museDeep)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    MuseIconBadge(icon: image.mood.icon, text: image.mood.rawValue)
                    if let occasion = image.occasion {
                        MuseIconBadge(icon: occasion.icon, text: occasion.rawValue, tint: .museDeep)
                    }
                }

                if let style = image.styles.first {
                    MuseStyleTag(text: style.rawValue, icon: style.icon, compact: true)
                }
            }

            Spacer(minLength: 0)

            if showChevron {
                Image(systemName: "line.3.horizontal")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.65))
            }
        }
        .padding(12)
        .museElevatedShell(radius: MuseDesign.cellRadius, shadow: .lite)
    }
}

struct MuseCreateCell: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(MuseDesign.accentGradient)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.museSoftFill)
                )

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.museAccent)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.museAccent.opacity(0.1), Color.museAccent.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .foregroundColor(Color.museAccent.opacity(0.4))
        )
    }
}

struct MuseStatRow: View {
    let icon: String
    let name: String
    let count: Int
    var tint: Color = .museAccent

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.16), tint.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(tint)
            }

            Text(name)
                .font(.subheadline)
                .foregroundColor(.museDeep)

            Spacer()

            Text("\(count)")
                .font(.subheadline.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(tint))
        }
        .padding(.vertical, 4)
    }
}
