import SwiftUI

struct ContentView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      if !appSettings.hasCompletedOnboarding {
        OnboardingViewNew()
      } else {
        MainTabView()
      }
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(AppSettings())
}

