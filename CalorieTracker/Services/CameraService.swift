import Foundation
import UIKit
import AVFoundation
import Photos

@MainActor
final class CameraService: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isPresentingPicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera

    private let pickerController = UIImagePickerController()

    override init() {
        super.init()
        setupPicker()
    }

    private func setupPicker() {
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.imageExportPreset = .compatible
    }

    func requestCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized { return true }
        if status == .denied || status == .restricted { return false }

        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func requestPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized || status == .addOnly { return true }
        if status == .denied || status == .restricted { return false }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status == .authorized || status == .addOnly)
            }
        }
    }

    func takePhoto() async {
        let granted = await requestCameraPermission()
        if granted {
            sourceType = .camera
            isPresentingPicker = true
        }
    }

    func pickFromLibrary() async {
        let granted = await requestPhotoLibraryPermission()
        if granted {
            sourceType = .photoLibrary
            isPresentingPicker = true
        }
    }

    func saveImage(_ image: UIImage) async throws -> URL {
        let filename = "meal_\(Date().timeIntervalSince1970).jpg"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docs.appendingPathComponent(filename)

        if let data = image.jpegData(compressionQuality: 0.85) {
            try data.write(to: fileURL)
        }

        return fileURL
    }

    func loadImage(from url: URL) -> UIImage? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    func deleteImage(_ url: URL) async throws {
        try FileManager.default.removeItem(at: url)
    }
}

extension CameraService: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isPresentingPicker = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaInfo info: [UIImagePickerController.InfoKey : Any]) {
        isPresentingPicker = false

        if let image = info[.originalImage] as? UIImage {
            capturedImage = image
        }

        picker.dismiss(animated: true)
    }
}
