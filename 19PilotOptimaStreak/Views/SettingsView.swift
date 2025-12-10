import SwiftUI
import SafariServices
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var storage: StorageService
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showingResetAlert = false
    @State private var showingPrivacyPolicy = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            List {
                Section {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                    .tint(.blue)
                }
                .listRowBackground(Color(.systemGray6).opacity(0.5))
                
                Section {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }
                .listRowBackground(Color(.systemGray6).opacity(0.5))
                
                Section {
                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            SKStoreReviewController.requestReview(in: scene)
                        }
                    } label: {
                        Label("Rate App", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    Button {
                        showingPrivacyPolicy = true
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
                .listRowBackground(Color(.systemGray6).opacity(0.5))
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    storage.resetAllData()
                }
            } message: {
                Text("Are you sure you want to reset all your data? This action cannot be undone.")
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                SafariView(url: URL(string: "https://www.termsfeed.com/live/4a7af84a-1b3a-4409-ad03-2a671edb4459")!)
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
} 
