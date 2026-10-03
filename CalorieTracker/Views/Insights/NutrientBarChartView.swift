import SwiftUI
import Charts

struct NutrientBarChartView: View {
    let nutrients: [(name: String, value: Double, target: Double, unit: String, color: Color)]

    var body: some View {
        Chart {
            ForEach(nutrients, id: \.name) { nutrient in
                BarMark(
                    x: .value("Nutrient", nutrient.name),
                    y: .value("Amount", nutrient.value)
                )
                .foregroundStyle(nutrient.color)
                .annotation(position: .top) {
                    Text("\(Int(nutrient.value))\(nutrient.unit)")
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                if nutrient.target > 0 {
                    RuleMark(y: .value("Target", nutrient.target))
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 3]))
                        .foregroundStyle(nutrient.color.opacity(0.5))
                }
            }
        }
        .chartYScale(domain: 0...((nutrients.map(\.target).max() ?? 100) * 1.3))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: nutrients.count)) { value in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .frame(height: 200)
        .chartLegend(.visible)
    }
}
