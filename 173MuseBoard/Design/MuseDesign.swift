import SwiftUI

// MARK: - Tokens

enum MuseDesign {
    static let cardRadius: CGFloat = 18
    static let chipRadius: CGFloat = 20
    static let cellRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 16

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [Color.museAccent, Color.museDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradientSoft: LinearGradient {
        LinearGradient(
            colors: [Color.museAccent.opacity(0.35), Color.museDeep.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var softPageGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.97, blue: 1.0),
                Color(red: 0.98, green: 0.99, blue: 1.0),
                Color.museBackground
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardHighlightGradient: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.95), Color.white.opacity(0.55)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var glassStrokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.9),
                Color.museAccent.opacity(0.25),
                Color.museDeep.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Shadows (single layer = better scroll performance)

enum MuseShadowLevel {
    case none
    case lite
    case medium
    case elevated

    var color: Color {
        switch self {
        case .none: return .clear
        case .lite: return Color.museDeep.opacity(0.06)
        case .medium: return Color.museDeep.opacity(0.1)
        case .elevated: return Color.museAccent.opacity(0.22)
        }
    }

    var radius: CGFloat {
        switch self {
        case .none: return 0
        case .lite: return 5
        case .medium: return 10
        case .elevated: return 16
        }
    }

    var y: CGFloat {
        switch self {
        case .none: return 0
        case .lite: return 2
        case .medium: return 5
        case .elevated: return 8
        }
    }
}

extension Color {
    static let museSoftFill = Color.museAccent.opacity(0.08)
    static let museSoftStroke = Color.museAccent.opacity(0.22)
    static let museSurfaceFill = Color.white
}

// MARK: - Background

struct MuseDecorativeBackground: View {
    var body: some View {
        ZStack {
            MuseDesign.softPageGradient

            Circle()
                .fill(Color.museAccent.opacity(0.07))
                .frame(width: 280, height: 280)
                .offset(x: -140, y: -220)

            Circle()
                .fill(Color.museDeep.opacity(0.05))
                .frame(width: 220, height: 220)
                .offset(x: 160, y: 320)
        }
        .ignoresSafeArea()
    }
}

struct MusePageBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(MuseDecorativeBackground())
    }
}

// MARK: - Surfaces

struct MuseSurfaceModifier: ViewModifier {
    var radius: CGFloat = MuseDesign.cardRadius
    var padding: CGFloat = 14
    var shadow: MuseShadowLevel = .medium
    var fill: Color = .museSurfaceFill
    var gradientStroke: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
                    .shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
            )
            .overlay {
                if gradientStroke {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(MuseDesign.glassStrokeGradient, lineWidth: 1)
                }
            }
    }
}

struct MuseInsetSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.museAccent.opacity(0.07), Color.museAccent.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .stroke(Color.museSoftStroke.opacity(0.35), lineWidth: 0.5)
            )
    }
}

struct MuseShadowModifier: ViewModifier {
    let level: MuseShadowLevel

    func body(content: Content) -> some View {
        content.shadow(color: level.color, radius: level.radius, x: 0, y: level.y)
    }
}

struct MuseGradientBorderModifier: ViewModifier {
    var radius: CGFloat = MuseDesign.cardRadius
    var lineWidth: CGFloat = 1.5

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(MuseDesign.glassStrokeGradient, lineWidth: lineWidth)
        )
    }
}

// MARK: - View extensions

extension View {
    func musePageBackground() -> some View {
        modifier(MusePageBackground())
    }

    func museCardSurface(padding: CGFloat = 14, shadow: MuseShadowLevel = .medium) -> some View {
        modifier(MuseSurfaceModifier(padding: padding, shadow: shadow))
    }

    func museInsetSurface() -> some View {
        modifier(MuseInsetSurface())
    }

    /// One shadow layer — use `.lite` in grids and lists.
    func museShadow(_ level: MuseShadowLevel) -> some View {
        modifier(MuseShadowModifier(level: level))
    }

    func museGradientBorder(radius: CGFloat = MuseDesign.cardRadius) -> some View {
        modifier(MuseGradientBorderModifier(radius: radius))
    }

    /// White card shell: fill + single shadow + gradient stroke.
    func museElevatedShell(
        radius: CGFloat = MuseDesign.cardRadius,
        shadow: MuseShadowLevel = .medium
    ) -> some View {
        background(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color.museSurfaceFill)
                .shadow(color: shadow.color, radius: shadow.radius, x: 0, y: shadow.y)
        )
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(MuseDesign.glassStrokeGradient, lineWidth: 1)
        )
    }
}

// Backward-compatible alias
typealias MuseCardSurface = MuseSurfaceModifier
