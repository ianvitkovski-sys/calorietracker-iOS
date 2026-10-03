import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    let onDateSelected: (Date) -> Void

    @State private var currentMonth = Date()
    private let calendar = Calendar.current

    private var daysInMonth: Int {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return 30 }
        return range.count
    }

    private var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        return calendar.date(from: components)!
    }

    private var weekdayOfFirst: Int {
        calendar.component(.weekday, from: firstDayOfMonth)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundColor(AppTheme.primaryColor)
                }

                Spacer()

                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.headline)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppTheme.primaryColor)
                }
            }

            HStack(spacing: 4) {
                ForEach(Calendar.current.standaloneWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.secondaryTextColor)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<(weekdayOfFirst - 1 + daysInMonth), id: \.self) { index in
                    if index < weekdayOfFirst - 1 {
                        Color.clear
                            .frame(height: 36)
                    } else {
                        let day = index - (weekdayOfFirst - 1) + 1
                        let date = calendar.date(from: DateComponents(
                            year: calendar.component(.year, from: currentMonth),
                            month: calendar.component(.month, from: currentMonth),
                            day: day
                        )) ?? currentMonth
                        dayView(date: date)
                    }
                }
            }
        }
        .padding()
    }

    @ViewBuilder
    private func dayView(date: Date) -> some View {
        Button(action: {
            selectedDate = date
            onDateSelected(date)
        }) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(date.isToday() ? .bold : .regular)
                    .foregroundColor(date.isToday() ? .white : AppTheme.textColor)
                    .frame(width: 32, height: 32)
                    .background(date.isToday() ? AppTheme.primaryColor : Color.clear)
                    .cornerRadius(16)

                if calendar.isDate(date, inSameDayAs: selectedDate) {
                    Circle()
                        .fill(AppTheme.primaryColor)
                        .frame(width: 4, height: 4)
                } else {
                    Color.clear
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 36)
        }
        .buttonStyle(.plain)
    }

    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
    }

    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
    }

    private var monthYearFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }
}
