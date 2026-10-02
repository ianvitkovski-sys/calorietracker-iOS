import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel(container: AppContainer.shared)
    @State private var showActionSheet = false
    @State private var navigationPath = NavigationPath()
    @State private var mealResultsViewModel: MealResultsViewModel?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                } else {
                    cameraPreviewPlaceholder
                }

                if viewModel.isAnalyzing {
                    LoadingOverlay(message: "Analyzing your meal...", progress: nil)
                }
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.detectedFoods) { _, foods in
                if !foods.isEmpty && !viewModel.isAnalyzing {
                    mealResultsViewModel = MealResultsViewModel(
                        container: viewModel.container ?? AppContainer.shared,
                        detectedFoods: foods,
                        image: viewModel.capturedImage ?? UIImage()
                    )
                    navigationPath.append("results")
                }
            }
            .sheet(isPresented: $viewModel.isPresentingPicker) {
                ImagePickerView(sourceType: viewModel.sourceType, selectedImage: $viewModel.capturedImage)
            }
        .confirmationDialog("Add Photo", isPresented: $showActionSheet, actions: {
            Button("Take Photo") {
                Task { await viewModel.takePhoto() }
            }
            Button("Photo Library") {
                Task { await viewModel.pickFromLibrary() }
            }
            Button("Cancel", role: .cancel) { }
        })
            .onAppear {
                showActionSheet = true
            }
            .onDisappear {
                viewModel.clearSession()
            }
            .navigationDestination(for: String.self) { route in
                if route == "results", let resultsVM = mealResultsViewModel {
                    MealResultsView(viewModel: resultsVM)
                }
            }
        }
    }

    @ViewBuilder
    private var cameraPreviewPlaceholder: some View {
        VStack {
            Spacer()
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            Text("Capture or select a meal photo")
                .font(.headline)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
    }
}



