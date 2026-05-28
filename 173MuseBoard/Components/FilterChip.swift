import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var icon: String?

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .foregroundColor(isSelected ? .white : color)
        .background(chipBackground)
        .overlay(
            Capsule()
                .stroke(
                    isSelected ? Color.white.opacity(0.35) : color.opacity(0.3),
                    lineWidth: 1
                )
        )
        .museShadow(isSelected ? .lite : .none)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Capsule().fill(
                LinearGradient(
                    colors: [color, color.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            Capsule().fill(Color.white)
        }
    }
}
