import SwiftUI
import FamilyControls

struct SettingsViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var revenueCat = RevenueCatManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
  @State private var showingResetAlert = false
  @State private var showingResetStatsAlert = false
  @State private var showingContributionSheet = false
  @State private var showingTestChallenges = false
  @State private var showingPauseDurationSheet = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        List {
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.blockedApps,
              title: "Blocked Apps",
              subtitle: "Requires challenge to access"
            )
            .onChange(of: screenTimeManager.blockedApps) { _, newValue in
              screenTimeManager.setBlockedApps(newValue)
            }
          } header: {
            Text("App Management")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Tip: Use the search bar in the app picker to quickly find your installed apps. Empty categories can be ignored.")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.allowedApps,
              title: "Always Allowed",
              subtitle: "No challenge required"
            )
            .onChange(of: screenTimeManager.allowedApps) { _, newValue in
              screenTimeManager.setAllowedApps(newValue)
            }
          } header: {
            Text("Exceptions")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("These apps will bypass the challenge requirement")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Button(action: {
              showingPauseDurationSheet = true
            }) {
              HStack {
                Image(systemName: appSettings.challengesPaused ? "clock.fill" : "pause.circle.fill")
                  .foregroundColor(appSettings.challengesPaused ? colors.warning : colors.primary)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(appSettings.challengesPaused ? "Manage Pause" : "Pause Challenges")
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  if appSettings.challengesPaused {
                    if let endTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date {
                      Text("Auto-resumes \(endTime, style: .relative)")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                    } else {
                      Text("Paused indefinitely")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                    }
                  } else {
                    Text("Challenges are active")
                      .font(.caption)
                      .foregroundColor(colors.textSecondary)
                  }
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ChallengesPausedStateChanged"))) { _ in
              // Update shields when state changes from quick action
              let isPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
              handlePauseStateChange(isPaused)
            }
          } header: {
            Text("Challenge Status")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Temporarily pause all challenges without removing your blocked apps list")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "xmark.circle")
                  .foregroundColor(colors.info)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text("Cancel Button Delay")
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text("Show cancel button after \(appSettings.challengeCancelDelaySeconds) seconds")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
              }
              
              Picker("", selection: $appSettings.challengeCancelDelaySeconds) {
                Text("60").tag(60)
                Text("90").tag(90)
                Text("120").tag(120)
                Text("180").tag(180)
              }
              .pickerStyle(.segmented)
            }
          } header: {
            Text("Challenge Settings")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Control when the cancel button appears in challenges. Always visible in Play for Fun mode.")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            if revenueCat.hasContributed {
              HStack {
                Image(systemName: "heart.circle.fill")
                  .foregroundColor(colors.premium)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Thank You!")
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text("You've contributed \(revenueCat.contributionAmount ?? "to development")")
                    .foregroundColor(colors.textSecondary)
                    .font(.caption)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(colors.success)
              }
            } else {
              Button(action: {
                showingContributionSheet = true
              }) {
                HStack {
                  Image(systemName: "heart.circle")
                    .foregroundColor(colors.premium)
                  VStack(alignment: .leading, spacing: 4) {
                    Text("Support Development")
                      .foregroundColor(colors.textPrimary)
                    Text("Help keep this app free")
                      .foregroundColor(colors.textSecondary)
                      .font(.caption)
                  }
                  Spacer()
                  Image(systemName: "chevron.right")
                    .foregroundColor(colors.textSecondary)
                }
              }
            }
          } header: {
            Text("Contribution")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Look Up, Silly! is free with no ads. Your contribution helps us continue development.")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "info.circle")
                  .foregroundColor(colors.info)
                Text("How It Works")
                  .foregroundColor(colors.textPrimary)
                  .font(.headline)
              }
              
              VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                  number: "1",
                  text: "Blocked apps will show a shield when you try to open them"
                )
                InfoRow(
                  number: "2",
                  text: "Open Look Up, Silly! and complete a challenge"
                )
                InfoRow(
                  number: "3",
                  text: "All blocked apps unlock for 5 minutes"
                )
                InfoRow(
                  number: "4",
                  text: "After 5 minutes, protection reactivates"
                )
              }
              .foregroundColor(colors.textSecondary)
              .font(.caption)
            }
          }
          .listRowBackground(colors.surface)
          
          Section {
            // Stats Display
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "chart.bar.fill")
                  .foregroundColor(colors.success)
                Text("Total Challenges Completed")
                  .foregroundColor(colors.textPrimary)
                Spacer()
                Text("\(statsManager.totalChallengesCompleted)")
                  .font(.title2.bold())
                  .foregroundColor(colors.success)
              }
              
              Divider()
                .background(colors.divider)
              
              HStack {
                Image(systemName: "function")
                  .foregroundColor(colors.mathChallenge)
                Text("Math Challenges")
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.mathChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: "square.grid.3x3.fill")
                  .foregroundColor(colors.ticTacToe)
                Text("Tic-Tac-Toe")
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.ticTacToeChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: "square.grid.4x4.fill")
                  .foregroundColor(colors.micro2048)
                Text("Micro 2048")
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.micro2048ChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              if let lastSync = statsManager.lastSyncDate {
                Divider()
                  .background(colors.divider)
                
                HStack {
                  Image(systemName: "icloud.fill")
                    .foregroundColor(colors.info)
                  Text("Last iCloud Sync")
                    .foregroundColor(colors.textSecondary)
                  Spacer()
                  Text(lastSync, style: .relative)
                    .foregroundColor(colors.textPrimary)
                    .font(.caption)
                }
              }
            }
          } header: {
            Text("Statistics")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Your challenge completion stats sync across all your devices via iCloud")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            #if DEBUG
            Button(action: {
              showingTestChallenges = true
            }) {
              HStack {
                Image(systemName: "hammer.circle")
                  .foregroundColor(colors.secondary)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Test Challenges")
                    .foregroundColor(colors.textPrimary)
                  Text("Development")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Button(action: {
              showingResetStatsAlert = true
            }) {
              HStack {
                Image(systemName: "chart.bar.xaxis")
                  .foregroundColor(colors.warning)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Reset Statistics")
                    .foregroundColor(colors.textPrimary)
                  Text("Development")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            #endif
            
            Button(action: {
              screenTimeManager.removeAllShields()
            }) {
              HStack {
                Image(systemName: "shield.slash")
                  .foregroundColor(colors.warning)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Temporarily Disable All Shields")
                    .foregroundColor(colors.textPrimary)
                  Text("Removes shields until next app launch")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Button(action: {
              showingResetAlert = true
            }) {
              HStack {
                Image(systemName: "arrow.counterclockwise")
                  .foregroundColor(colors.danger)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Reset App & Start Over")
                    .foregroundColor(colors.textPrimary)
                  Text("Clear all settings and blocks")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
          } header: {
            #if DEBUG
            Text("Development & Actions")
              .foregroundColor(colors.textPrimary)
            #else
            Text("Actions")
              .foregroundColor(colors.textPrimary)
            #endif
          }
          .listRowBackground(colors.surface)
        }
        .scrollContentBackground(.hidden)
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $showingContributionSheet) {
        ContributionView(onComplete: {
          showingContributionSheet = false
        })
      }
      .sheet(isPresented: $showingTestChallenges) {
        ChallengeTestView(isDevelopment: true)
      }
      .overlay {
        if showingPauseDurationSheet {
          PauseDurationSheet(isPresented: $showingPauseDurationSheet)
            .environmentObject(appSettings)
            .transition(.opacity)
        }
      }
      .alert("Reset App?", isPresented: $showingResetAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Reset", role: .destructive) {
          screenTimeManager.removeAllShields()
          appSettings.hasCompletedOnboarding = false
          appSettings.allowedApps.removeAll()
          appSettings.saveAllowedApps()
        }
      } message: {
        Text("This will remove all app blocks and reset the app. You'll need to go through onboarding again.")
      }
      .alert("Reset Statistics?", isPresented: $showingResetStatsAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Reset", role: .destructive) {
          statsManager.resetStats()
        }
      } message: {
        Text("This will reset all your challenge completion statistics and remove them from iCloud.")
      }
    }
  }
  
  private func handlePauseStateChange(_ isPaused: Bool) {
    if isPaused {
      screenTimeManager.removeAllShields()
    } else {
      screenTimeManager.updateShielding()
    }
    
    // Update home screen quick actions
    NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
  }
}

struct InfoRow: View {
  @Environment(\.themeColors) private var colors
  let number: String
  let text: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Text(number)
        .font(.caption.bold())
        .foregroundColor(colors.textOnAccent)
        .frame(width: 20, height: 20)
        .background(colors.primary)
        .clipShape(Circle())
      
      Text(text)
        .foregroundColor(colors.textSecondary)
    }
  }
}

#Preview {
  SettingsViewNew()
    .environmentObject(AppSettings())
}

