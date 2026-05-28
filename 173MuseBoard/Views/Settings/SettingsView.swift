import SwiftUI
import StoreKit

struct SettingsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                settingsCard
                versionFooter
            }
            .padding(.horizontal, MuseDesign.horizontalPadding)
            .padding(.vertical, 8)
        }
        .musePageBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            SettingsRow(
                title: "Rate Us",
                subtitle: "Enjoying the app? Leave a quick review.",
                icon: "star.fill",
                iconColor: .museAccent,
                showsDivider: true,
                action: rateApp
            )

            SettingsRow(
                title: "Privacy Policy",
                subtitle: "How we handle your data",
                icon: "hand.raised.fill",
                iconColor: .museDeep,
                showsDivider: true,
                action: { MuseAppLinks.privacyPolicy.open() }
            )

            SettingsRow(
                title: "Terms of Use",
                subtitle: "Rules for using the app",
                icon: "doc.text.fill",
                iconColor: .museAccent,
                showsDivider: false,
                action: { MuseAppLinks.termsOfUse.open() }
            )
        }
        .museCardSurface(shadow: .lite)
    }

    private var versionFooter: some View {
        Text("Version \(appVersion)")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    var subtitle: String?
    let icon: String
    let iconColor: Color
    var showsDivider: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [iconColor.opacity(0.18), iconColor.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        Image(systemName: icon)
                            .font(.body.weight(.semibold))
                            .foregroundColor(iconColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.museDeep)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.museAccent.opacity(0.8))
                }
                .padding(.vertical, 14)

                if showsDivider {
                    Divider()
                        .padding(.leading, 54)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
