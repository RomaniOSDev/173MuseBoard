import SwiftUI
import UIKit

enum ImageColorExtractor {
    struct Swatch: Identifiable {
        let id = UUID()
        let hex: String
        var color: Color { Color(hex: hex) }
    }

    static func dominantColors(from imageName: String, count: Int = 5) -> [Swatch] {
        guard let image = MuseImageStorage.uiImage(named: imageName) else { return [] }
        guard let cgImage = image.cgImage else { return [] }

        let sampleSize = 40
        let width = sampleSize
        let height = sampleSize
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return [] }

        context.interpolationQuality = .low
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var buckets: [String: Int] = [:]
        for y in stride(from: 0, to: height, by: 2) {
            for x in stride(from: 0, to: width, by: 2) {
                let offset = (y * width + x) * bytesPerPixel
                let r = rawData[offset]
                let g = rawData[offset + 1]
                let b = rawData[offset + 2]
                let qr = (r / 32) * 32
                let qg = (g / 32) * 32
                let qb = (b / 32) * 32
                let key = String(format: "#%02X%02X%02X", qr, qg, qb)
                buckets[key, default: 0] += 1
            }
        }

        return buckets
            .sorted { $0.value > $1.value }
            .prefix(count)
            .map { Swatch(hex: $0.key) }
    }
}
