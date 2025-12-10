import Foundation
import Combine

class StorageService: ObservableObject {
    static let shared = StorageService()
    @Published private(set) var silenceDays: [SilenceDay] = []
    private let defaults = UserDefaults.standard
    private let silenceDaysKey = "silenceDays"
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        if let data = defaults.data(forKey: silenceDaysKey),
           let decoded = try? JSONDecoder().decode([SilenceDay].self, from: data) {
            silenceDays = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(silenceDays) {
            defaults.set(encoded, forKey: silenceDaysKey)
        }
    }
    
    func markTodayAsSilent(note: String? = nil) {
        guard !hasMarkedToday() else { return }
        let newDay = SilenceDay(wasSilent: true, note: note, markedAt: Date())
        silenceDays.append(newDay)
        saveData()
    }
    
    func hasMarkedToday() -> Bool {
        silenceDays.contains { $0.isToday }
    }
    
    func getCurrentStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        let today = Date()
        
        for day in silenceDays.sorted(by: { $0.date > $1.date }) {
            if day.wasSilent {
                if streak == 0 && !day.isToday && !day.isYesterday {
                    break
                }
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getBestStreak() -> Int {
        var currentStreak = 0
        var bestStreak = 0
        
        for day in silenceDays.sorted(by: { $0.date < $1.date }) {
            if day.wasSilent {
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return bestStreak
    }
    
    func getTotalSilentDays() -> Int {
        silenceDays.filter { $0.wasSilent }.count
    }
    
    func getLastSevenDays() -> [SilenceDay] {
        let calendar = Calendar.current
        let today = Date()
        let lastSevenDays = (0..<7).map { day in
            calendar.date(byAdding: .day, value: -day, to: today)!
        }
        
        return lastSevenDays.map { date in
            if let existingDay = silenceDays.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return existingDay
            } else {
                return SilenceDay(date: date, wasSilent: false)
            }
        }.reversed()
    }
    
    func resetAllData() {
        silenceDays.removeAll()
        saveData()
    }
    
    func updateNote(for date: Date, note: String) {
        if let idx = silenceDays.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            silenceDays[idx].note = note
            saveData()
        }
    }
    
    func getHistory(onlySilent: Bool = false) -> [SilenceDay] {
        let filtered = onlySilent ? silenceDays.filter { $0.wasSilent } : silenceDays
        return filtered.sorted { $0.date > $1.date }
    }
    
    func hasNote(for date: Date) -> Bool {
        silenceDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })?.note?.isEmpty == false
    }
    
    func getAchievements() -> [String] {
        let best = getBestStreak()
        let total = getTotalSilentDays()
        var result: [String] = []
        if best >= 3 { result.append("🔥 3 days streak") }
        if best >= 7 { result.append("🏅 7 days streak") }
        if total >= 30 { result.append("🌟 30 silent days") }
        return result
    }
    
    func getHourStats() -> [Int: Int] {
        // [hour: count]
        let silent = silenceDays.filter { $0.wasSilent }
        return Dictionary(grouping: silent) { Calendar.current.component(.hour, from: $0.markedAt) }
            .mapValues { $0.count }
    }
} 
