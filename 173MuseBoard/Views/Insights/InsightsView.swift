import SwiftUI

struct InsightsView: View {
    @ObservedObject var viewModel: MuseBoardViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(MuseDesign.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .museShadow(.lite)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Style Playbook")
                                .font(.headline)
                                .foregroundColor(.museDeep)
                            Text("Check off tips as you try them — saved on device.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .museCardSurface(shadow: .lite)
                    .padding(.horizontal, MuseDesign.horizontalPadding)

                    LazyVStack(spacing: 14) {
                        ForEach(StyleCategory.allCases, id: \.self) { style in
                            if let insight = viewModel.insights.first(where: { $0.style == style }) {
                                InsightCard(insight: insight, viewModel: viewModel)
                            } else {
                                InsightCardPlaceholder(style: style)
                            }
                        }
                    }
                    .padding(.horizontal, MuseDesign.horizontalPadding)
                }
                .padding(.vertical, 8)
            }
            .musePageBackground()
            .navigationTitle("Style Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
