import SwiftUI

struct MuseStyleTag: View {
    let text: String
    var icon: String?
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: compact ? 9 : 10, weight: .semibold))
            }
            Text(text)
                .font(.system(size: compact ? 10 : 11, weight: .semibold))
        }
        .foregroundColor(.museDeep)
        .padding(.horizontal, compact ? 7 : 9)
        .padding(.vertical, compact ? 4 : 5)
        .background(
            Capsule()
                .fill(Color.museAccent.opacity(0.12))
        )
    }
}

struct MuseIconBadge: View {
    let icon: String
    let text: String
    var tint: Color = .museAccent

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
            Text(text)
                .font(.caption2.weight(.medium))
        }
        .foregroundColor(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(tint.opacity(0.1))
        )
    }
}
