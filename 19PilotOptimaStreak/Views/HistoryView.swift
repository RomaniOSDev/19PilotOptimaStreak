import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var storage: StorageService
    @State private var showOnlySilent = false
    @State private var selectedDay: SilenceDay?
    @State private var noteText: String = ""
    @State private var showNoteSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            NavigationView {
                VStack {
                    Picker("Filter", selection: $showOnlySilent) {
                        Text("All").tag(false)
                        Text("Silent only").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    List(storage.getHistory(onlySilent: showOnlySilent)) { day in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dateString(day.date))
                                    .font(.headline)
                                if let note = day.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            if day.wasSilent {
                                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.seal").foregroundColor(.red)
                            }
                            if let note = day.note, !note.isEmpty {
                                Image(systemName: "note.text").foregroundColor(.blue)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .navigationTitle("History")
                .sheet(isPresented: $showNoteSheet, onDismiss: {
                    selectedDay = nil
                    noteText = ""
                }) {
                    if let day = selectedDay {
                        NoteSheet(day: day, initialText: day.note ?? "") { newNote in
                            storage.updateNote(for: day.date, note: newNote)
                        }
                    }
                }
            }
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct NoteSheet: View {
    let day: SilenceDay
    let initialText: String
    var onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Note for \(dateString(day.date))")
                    .font(.headline)
                TextEditor(text: $noteText)
                    .frame(height: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                Spacer()
            }
            .padding()
            .onAppear { noteText = initialText }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(noteText)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 