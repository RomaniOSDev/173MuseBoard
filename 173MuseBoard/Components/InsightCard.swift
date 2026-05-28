import SwiftUI

struct InsightCard: View {
    let insight: StyleInsight
    var viewModel: MuseBoardViewModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(MuseDesign.accentGradient)
                        .frame(width: 48, height: 48)
                    Image(systemName: insight.style.icon)
                        .foregroundColor(.white)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.style.rawValue)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.museDeep)
                    Text("Style insight")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }

            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.museDeep)
                .fixedSize(horizontal: false, vertical: true)

            Text("Try this")
                .font(.caption.weight(.semibold))
                .foregroundColor(.museAccent)
                .textCase(.uppercase)

            VStack(spacing: 8) {
                ForEach(Array(insight.tips.enumerated()), id: \.offset) { index, tip in
                    tipRow(index: index, tip: tip)
                }
            }

            if !insight.colorPalette.isEmpty {
                Text("Palette")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.museAccent)
                    .textCase(.uppercase)

                HStack(spacing: 10) {
                    ForEach(insight.colorPalette, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .overlay(Circle().stroke(Color.museSoftStroke.opacity(0.4), lineWidth: 0.5))
                    }
                }
            }
        }
        .museCardSurface(shadow: .lite)
    }

    @ViewBuilder
    private func tipRow(index: Int, tip: String) -> some View {
        let checked = viewModel?.isTipChecked(style: insight.style, tipIndex: index) == true

        HStack(alignment: .top, spacing: 10) {
            if let viewModel {
                Button {
                    viewModel.toggleTip(style: insight.style, tipIndex: index)
                } label: {
                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                        .font(.body)
                        .foregroundColor(checked ? .museAccent : .gray.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            Text(tip)
                .font(.subheadline)
                .foregroundColor(checked ? .gray : .museDeep)
                .strikethrough(checked)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(checked ? Color.museSoftFill.opacity(0.5) : Color.museSoftFill)
        )
    }
}
