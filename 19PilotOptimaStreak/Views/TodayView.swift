import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var storage: StorageService
    @State private var animateStreak = false
    @State private var showNoteSheet = false
    @State private var noteText = ""
    
    private let silenceQuotes: [String] = [
        "Silence is a source of great strength. — Lao Tzu",
        "In the silence of the heart, God speaks. — Mother Teresa",
        "The quieter you become, the more you can hear. — Ram Dass",
        "Silence is sometimes the best answer.",
        "Listen to silence. It has so much to say.",
        "Within yourself is a stillness, a sanctuary. — Hermann Hesse",
        "True silence is the rest of the mind. — William Penn",
        "Sometimes you just need a break. In a beautiful place. Alone. To figure everything out.",
        "All man's miseries derive from not being able to sit in a quiet room alone. — Blaise Pascal",
        "Quiet the mind, and the soul will speak. — Ma Jaya Sati Bhagavati"
    ]

    private func quoteOfTheDay() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let hash = abs(today.hashValue)
        return silenceQuotes[hash % silenceQuotes.count]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text("Did you find silence today?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .foregroundStyle(LinearGradient(colors: [Color.primary, Color.blue.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                
                VStack(spacing: 12) {
                    Text("Quote of the day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(quoteOfTheDay())
                        .font(.body.italic())
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .background(Color(.systemGray6).opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal)
                
                VStack(spacing: 18) {
                    HStack(spacing: 10) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 2)
                            .scaleEffect(animateStreak ? 1.25 : 1.0)
                            .opacity(animateStreak ? 0.7 : 1.0)
                            .animation(.easeOut(duration: 0.4), value: animateStreak)
                        Text("\(storage.getCurrentStreak()) days in a row")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .orange.opacity(0.08), radius: 8, x: 0, y: 2)
                    
                    Text("Best streak: \(storage.getBestStreak()) days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6).opacity(0.7))
                        .clipShape(Capsule())
                }
                
                Button(action: {
                    if !storage.hasMarkedToday() {
                        showNoteSheet = true
                    }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.white)
                        Text("Yes, I did")
                            .font(.title3.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        if storage.hasMarkedToday() {
                            Color.gray.opacity(0.18)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.teal]), startPoint: .leading, endPoint: .trailing)
                        }
                    }
                    .foregroundColor(storage.hasMarkedToday() ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color.blue.opacity(storage.hasMarkedToday() ? 0 : 0.18), radius: 8, x: 0, y: 4)
                }
                .disabled(storage.hasMarkedToday())
                .padding(.horizontal)
                .animation(.easeInOut, value: storage.hasMarkedToday())
                
                WeekCalendarView(days: storage.getLastSevenDays())
                    .padding(.horizontal, 8)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            NoteInputSheet(noteText: $noteText) { note in
                storage.markTodayAsSilent(note: note)
                animateStreak = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateStreak = false
                }
            }
        }
    }
}

struct WeekCalendarView: View {
    let days: [SilenceDay]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(days, id: \.id) { day in
                    Text(shortWeekday(for: day.date))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            HStack {
                ForEach(days) { day in
                    ZStack {
                        Circle()
                            .fill(
                                day.wasSilent
                                ? AnyShapeStyle(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]), startPoint: .top, endPoint: .bottom))
                                : AnyShapeStyle(Color.red.opacity(0.12))
                            )
                            .frame(width: 34, height: 34)
                            .shadow(color: day.wasSilent ? Color.green.opacity(0.18) : .clear, radius: 6, x: 0, y: 2)
                        if day.wasSilent {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.red)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
    
    private func shortWeekday(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

struct NoteInputSheet: View {
    @Binding var noteText: String
    var onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add a note (optional)")
                    .font(.headline)
                TextEditor(text: $noteText)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .focused($isTextEditorFocused)
                Spacer()
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextEditorFocused = true
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(noteText)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                }
            }
        }
    }
} 
