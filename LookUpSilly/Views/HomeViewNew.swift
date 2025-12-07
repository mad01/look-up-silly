import SwiftUI
import FamilyControls

struct HomeViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var challengeManager = ChallengeManager()
  @StateObject private var statsManager = ChallengeStatsManager.shared
  @State private var showingChallengeSheet = false
  @State private var showingPlayForFun = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header with Stats
            VStack(spacing: 16) {
              Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
              
              Text("Look Up, Silly!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colors.textPrimary)
              
              // Prominent Stats Counter
              VStack(spacing: 8) {
                HStack(spacing: 4) {
                  Image(systemName: "checkmark.shield.fill")
                    .font(.title2)
                    .foregroundColor(colors.success)
                  
                  Text("\(statsManager.totalChallengesCompleted)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(colors.success)
                    .contentTransition(.numericText())
                  
                  Text("Times Saved")
                    .font(.title3.bold())
                    .foregroundColor(colors.textPrimary)
                }
                
                Text("Challenges completed to stay focused")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
              }
              .padding()
              .background(colors.success.opacity(0.15))
              .cornerRadius(12)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(colors.success.opacity(0.3), lineWidth: 1)
              )
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
            
            // Status Card
            StatusCard(
              blockedCount: screenTimeManager.blockedApps.applicationTokens.count,
              allowedCount: screenTimeManager.allowedApps.applicationTokens.count
            )
            
            // Quick Unlock Section or Paused Status
            if appSettings.challengesPaused {
              VStack(alignment: .leading, spacing: 16) {
                Text("Challenges Paused")
                  .font(.title2.bold())
                  .foregroundColor(colors.textPrimary)
                  .padding(.horizontal, 20)
                
                HStack {
                  Image(systemName: "pause.circle.fill")
                    .font(.title)
                    .foregroundColor(colors.warning)
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text("All apps are accessible")
                      .font(.headline)
                      .foregroundColor(colors.textPrimary)
                    Text("Go to Settings to resume challenges")
                      .font(.caption)
                      .foregroundColor(colors.textSecondary)
                  }
                  
                  Spacer()
                }
                .padding()
                .background(colors.warning.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(colors.warning, lineWidth: 2)
                )
                .padding(.horizontal, 20)
              }
            } else {
              VStack(alignment: .leading, spacing: 16) {
                Text("Need Access?")
                  .font(.title2.bold())
                  .foregroundColor(colors.textPrimary)
                  .padding(.horizontal, 20)
                
                Text("Complete a challenge to temporarily unlock blocked apps for 5 minutes")
                  .font(.subheadline)
                  .foregroundColor(colors.textSecondary)
                  .padding(.horizontal, 20)
                
                Button(action: {
                  startChallenge()
                }) {
                  HStack {
                    Image(systemName: "puzzlepiece.fill")
                      .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                      Text("Start Challenge")
                        .font(.headline)
                      Text("Unlock all blocked apps temporarily")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                      .foregroundColor(colors.textSecondary)
                  }
                  .foregroundColor(colors.textPrimary)
                  .padding()
                  .background(colors.primary.opacity(0.2))
                  .cornerRadius(12)
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(colors.primary, lineWidth: 2)
                  )
                }
                .padding(.horizontal, 20)
              }
            }
            
            // Play for Fun Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Practice")
                .font(.title2.bold())
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              Button(action: {
                showingPlayForFun = true
              }) {
                HStack {
                  Image(systemName: "gamecontroller.fill")
                    .font(.title2)
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text("Play Challenges for Fun")
                      .font(.headline)
                    Text("Practice anytime, no unlock needed")
                      .font(.caption)
                      .foregroundColor(colors.textSecondary)
                  }
                  
                  Spacer()
                  
                  Image(systemName: "chevron.right")
                    .foregroundColor(colors.textSecondary)
                }
                .foregroundColor(colors.textPrimary)
                .padding()
                .background(colors.secondary.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(colors.secondary, lineWidth: 2)
                )
              }
              .padding(.horizontal, 20)
            }
            
            // Statistics Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Your Progress")
                .font(.title2.bold())
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
                HStack(spacing: 12) {
                  StatCard(
                    icon: "function",
                    title: "Math",
                    value: "\(statsManager.mathChallengesCompleted)",
                    color: colors.mathChallenge
                  )
                  
                  StatCard(
                    icon: "square.grid.3x3.fill",
                    title: "Tic-Tac-Toe",
                    value: "\(statsManager.ticTacToeChallengesCompleted)",
                    color: colors.ticTacToe
                  )
                }
                
                HStack(spacing: 12) {
                  StatCard(
                    icon: "shield.checkered",
                    title: "Apps Blocked",
                    value: "\(screenTimeManager.blockedApps.applicationTokens.count)",
                    color: colors.appSelection
                  )
                  
                  if let lastSync = statsManager.lastSyncDate {
                    StatCard(
                      icon: "icloud.fill",
                      title: "Last Sync",
                      value: timeAgo(lastSync),
                      color: colors.success
                    )
                  } else {
                    StatCard(
                      icon: "icloud.slash",
                      title: "Sync Status",
                      value: "Local",
                      color: colors.textDisabled
                    )
                  }
                }
              }
              .padding(.horizontal, 20)
            }
          }
          .padding(.bottom, 30)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showingChallengeSheet) {
        if let challenge = challengeManager.currentChallenge {
          ChallengeSheetView(challenge: challenge) {
            showingChallengeSheet = false
            
            // Record stats (not test mode)
            statsManager.recordChallengeCompleted(type: challenge.type, isTestMode: false)
            
            challengeManager.completeChallenge(success: true)
            
            // Grant temporary access after completing challenge
            screenTimeManager.grantTemporaryAccess(duration: 300) // 5 minutes
          }
        }
      }
      .sheet(isPresented: $showingPlayForFun) {
        ChallengeTestView(isDevelopment: false)
      }
    }
  }
  
  private func startChallenge() {
    let challengeType = ChallengeType.allCases.randomElement() ?? .math
    
    switch challengeType {
    case .math:
      challengeManager.currentChallenge = MathChallenge()
    case .ticTacToe:
      challengeManager.currentChallenge = TicTacToeChallenge()
    }
    
    showingChallengeSheet = true
  }
  
  private func timeAgo(_ date: Date) -> String {
    let seconds = Int(Date().timeIntervalSince(date))
    if seconds < 60 {
      return "Now"
    } else if seconds < 3600 {
      return "\(seconds / 60)m"
    } else if seconds < 86400 {
      return "\(seconds / 3600)h"
    } else {
      return "\(seconds / 86400)d"
    }
  }
}

struct StatusCard: View {
  @Environment(\.themeColors) private var colors
  let blockedCount: Int
  let allowedCount: Int
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading) {
          Text("Protection Active")
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          Text("\(blockedCount) apps blocked")
            .font(.caption)
            .foregroundColor(colors.textSecondary)
        }
        
        Spacer()
        
        Image(systemName: "shield.checkered")
          .font(.system(size: 40))
          .foregroundStyle(colors.success.gradient)
      }
    }
    .padding()
    .background(colors.success.opacity(0.15))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(colors.success.opacity(0.3), lineWidth: 1)
    )
    .padding(.horizontal, 20)
  }
}

struct StatCard: View {
  @Environment(\.themeColors) private var colors
  let icon: String
  let title: String
  let value: String
  let color: Color
  
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 30))
        .foregroundColor(color)
      
      Text(value)
        .font(.system(size: 24, weight: .bold))
        .foregroundColor(colors.textPrimary)
      
      Text(title)
        .font(.caption)
        .foregroundColor(colors.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(colors.surface)
    .cornerRadius(12)
  }
}

#Preview {
  HomeViewNew()
    .environmentObject(AppSettings())
}

