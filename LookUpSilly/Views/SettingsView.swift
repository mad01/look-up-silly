import SwiftUI

struct SettingsView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        List {
          Section {
            ForEach(InstalledApp.commonApps) { app in
              HStack {
                Image(systemName: app.icon)
                  .font(.system(size: 24))
                  .foregroundColor(colors.primary)
                  .frame(width: 40)
                
                Text(app.name)
                  .foregroundColor(colors.textPrimary)
                
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
              .foregroundColor(colors.textPrimary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Toggle(isOn: $appSettings.challengesPaused) {
              VStack(alignment: .leading, spacing: 4) {
                HStack {
                  Image(systemName: "pause.circle.fill")
                    .foregroundColor(colors.primary)
                  Text("Pause Challenges")
                    .foregroundColor(colors.textPrimary)
                }
                Text(appSettings.challengesPaused ? "Challenges are paused - all apps open freely" : "Challenges are active")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
              }
            }
          } header: {
            Text("Challenge Status")
              .foregroundColor(colors.textPrimary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Button(action: {
              appSettings.hasCompletedOnboarding = false
              appSettings.allowedApps.removeAll()
              appSettings.saveAllowedApps()
            }) {
              HStack {
                Image(systemName: "arrow.counterclockwise")
                  .foregroundColor(colors.danger)
                Text("Reset Onboarding")
                  .foregroundColor(colors.danger)
              }
            }
          }
          .listRowBackground(colors.surface)
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

