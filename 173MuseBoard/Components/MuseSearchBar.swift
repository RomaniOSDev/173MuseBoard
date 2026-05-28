import SwiftUI

struct MuseSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search…"

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(MuseDesign.accentGradientSoft)
                    .frame(width: 34, height: 34)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.museAccent)
                    .font(.subheadline.weight(.semibold))
            }

            TextField(placeholder, text: $text)
                .foregroundColor(.museDeep)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.55))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .museElevatedShell(radius: MuseDesign.chipRadius, shadow: .lite)
    }
}
