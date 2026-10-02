import Foundation
import SwiftData
import SwiftUI

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isPresentingPicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera
    @Published var isAnalyzing = false
    @Published var detectedFoods: [DetectedFood] = []
    @Published var errorMessage: String?
    @Published var showError = false

    weak var container: AppContainer?
    private let cameraService: CameraService
    private let foodDetectionService: FoodDetectionService
    private let imagePreprocessingService: ImagePreprocessingService

    init(container: AppContainer) {
        self.container = container
        self.cameraService = container.cameraService
        self.foodDetectionService = container.foodDetectionService as! FoodDetectionService
        self.imagePreprocessingService = container.imagePreprocessingService
    }

    func takePhoto() async {
        await cameraService.takePhoto()
        capturedImage = cameraService.capturedImage
    }

    func pickFromLibrary() async {
        await cameraService.pickFromLibrary()
        capturedImage = cameraService.capturedImage
    }

    var isPresented: Binding<Bool> {
        Binding(
            get: { isPresentingPicker },
            set: { isPresentingPicker = $0 }
        )
    }

    func analyzeImage(_ image: UIImage) async {
        isAnalyzing = true
        defer { isAnalyzing = false }

        let preprocessed = imagePreprocessingService.preprocessForDetection(image) ?? image

        foodDetectionService.detectFood(in: preprocessed) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let foods):
                    self?.detectedFoods = foods
                    if foods.isEmpty {
                        self?.errorMessage = "No food items detected. Try a different angle or lighting."
                        self?.showError = true
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }

    func clearSession() {
        capturedImage = nil
        detectedFoods = []
        errorMessage = nil
        showError = false
    }

    func navigateToResults() -> Bool {
        !detectedFoods.isEmpty
    }
}
