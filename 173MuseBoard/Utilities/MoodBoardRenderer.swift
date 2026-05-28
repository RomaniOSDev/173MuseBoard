import UIKit

enum MoodBoardRenderer {
    enum GridSize: Int {
        case two = 2
        case three = 3

        var cellCount: Int { rawValue * rawValue }
    }

    static func collage(imageNames: [String], grid: GridSize) -> UIImage? {
        let names = Array(imageNames.prefix(grid.cellCount))
        guard !names.isEmpty else { return nil }

        let canvasSize = CGSize(width: 1200, height: 1200)
        let columns = grid.rawValue
        let cellWidth = canvasSize.width / CGFloat(columns)
        let cellHeight = canvasSize.height / CGFloat(columns)

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { _ in
            UIColor.white.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: canvasSize)).fill()

            for (index, name) in names.enumerated() {
                guard let image = MuseImageStorage.uiImage(named: name) else { continue }
                let row = index / columns
                let col = index % columns
                let rect = CGRect(
                    x: CGFloat(col) * cellWidth,
                    y: CGFloat(row) * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                ).insetBy(dx: 4, dy: 4)

                image.draw(in: aspectFillRect(image: image, in: rect))
            }
        }
    }

    private static func aspectFillRect(image: UIImage, in rect: CGRect) -> CGRect {
        let imageRatio = image.size.width / image.size.height
        let rectRatio = rect.width / rect.height
        var drawRect = rect
        if imageRatio > rectRatio {
            let width = rect.height * imageRatio
            drawRect.origin.x -= (width - rect.width) / 2
            drawRect.size.width = width
        } else {
            let height = rect.width / imageRatio
            drawRect.origin.y -= (height - rect.height) / 2
            drawRect.size.height = height
        }
        return drawRect
    }
}
