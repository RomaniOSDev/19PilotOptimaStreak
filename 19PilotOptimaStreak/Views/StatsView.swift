import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject private var storage: StorageService
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    HStack(spacing: 18) {
                        StatCard(title: "Total Silent Days", value: "\(storage.getTotalSilentDays())", color: .green)
                        StatCard(title: "Best Streak", value: "\(storage.getBestStreak())", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    if !storage.getAchievements().isEmpty {
                        GlassCard {
                            Text("Achievements")
                                .font(.headline)
                                .padding(.top, 8)
                            HStack(spacing: 16) {
                                ForEach(storage.getAchievements(), id: \.self) { ach in
                                    Text(ach)
                                        .font(.title2)
                                        .padding(8)
                                        .background(Color.yellow.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal)
                    }
                    
                    GlassCard {
                        Text("Weekly Progress")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                        WeeklyChartView(days: storage.silenceDays)
                            .frame(height: 200)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal)
                    
                    GlassCard {
                        Text("When do you find silence?")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                        HourlyChartView(hourStats: storage.getHourStats())
                            .frame(height: 180)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 32)
            }
            .navigationTitle("")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title.bold())
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct GlassCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack { content }
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct WeeklyChartView: View {
    let days: [SilenceDay]
    
    private var weeklyData: [(week: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: days.filter { $0.wasSilent }) { day in
            calendar.startOfWeek(for: day.date)
        }
        
        return grouped.map { (week: $0.key, count: $0.value.count) }
            .sorted { $0.week < $1.week }
    }
    
    var body: some View {
        Chart(weeklyData, id: \.week) { item in
            BarMark(
                x: .value("Week", item.week),
                y: .value("Days", item.count)
            )
            .foregroundStyle(Color.blue.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(shortWeekString(for: date))
                    }
                }
            }
        }
    }
    
    private func shortWeekString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
}

struct HourlyChartView: View {
    let hourStats: [Int: Int]
    var sorted: [(Int, Int)] { hourStats.sorted { $0.0 < $1.0 } }
    var body: some View {
        Chart(sorted, id: \.0) { hour, count in
            BarMark(
                x: .value("Hour", hour),
                y: .value("Count", count)
            )
            .foregroundStyle(Color.purple.gradient)
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 8)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hour = value.as(Int.self) {
                        Text("\(hour)h")
                    }
                }
            }
        }
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components)!
    }
} 