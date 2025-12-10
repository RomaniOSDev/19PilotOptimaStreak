import Foundation

struct SilenceDay: Codable, Identifiable {
    let id: UUID
    let date: Date
    let wasSilent: Bool
    var note: String?
    let markedAt: Date
    
    init(id: UUID = UUID(), date: Date = Date(), wasSilent: Bool, note: String? = nil, markedAt: Date = Date()) {
        self.id = id
        self.date = date
        self.wasSilent = wasSilent
        self.note = note
        self.markedAt = markedAt
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    var isInCurrentWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    var isSilentDay: Bool {
        wasSilent
    }
} 