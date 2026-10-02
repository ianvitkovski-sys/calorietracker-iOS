import SwiftUI

struct FoodDetectionPreviews: View {
    let detectedFoods: [DetectedFood]
    let image: UIImage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detected Foods")
                .font(.headline)
                .foregroundColor(AppTheme.textColor)

            ForEach(Array(detectedFoods.prefix(AppConstants.maxDetectedFoods))) { food in
                detectedFoodRow(food: food, image: image)
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.smallCornerRadius)
    }

    @ViewBuilder
    private func detectedFoodRow(food: DetectedFood, image: UIImage) -> some View {
        HStack(spacing: 12) {
            if let croppedImage = cropImage(image, to: food.boundingBox) {
                Image(uiImage: croppedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.systemGray5))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.secondaryTextColor)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(FoodClassMapper.getFoodName(for: food.className))
                    .font(.subheadline)
                    .fontWeight(.medium)

                ConfidenceIndicator(confidence: food.confidence)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.secondaryTextColor)
                .font(.caption)
        }
    }

    private func cropImage(_ image: UIImage, to boundingBox: CGRect) -> UIImage? {
        let imageSize = image.size
        let rect = CGRect(
            x: boundingBox.origin.x * imageSize.width,
            y: boundingBox.origin.y * imageSize.height,
            width: boundingBox.width * imageSize.width,
            height: boundingBox.height * imageSize.height
        )

        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

#Preview {
    FoodDetectionPreviews(
        detectedFoods: PreviewData.sampleDetectedFoods,
        image: UIImage(systemName: "photo")!
    )
}
