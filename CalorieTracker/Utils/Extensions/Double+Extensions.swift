import Foundation

extension Double {
    func rounded(to places: Int = 1) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func asCalories() -> String {
        "\(Int(self)) kcal"
    }

    func asGram() -> String {
        let rounded = self.rounded(to: 1)
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(self)) g"
        }
        return "\(rounded) g"
    }

    func asPercent() -> String {
        "\(Int(self * 100))%"
    }

    func asMilligram() -> String {
        "\(Int(self)) mg"
    }

    func asMicrogram() -> String {
        let value = self / 1000.0
        if value >= 1 {
            return "\(Int(value)) mcg"
        }
        return "\(Int(self)) mcg"
    }

    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }

    func toProgress() -> Double {
        clamped(to: 0...1)
    }
}

extension Int {
    func asCalories() -> String {
        "\(self) kcal"
    }
}
