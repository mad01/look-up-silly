import SwiftUI

struct MainTabView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  
  var body: some View {
    TabView {
      HomeViewNew()
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }
      
      SettingsViewNew()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
    }
    .tint(colors.primary)
  }
}

#Preview {
  MainTabView()
    .environmentObject(AppSettings())
}

