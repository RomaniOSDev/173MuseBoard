import SwiftUI

struct MuseSectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.museDeep)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(MuseDesign.accentGradient))
                }
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }
}

struct MuseScreenHeader: View {
    let title: String
    let subtitle: String
    var trailingIcon: String?
    var trailingAction: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.museDeep)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            if let trailingIcon, let trailingAction {
                Button(action: trailingAction) {
                    Image(systemName: trailingIcon)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(MuseDesign.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .museShadow(.lite)
                }
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
        .padding(.top, 8)
    }
}
