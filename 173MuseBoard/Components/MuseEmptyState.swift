import SwiftUI

struct MuseEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.museAccent.opacity(0.2), Color.museAccent.opacity(0.04)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 48
                        )
                    )
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(MuseDesign.accentGradient)
            }

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.museDeep)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let buttonTitle, let action {
                Button(action: action) {
                    Text(buttonTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(MuseDesign.accentGradient)
                        .clipShape(Capsule())
                        .museShadow(.lite)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
