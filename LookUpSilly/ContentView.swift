import SwiftUI

struct ContentView: View {
  @EnvironmentObject var appSettings: AppSettings
  
  var body: some View {
    if !appSettings.hasCompletedOnboarding {
      OnboardingView()
    } else {
      MainTabView()
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(AppSettings())
}

