import SwiftUI

enum OnboardingStorage {
    static let completedKey = "museboard_onboarding_completed"
}

struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String?
    let systemImage: String
    let accent: Color
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Collect Your Looks",
            subtitle: "Save outfit photos from your library or built-in inspiration. Tag moods, styles, and occasions in seconds.",
            imageName: "presetFeatured1",
            systemImage: "photo.stack.fill",
            accent: .museAccent
        ),
        OnboardingPage(
            id: 1,
            title: "Organize Inspiration",
            subtitle: "Group favorites into boards and collections. Reorder, compare looks, and build mood boards to export.",
            imageName: "presetFeatured2",
            systemImage: "square.grid.2x2.fill",
            accent: .museDeep
        ),
        OnboardingPage(
            id: 2,
            title: "Grow Your Style",
            subtitle: "Unlock style insights, track goals, and watch your creative streak — all in one calm workspace.",
            imageName: "presetFeatured3",
            systemImage: "sparkles",
            accent: .museAccent
        )
    ]

    var body: some View {
        ZStack {
            MuseDecorativeBackground()

            VStack(spacing: 0) {
                header

                TabView(selection: $pageIndex) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: pageIndex)

                footer
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var header: some View {
        HStack {
            Spacer()
            if pageIndex < pages.count - 1 {
                Button("Skip", action: onComplete)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.museAccent)
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
        .padding(.top, 12)
        .frame(height: 44)
    }

    private var footer: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(page.id == pageIndex ? Color.museAccent : Color.museAccent.opacity(0.22))
                        .frame(width: page.id == pageIndex ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: pageIndex)
                }
            }

            if pageIndex == pages.count - 1 {
                MusePrimaryButton(title: "Get Started", icon: "arrow.right") {
                    onComplete()
                }
            } else {
                MusePrimaryButton(title: "Next", icon: "chevron.right") {
                    withAnimation {
                        pageIndex += 1
                    }
                }
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
        .padding(.bottom, 36)
        .padding(.top, 8)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 8)

            heroVisual

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.museDeep)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)

            featureChips

            Spacer(minLength: 8)
        }
    }

    @ViewBuilder
    private var heroVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [page.accent.opacity(0.12), Color.white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 340)
                .museShadow(.medium)

            if let imageName = page.imageName {
                MusePhotoView(imageName: imageName, contentMode: .fill)
                    .frame(width: 248, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
                    .museGradientBorder(radius: MuseDesign.cellRadius)
            }

            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(MuseDesign.accentGradient)
                            .frame(width: 52, height: 52)
                            .museShadow(.lite)
                        Image(systemName: page.systemImage)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 18, y: -18)
                }
                Spacer()
            }
            .frame(width: 280, height: 340)
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var featureChips: some View {
        HStack(spacing: 10) {
            ForEach(chipTitles, id: \.self) { title in
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(page.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(page.accent.opacity(0.1))
                    )
                    .overlay(
                        Capsule()
                            .stroke(page.accent.opacity(0.25), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var chipTitles: [String] {
        switch page.id {
        case 0: return ["Feed", "Tags", "Favorites"]
        case 1: return ["Boards", "Compare", "Export"]
        default: return ["Insights", "Goals", "Stats"]
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
