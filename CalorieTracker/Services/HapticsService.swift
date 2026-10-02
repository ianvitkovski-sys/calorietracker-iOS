import Foundation
import UIKit
import AVFAudio

@MainActor
final class HapticsService {
    static let shared = HapticsService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
    }

    func lightImpact() {
        impactLight.impactOccurred()
    }

    func mediumImpact() {
        impactMedium.impactOccurred()
    }

    func heavyImpact() {
        impactHeavy.impactOccurred()
    }

    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func photoCapture() {
        impactMedium.impactOccurred()
    }

    func photoSaved() {
        success()
    }
}
