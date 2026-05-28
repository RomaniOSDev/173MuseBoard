import UIKit

enum MuseImageStorage {
    static let localPrefix = "local:"
    private static let folderName = "MusePhotos"

    static var photosDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = documents.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    static func isLocal(_ imageName: String) -> Bool {
        imageName.hasPrefix(localPrefix)
    }

    static func fileURL(for imageName: String) -> URL? {
        guard isLocal(imageName) else { return nil }
        let fileName = String(imageName.dropFirst(localPrefix.count))
        return photosDirectory.appendingPathComponent(fileName)
    }

    static func uiImage(named imageName: String) -> UIImage? {
        if let url = fileURL(for: imageName),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        return UIImage(named: imageName)
    }

    @discardableResult
    static func saveImage(_ image: UIImage, imageId: UUID, index: Int = 0) throws -> String {
        let fileName = fileName(for: imageId, index: index)
        let url = photosDirectory.appendingPathComponent(fileName)
        guard let data = jpegData(from: image) else {
            throw StorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return localPrefix + fileName
    }

    @discardableResult
    static func saveBoardCover(_ image: UIImage, boardId: UUID) throws -> String {
        let fileName = "board_\(boardId.uuidString).jpg"
        let url = photosDirectory.appendingPathComponent(fileName)
        guard let data = jpegData(from: image) else {
            throw StorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return localPrefix + fileName
    }

    static func copyImageNames(_ names: [String], to newImageId: UUID) -> [String] {
        names.enumerated().compactMap { index, name in
            if isLocal(name), let image = uiImage(named: name) {
                return try? saveImage(image, imageId: newImageId, index: index)
            }
            return name
        }
    }

    static func deleteImageIfLocal(named imageName: String) {
        guard isLocal(imageName), let url = fileURL(for: imageName) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    static func deleteAllLocal(names: [String]) {
        names.forEach { deleteImageIfLocal(named: $0) }
    }

    static func deleteBoardCoverIfLocal(named coverName: String) {
        deleteImageIfLocal(named: coverName)
    }

    static func jpegData(from image: UIImage, maxDimension: CGFloat = 1600, quality: CGFloat = 0.85) -> Data? {
        let resized = resizedImage(image, maxDimension: maxDimension)
        return resized.jpegData(compressionQuality: quality)
    }

    private static func fileName(for imageId: UUID, index: Int) -> String {
        index == 0 ? "\(imageId.uuidString).jpg" : "\(imageId.uuidString)_\(index).jpg"
    }

    private static func resizedImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    enum StorageError: Error {
        case encodingFailed
    }
}
