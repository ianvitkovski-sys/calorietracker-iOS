import Foundation
import UIKit

@MainActor
final class FoodDetectionService {
    @Published var isModelLoaded = false
    @Published var useMockMode = false

    init() {
        #if DEBUG
        useMockMode = true
        #else
        isModelLoaded = loadCoreMLModel()
        useMockMode = !isModelLoaded
        #endif
    }

    private func loadCoreMLModel() -> Bool {
        return false
    }

    func detectFood(in image: UIImage, completion: @escaping (Result<[DetectedFood], DetectionError>) -> Void) {
        if useMockMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion(.success(PreviewData.sampleDetectedFoods))
            }
            return
        }

        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }

        // Production: Use Vision + CoreML
        // guard let model = try? VNCoreMLModel(for: FoodDetector().model) else {
        //     completion(.failure(.modelNotLoaded))
        //     return
        // }
        //
        // let request = VNCoreMLRequest(model: model) { request, _ in
        //     guard let observations = request.results as? [VNRecognizedObjectObservation] else { return }
        //     let foods = self.extractDetectedFoods(from: observations, imageSize: image.size)
        //     completion(.success(foods))
        // }
        // request.imageCropAndScaleOption = .centerCrop
        //
        // let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        // Task {
        //     do {
        //         try await handler.perform([request])
        //     } catch {
        //         await MainActor.run {
        //             completion(.failure(.processingFailed(error)))
        //         }
        //     }
        // }

        // Fallback to mock if model not available
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion(.success(PreviewData.sampleDetectedFoods))
        }
    }

    private func extractDetectedFoods(from observations: [Any], imageSize: CGSize) -> [DetectedFood] {
        return PreviewData.sampleDetectedFoods
    }
}
