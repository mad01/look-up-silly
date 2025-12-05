import SwiftUI

struct MainTabView: View {
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
  }
}

#Preview {
  MainTabView()
    .environmentObject(AppSettings())
}

