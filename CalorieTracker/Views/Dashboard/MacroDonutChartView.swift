import SwiftUI
import Charts

struct MacroDonutChartView: View {
    let protein: Double
    let carbs: Double
    let fat: Double
    let targetProtein: Double
    let targetCarbs: Double
    let targetFat: Double

    private var total: Double { protein + carbs + fat }

    var body: some View {
        HStack(spacing: 16) {
            Chart {
                BarMark(
                    x: .value("Protein", "P"),
                    y: .value("Protein", protein)
                )
                .foregroundStyle(Color.blue)
                .annotation(position: .top, alignment: .center) {
                    Text("\(Int(protein))g")
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                BarMark(
                    x: .value("Carbs", "C"),
                    y: .value("Carbs", carbs)
                )
                .foregroundStyle(Color.orange)
                .annotation(position: .top, alignment: .center) {
                    Text("\(Int(carbs))g")
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }

                BarMark(
                    x: .value("Fat", "F"),
                    y: .value("Fat", fat)
                )
                .foregroundStyle(Color.purple)
                .annotation(position: .top, alignment: .center) {
                    Text("\(Int(fat))g")
                        .font(.caption2)
                        .foregroundColor(AppTheme.secondaryTextColor)
                }
            }
            .chartYScale(domain: 0...max(max(targetProtein, targetCarbs), targetFat) * 1.3)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisValueLabel()
                }
            }
            .frame(width: 120, height: 120)
            .chartLegend(.hidden)

            VStack(alignment: .leading, spacing: 12) {
                macroLegendRow("Protein", consumed: protein, target: targetProtein, color: .blue)
                macroLegendRow("Carbs", consumed: carbs, target: targetCarbs, color: .orange)
                macroLegendRow("Fat", consumed: fat, target: targetFat, color: .purple)
            }
        }
    }

    @ViewBuilder
    private func macroLegendRow(_ name: String, consumed: Double, target: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(name)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryTextColor)

            Text("\(Int(consumed))g / \(Int(target))g")
                .font(.caption)
                .fontWeight(.medium)

            ProgressView(value: target > 0 ? consumed / target : 0)
                .tint(color)
                .frame(maxWidth: 50)
        }
    }
}
