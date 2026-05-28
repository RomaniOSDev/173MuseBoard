import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 6 : 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.2), color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: compact ? 32 : 38, height: compact ? 32 : 38)
                    Image(systemName: icon)
                        .font(compact ? .caption : .subheadline)
                        .foregroundColor(color)
                }
                Spacer(minLength: 0)
            }

            Text(value)
                .font(.system(size: compact ? 22 : 26, weight: .bold, design: .rounded))
                .foregroundColor(.museDeep)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(compact ? 12 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .museElevatedShell(radius: MuseDesign.cardRadius, shadow: .lite)
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(color.opacity(0.12))
                .frame(width: 56, height: 56)
                .offset(x: 16, y: -16)
                .allowsHitTesting(false)
        }
    }
}
