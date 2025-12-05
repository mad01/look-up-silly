import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var appSettings: AppSettings
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.black.ignoresSafeArea()
        
        List {
          Section {
            ForEach(InstalledApp.commonApps) { app in
              HStack {
                Image(systemName: app.icon)
                  .font(.system(size: 24))
                  .foregroundColor(.blue)
                  .frame(width: 40)
                
                Text(app.name)
                  .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                  get: { appSettings.allowedApps.contains(app.bundleId) },
                  set: { isOn in
                    if isOn {
                      appSettings.addAllowedApp(app.bundleId)
                    } else {
                      appSettings.removeAllowedApp(app.bundleId)
                    }
                  }
                ))
              }
            }
          } header: {
            Text("Allowed Apps")
              .foregroundColor(.white)
          }
          .listRowBackground(Color.white.opacity(0.1))
          
          Section {
            Button(action: {
              appSettings.hasCompletedOnboarding = false
              appSettings.allowedApps.removeAll()
              appSettings.saveAllowedApps()
            }) {
              HStack {
                Image(systemName: "arrow.counterclockwise")
                  .foregroundColor(.red)
                Text("Reset Onboarding")
                  .foregroundColor(.red)
              }
            }
          }
          .listRowBackground(Color.white.opacity(0.1))
        }
        .scrollContentBackground(.hidden)
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#Preview {
  SettingsView()
    .environmentObject(AppSettings())
}

