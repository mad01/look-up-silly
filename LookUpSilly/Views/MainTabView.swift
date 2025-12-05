import SwiftUI

struct MainTabView: View {
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var challengeManager = ChallengeManager()
  
  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }
      
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .environmentObject(challengeManager)
  }
}

#Preview {
  MainTabView()
    .environmentObject(AppSettings())
}

