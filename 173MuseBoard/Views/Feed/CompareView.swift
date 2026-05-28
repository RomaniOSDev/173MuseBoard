import SwiftUI

struct CompareView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    var preselectedImage: MuseImage?

    @Environment(\.dismiss) private var dismiss
    @State private var leftImage: MuseImage?
    @State private var rightImage: MuseImage?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Pick two looks to compare side by side.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, MuseDesign.horizontalPadding)

                    pickerSection(title: "Left Look", selection: $leftImage)
                    pickerSection(title: "Right Look", selection: $rightImage)

                    if let leftImage, let rightImage {
                        HStack(alignment: .top, spacing: 12) {
                            compareColumn(image: leftImage, accent: .museAccent)
                            compareColumn(image: rightImage, accent: .museDeep)
                        }
                        .padding(.horizontal, MuseDesign.horizontalPadding)
                    }
                }
                .padding(.vertical, 8)
            }
            .musePageBackground()
            .navigationTitle("Compare Looks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.museAccent)
                }
            }
            .onAppear {
                if leftImage == nil { leftImage = preselectedImage }
            }
        }
    }

    private func pickerSection(title: String, selection: Binding<MuseImage?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.museDeep)
                .padding(.horizontal, MuseDesign.horizontalPadding)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.images) { image in
                        VStack(spacing: 6) {
                            MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                                .frame(width: 76, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            selection.wrappedValue?.id == image.id
                                                ? Color.museAccent : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                            Text(image.title)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.museDeep)
                                .lineLimit(1)
                                .frame(width: 76)
                        }
                        .onTapGesture { selection.wrappedValue = image }
                    }
                }
                .padding(.horizontal, MuseDesign.horizontalPadding)
            }
        }
    }

    private func compareColumn(image: MuseImage, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            MusePhotoView(imageName: image.primaryImageName, contentMode: .fill)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous))

            Text(image.title)
                .font(.headline)
                .foregroundColor(.museDeep)
                .lineLimit(2)

            MuseIconBadge(icon: image.mood.icon, text: image.mood.rawValue, tint: accent)

            if let occasion = image.occasion {
                MuseIconBadge(icon: occasion.icon, text: occasion.rawValue, tint: .museDeep)
            }

            ForEach(image.styles.prefix(3), id: \.self) { style in
                MuseStyleTag(text: style.rawValue, icon: style.icon, compact: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .museCardSurface(padding: 12, shadow: .lite)
    }
}
