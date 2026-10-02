import Foundation
import UIKit
import CoreImage
import Vision

final class ImagePreprocessingService {
    private let context = CIContext()

    func preprocessForDetection(_ image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        var outputImage = ciImage

        let filter = CIFilter.automaticColorAdjustment()
        filter.inputImage = ciImage
        if let output = filter.outputImage {
            outputImage = output
        }

        let orientation = CIImageOrientation(image.imageOrientation)
        outputImage = outputImage.oriented(orientation)

        let resizeFilter = CIFilter(name: "CILanczosScaleTransform")!
        resizeFilter.setValue(outputImage, forKey: kCIInputImageKey)
        resizeFilter.setValue(320.0 / outputImage.extent.width, forKey: kCIInputScaleKey)

        if let scaled = resizeFilter.value(forKey: kCIOutputImageKey) as? CIImage {
            outputImage = scaled
        }

        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func preprocessForWeightEstimation(_ image: UIImage) -> (image: UIImage, depthData: Data?) {
        return (image, nil)
    }

    func cropToBoundingBox(_ image: UIImage, boundingBox: CGRect) -> UIImage? {
        let imageSize = image.size
        let rect = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: boundingBox.origin.y * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )

        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func resize(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageRenderer(size: size)
        let image = UIGraphicsImageRenderer(format: image.imageRendererFormat).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        UIGraphicsEndImageRenderer()
        return image
    }

    func extractDepth(from image: UIImage) -> Data? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let depthFilter = CIFilter(name: "CIDepthToDisplacementMap")
        depthFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        return nil
    }
}

private extension CIImageOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
