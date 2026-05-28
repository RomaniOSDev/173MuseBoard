import UIKit

extension UIImage {
    func rotatedByQuarterTurns(_ count: Int) -> UIImage {
        let normalized = ((count % 4) + 4) % 4
        guard normalized != 0 else { return self }

        let radians = CGFloat(normalized) * .pi / 2
        var newSize = size
        if normalized % 2 == 1 {
            newSize = CGSize(width: size.height, height: size.width)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.cgContext.rotate(by: radians)
            draw(in: CGRect(
                x: -size.width / 2,
                y: -size.height / 2,
                width: size.width,
                height: size.height
            ))
        }
    }

    func squareCropped() -> UIImage {
        let side = min(size.width, size.height)
        let origin = CGPoint(
            x: (size.width - side) / 2,
            y: (size.height - side) / 2
        )
        let cropRect = CGRect(
            x: origin.x * scale,
            y: origin.y * scale,
            width: side * scale,
            height: side * scale
        )
        guard let cgImage, let cropped = cgImage.cropping(to: cropRect) else { return self }
        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }
}
