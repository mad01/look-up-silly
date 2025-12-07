import SwiftUI
import FamilyControls

struct HomeViewNew: View {
  @Environment(\.themeColors) private var colors
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
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
          }
          .padding(.bottom, 30)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showingPlayForFun) {
        ChallengeTestView(isDevelopment: false)
      }
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

#Preview {
  HomeViewNew()
    .environmentObject(AppSettings())
}

