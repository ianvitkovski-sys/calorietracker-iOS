import Foundation
import UIKit

@MainActor
final class ImageStorageService {
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    private var imagesDirectory: URL {
        documentsURL.appendingPathComponent("MealImages")
    }

    init() {
        createDirectoryIfNeeded(imagesDirectory)
    }

    private func createDirectoryIfNeeded(_ url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    func saveImage(_ image: UIImage) async throws -> String {
        let filename = "meal_\(UUID().uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)

        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "ImageStorage", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }

        try data.write(to: fileURL)
        return filename
    }

    func loadImage(named filename: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    func deleteImage(named filename: String) async throws {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func clearAllImages() async throws {
        let enumerator = fileManager.enumerator(at: imagesDirectory, includingPropertiesForKeys: nil)
        for case let fileURL as URL in enumerator! {
            try? fileManager.removeItem(at: fileURL)
        }
    }
}
