import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var page = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("ColorBack"), Color("Colorsecond")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $page) {
                OnboardingPage(
                    image: "moon.stars.fill",
                    title: "Welcome to SilentStreak",
                    text: "Track your days of silence and mindfulness."
                ).tag(0)
                OnboardingPage(
                    image: "checkmark.seal.fill",
                    title: "Mark your silent days",
                    text: "Tap once a day when you find at least 30 minutes of silence."
                ).tag(1)
                OnboardingPage(
                    image: "note.text",
                    title: "Add notes, track progress",
                    text: "Write short notes, view your streaks and stats."
                ).tag(2)
                OnboardingPage(
                    image: "flame.fill",
                    title: "Ready to find your silence?",
                    text: "Start your journey now!"
                ).tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: page)
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") { hasSeenOnboarding = true }
                        .font(.body.bold())
                        .foregroundColor(.blue)
                        .padding(.trailing, 24)
                        .opacity(page < 3 ? 1 : 0)
                }
                Spacer()
                if page == 3 {
                    Button(action: { hasSeenOnboarding = true }) {
                        Text("Start")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.teal]), startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.blue.opacity(0.18), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let text: String
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.12), radius: 8, x: 0, y: 4)
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            Spacer()
        }
    }
} 