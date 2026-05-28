import SwiftUI

struct InsightCardPlaceholder: View {
    let style: StyleCategory

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: style.icon)
                    .foregroundColor(.gray)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(style.rawValue)
                    .font(.headline)
                    .foregroundColor(.gray)

                Text("Add 3+ photos with this style to unlock personalized tips.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "lock.fill")
                .foregroundColor(.gray.opacity(0.4))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .fill(Color.white.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(Color.gray.opacity(0.25))
        )
        .museShadow(.lite)
    }
}
