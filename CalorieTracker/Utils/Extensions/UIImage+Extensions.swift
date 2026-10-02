import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageRenderer(size: size)
        let image = UIGraphicsImageRenderer(format: self.imageRendererFormat).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        UIGraphicsEndImageRenderer()
        return image
    }

    func rotated(by degrees: CGFloat) -> UIImage? {
        let radians = degrees * .pi / 180
        let rotatedSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            .applying(CGAffineTransform(rotationAngle: radians)).insetBy(dx: 0, dy: 0)

        UIGraphicsBeginImageRenderer(rotatedSize)
        let image = UIGraphicsImageRenderer(format: self.imageRendererFormat).image { ctx in
            ctx.cgContext.translateBy(x: rotatedSize.midX, y: rotatedSize.midY)
            ctx.cgContext.rotate(by: radians)
            self.draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
        UIGraphicsEndImageRenderer()
        return image
    }

    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    var aspectRatio: CGFloat {
        return size.width / size.height
    }

    static func fromBase64(_ base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }

    func toBase64(compression: CGFloat = 0.85) -> String? {
        return jpegData(compressionQuality: compression)?.base64EncodedString()
    }
}
