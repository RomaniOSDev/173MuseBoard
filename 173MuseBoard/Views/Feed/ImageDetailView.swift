import SwiftUI

struct ImageDetailView: View {
    @ObservedObject var viewModel: MuseBoardViewModel
    let image: MuseImage

    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showCompare = false
    @State private var newNoteText = ""
    @State private var carouselIndex = 0

    private var currentImage: MuseImage {
        viewModel.image(with: image.id) ?? image
    }

    private var palette: [ImageColorExtractor.Swatch] {
        ImageColorExtractor.dominantColors(from: currentImage.primaryImageName)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                photoCarousel
                quickActions
                infoSection
                paletteSection
                metaSection
                actionButtons
                notesSection
            }
            .padding(.bottom, 24)
        }
        .musePageBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Compare") { showCompare = true }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.museAccent)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditImageView(viewModel: viewModel, image: currentImage)
        }
        .sheet(isPresented: $showCompare) {
            CompareView(viewModel: viewModel, preselectedImage: currentImage)
        }
        .alert("Delete Photo?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteImage(currentImage)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var photoCarousel: some View {
        VStack(spacing: 10) {
            TabView(selection: $carouselIndex) {
                ForEach(Array(currentImage.imageNames.enumerated()), id: \.offset) { index, name in
                    MusePhotoView(imageName: name, contentMode: .fit)
                        .tag(index)
                        .padding(8)
                }
            }
            .frame(height: 380)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cardRadius, style: .continuous))
            .museShadow(.medium)
            .museGradientBorder()
            .padding(.horizontal, MuseDesign.horizontalPadding)

            if currentImage.imageNames.count > 1 {
                Text("Photo \(carouselIndex + 1) of \(currentImage.imageNames.count)")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.gray)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            quickActionButton(
                icon: currentImage.isFavorite ? "heart.fill" : "heart",
                title: "Favorite",
                isOn: currentImage.isFavorite
            ) { viewModel.toggleFavorite(currentImage) }

            quickActionButton(
                icon: currentImage.isSaved ? "bookmark.fill" : "bookmark",
                title: "Save",
                isOn: currentImage.isSaved
            ) { viewModel.toggleSaved(currentImage) }
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private func quickActionButton(icon: String, title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundColor(isOn ? .white : .museDeep)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isOn {
                        MuseDesign.accentGradient
                    } else {
                        Color.white
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MuseDesign.cellRadius, style: .continuous)
                    .stroke(Color.museSoftStroke, lineWidth: isOn ? 0 : 1)
            )
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentImage.title)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.museDeep)

            if !currentImage.description.isEmpty {
                Text(currentImage.description)
                    .font(.body)
                    .foregroundColor(.museDeep.opacity(0.85))
            }

            FlowLayout(spacing: 8) {
                ForEach(currentImage.styles, id: \.self) { style in
                    MuseStyleTag(text: style.rawValue, icon: style.icon)
                }
                if let occasion = currentImage.occasion {
                    MuseStyleTag(text: occasion.rawValue, icon: occasion.icon)
                }
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    @ViewBuilder
    private var paletteSection: some View {
        if !palette.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Color Palette")
                    .font(.headline)
                    .foregroundColor(.museDeep)
                HStack(spacing: 12) {
                    ForEach(palette) { swatch in
                        Circle()
                            .fill(swatch.color)
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .overlay(Circle().stroke(Color.museSoftStroke.opacity(0.35), lineWidth: 0.5))
                    }
                }
            }
            .museCardSurface(shadow: .lite)
            .padding(.horizontal, MuseDesign.horizontalPadding)
        }
    }

    private var metaSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            metaRow(icon: currentImage.mood.icon, label: "Mood", value: currentImage.mood.rawValue)
            if let occasion = currentImage.occasion {
                metaRow(icon: occasion.icon, label: "Occasion", value: occasion.rawValue)
            }
            if let photographer = currentImage.photographer {
                metaRow(icon: "camera.fill", label: "Photographer", value: photographer)
            }
            if let location = currentImage.location {
                metaRow(icon: "location.fill", label: "Location", value: location)
            }
            if let dateTaken = currentImage.dateTaken {
                metaRow(icon: "calendar", label: "Shot", value: formattedDate(dateTaken))
            }
            if let updatedAt = currentImage.updatedAt {
                metaRow(icon: "clock.arrow.circlepath", label: "Edited", value: formattedDate(updatedAt))
            }
            metaRow(icon: "plus.circle", label: "Added", value: formattedDate(currentImage.createdAt))

            if !currentImage.tags.isEmpty {
                Text("Tags")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                FlowLayout(spacing: 6) {
                    ForEach(currentImage.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.museAccent)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.museAccent.opacity(0.12)))
                    }
                }
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private func metaRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.museAccent)
                .frame(width: 22)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(.museDeep)
            Spacer(minLength: 0)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            MusePrimaryButton(title: "Edit Look", icon: "pencil") {
                showEditSheet = true
            }
            MuseSecondaryButton(title: "Duplicate", icon: "plus.square.on.square") {
                viewModel.duplicateImage(currentImage)
                dismiss()
            }
            Button("Delete Look") { showDeleteConfirmation = true }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Notes")
                .font(.headline)
                .foregroundColor(.museDeep)

            HStack(spacing: 10) {
                TextField("Write a note…", text: $newNoteText)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.museSoftFill)
                    )
                Button {
                    let trimmed = newNoteText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    viewModel.addNote(PersonalNote(
                        id: UUID(),
                        imageId: currentImage.id,
                        content: trimmed,
                        createdAt: Date()
                    ))
                    newNoteText = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(MuseDesign.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .disabled(newNoteText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            ForEach(viewModel.notes(for: currentImage.id)) { note in
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundColor(.museDeep)
                    Text(formattedDate(note.createdAt))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.museSoftFill)
                )
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteNote(note)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .museCardSurface(shadow: .lite)
        .padding(.horizontal, MuseDesign.horizontalPadding)
    }
}

/// Simple flow layout for tags and style chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
