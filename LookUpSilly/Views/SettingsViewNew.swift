import SwiftUI
import FamilyControls

struct SettingsViewNew: View {
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var revenueCat = RevenueCatManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
  @State private var showingResetAlert = false
  @State private var showingResetStatsAlert = false
  @State private var showingContributionSheet = false
  @State private var showingTestChallenges = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.black.ignoresSafeArea()
        
        List {
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.blockedApps,
              title: "Blocked Apps",
              subtitle: "Requires challenge to access"
            )
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .onChange(of: screenTimeManager.blockedApps) { _, newValue in
              screenTimeManager.setBlockedApps(newValue)
            }
          } header: {
            Text("App Management")
              .foregroundColor(.white)
          }
          .listRowBackground(Color.white.opacity(0.1))
          
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.allowedApps,
              title: "Always Allowed",
              subtitle: "No challenge required"
            )
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .onChange(of: screenTimeManager.allowedApps) { _, newValue in
              screenTimeManager.setAllowedApps(newValue)
            }
          } header: {
            Text("Exceptions")
              .foregroundColor(.white)
          } footer: {
            Text("These apps will bypass the challenge requirement")
              .foregroundColor(.gray)
          }
          .listRowBackground(Color.white.opacity(0.1))
          
          Section {
            if revenueCat.hasContributed {
              HStack {
                Image(systemName: "heart.circle.fill")
                  .foregroundColor(.pink)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Thank You!")
                    .foregroundColor(.white)
                    .font(.headline)
                  Text("You've contributed \(revenueCat.contributionAmount ?? "to development")")
                    .foregroundColor(.gray)
                    .font(.caption)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)
              }
            } else {
              Button(action: {
                showingContributionSheet = true
              }) {
                HStack {
                  Image(systemName: "heart.circle")
                    .foregroundColor(.pink)
                  VStack(alignment: .leading, spacing: 4) {
                    Text("Support Development")
                      .foregroundColor(.white)
                    Text("Help keep this app free")
                      .foregroundColor(.gray)
                      .font(.caption)
                  }
                  Spacer()
                  Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                }
              }
            }
          } header: {
            Text("Contribution")
              .foregroundColor(.white)
          } footer: {
            Text("Look Up, Silly! is free with no ads. Your contribution helps us continue development.")
              .foregroundColor(.gray)
          }
          .listRowBackground(Color.white.opacity(0.1))
          
          Section {
            HStack {
              Image(systemName: "info.circle")
                .foregroundColor(.blue)
              Text("How It Works")
                .foregroundColor(.white)
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
            .foregroundColor(.gray)
            .font(.caption)
          }
          .listRowBackground(Color.white.opacity(0.05))
          
          Section {
            // Stats Display
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "chart.bar.fill")
                  .foregroundColor(.green)
                Text("Total Challenges Completed")
                  .foregroundColor(.white)
                Spacer()
                Text("\(statsManager.totalChallengesCompleted)")
                  .font(.title2.bold())
                  .foregroundColor(.green)
              }
              
              Divider()
                .background(Color.gray)
              
              HStack {
                Image(systemName: "function")
                  .foregroundColor(.orange)
                Text("Math Challenges")
                  .foregroundColor(.gray)
                Spacer()
                Text("\(statsManager.mathChallengesCompleted)")
                  .foregroundColor(.white)
              }
              
              HStack {
                Image(systemName: "square.grid.3x3.fill")
                  .foregroundColor(.purple)
                Text("Tic-Tac-Toe")
                  .foregroundColor(.gray)
                Spacer()
                Text("\(statsManager.ticTacToeChallengesCompleted)")
                  .foregroundColor(.white)
              }
              
              if let lastSync = statsManager.lastSyncDate {
                Divider()
                  .background(Color.gray)
                
                HStack {
                  Image(systemName: "icloud.fill")
                    .foregroundColor(.blue)
                  Text("Last iCloud Sync")
                    .foregroundColor(.gray)
                  Spacer()
                  Text(lastSync, style: .relative)
                    .foregroundColor(.white)
                    .font(.caption)
                }
              }
            }
          } header: {
            Text("Statistics")
              .foregroundColor(.white)
          } footer: {
            Text("Your challenge completion stats sync across all your devices via iCloud")
              .foregroundColor(.gray)
          }
          .listRowBackground(Color.white.opacity(0.1))
          
          Section {
            #if DEBUG
            Button(action: {
              showingTestChallenges = true
            }) {
              HStack {
                Image(systemName: "hammer.circle")
                  .foregroundColor(.purple)
                Text("Test Challenges")
                  .foregroundColor(.purple)
                Spacer()
                Text("Development")
                  .font(.caption)
                  .foregroundColor(.gray)
              }
            }
            
            Button(action: {
              showingResetStatsAlert = true
            }) {
              HStack {
                Image(systemName: "chart.bar.xaxis")
                  .foregroundColor(.orange)
                Text("Reset Statistics")
                  .foregroundColor(.orange)
                Spacer()
                Text("Development")
                  .font(.caption)
                  .foregroundColor(.gray)
              }
            }
            #endif
            
            Button(action: {
              screenTimeManager.removeAllShields()
            }) {
              HStack {
                Image(systemName: "shield.slash")
                  .foregroundColor(.orange)
                Text("Temporarily Disable All Shields")
                  .foregroundColor(.orange)
              }
            }
            
            Button(action: {
              showingResetAlert = true
            }) {
              HStack {
                Image(systemName: "arrow.counterclockwise")
                  .foregroundColor(.red)
                Text("Reset App & Start Over")
                  .foregroundColor(.red)
              }
            }
          } header: {
            #if DEBUG
            Text("Development & Actions")
              .foregroundColor(.white)
            #else
            Text("Actions")
              .foregroundColor(.white)
            #endif
          }
          .listRowBackground(Color.white.opacity(0.1))
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
}

struct InfoRow: View {
  let number: String
  let text: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Text(number)
        .font(.caption.bold())
        .foregroundColor(.white)
        .frame(width: 20, height: 20)
        .background(Color.blue)
        .clipShape(Circle())
      
      Text(text)
        .foregroundColor(.gray)
    }
  }
}

#Preview {
  SettingsViewNew()
    .environmentObject(AppSettings())
}

