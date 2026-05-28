import SwiftUI

struct MusePrimaryButton: View {
    let title: String
    var icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(MuseDesign.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
            .museShadow(.lite)
            .overlay(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
            )
        }
    }
}

struct MuseSecondaryButton: View {
    let title: String
    var icon: String?
    var tint: Color = .museAccent
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.08), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .stroke(tint.opacity(0.45), lineWidth: 1.5)
            )
        }
    }
}

struct MuseFloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(MuseDesign.accentGradient)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .museShadow(.elevated)
        }
        .padding(22)
    }
}

struct MuseFilterBarButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(isActive ? .white : .museDeep)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isActive {
                        Capsule().fill(MuseDesign.accentGradient)
                    } else {
                        Capsule().fill(Color.white)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(Color.museSoftStroke.opacity(isActive ? 0 : 0.8), lineWidth: 1)
            )
            .museShadow(isActive ? .lite : .none)
        }
    }
}
