//
//  ContentView.swift
//  SilenTStreak
//
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if hasSeenOnboarding {
                TabView {
                    TodayView()
                        .tabItem { Label("Today", systemImage: "calendar") }
                    StatsView()
                        .tabItem { Label("Stats", systemImage: "chart.bar") }
                    HistoryView()
                        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gear") }
                }
                .environmentObject(StorageService.shared)
                .preferredColorScheme(isDarkMode ? .dark : .light)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

#Preview {
    ContentView()
}
