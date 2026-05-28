import SwiftUI

struct ImageEditorView: View {
    let sourceImage: UIImage
    let onApply: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var rotationSteps = 0
    @Environment(\.dismiss) private var dismiss

    private var previewImage: UIImage {
        sourceImage.rotatedByQuarterTurns(rotationSteps)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .cornerRadius(12)
                    .padding()

                HStack(spacing: 24) {
                    Button {
                        rotationSteps = (rotationSteps + 3) % 4
                    } label: {
                        Label("Rotate Left", systemImage: "rotate.left")
                    }
                    .foregroundColor(.museAccent)

                    Button {
                        rotationSteps = (rotationSteps + 1) % 4
                    } label: {
                        Label("Rotate Right", systemImage: "rotate.right")
                    }
                    .foregroundColor(.museAccent)
                }

                Button("Crop to Square") {
                    onApply(previewImage.squareCropped())
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.museAccent.opacity(0.15))
                .foregroundColor(.museAccent)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .background(Color.museBackground)
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundColor(.museAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(previewImage)
                        dismiss()
                    }
                    .foregroundColor(.museAccent)
                }
            }
        }
    }
}
