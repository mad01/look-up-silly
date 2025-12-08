import SwiftUI

struct HomeView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @EnvironmentObject var challengeManager: ChallengeManager
  
  private var isShowingChallenge: Binding<Bool> {
    Binding(
      get: { challengeManager.currentChallenge != nil },
      set: { isPresented in
        if !isPresented {
          challengeManager.completeChallenge(success: false)
        }
      }
    )
  }
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
              Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
              
              Text("Look Up, Silly!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colors.textPrimary)
              
              Text("Stay focused, break the scroll")
                .font(.subheadline)
                .foregroundColor(colors.textSecondary)
            }
            .padding(.top, 40)
            
            // Allowed Apps Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Allowed Apps")
                .font(.title2.bold())
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              if appSettings.allowedApps.isEmpty {
                Text("No allowed apps yet. Add some in Settings.")
                  .foregroundColor(colors.textSecondary)
                  .padding(.horizontal, 20)
              } else {
                VStack(spacing: 12) {
                  ForEach(InstalledApp.commonApps.filter { appSettings.allowedApps.contains($0.bundleId) }) { app in
                    AppCard(app: app, isAllowed: true)
                  }
                }
                .padding(.horizontal, 20)
              }
            }
            
            // Challenge Required Apps Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Challenge Required")
                .font(.title2.bold())
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
                ForEach(InstalledApp.commonApps.filter { !appSettings.allowedApps.contains($0.bundleId) }) { app in
                  AppCard(app: app, isAllowed: false) {
                    challengeManager.requestAppAccess(
                      app: app,
                      enabledChallenges: appSettings.enabledChallengeTypes
                    ) { success in
                      if success {
                        // App unlocked temporarily
                      }
                    }
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
      .sheet(isPresented: isShowingChallenge) {
        if let challenge = challengeManager.currentChallenge {
          ChallengeSheetView(
            challenge: challenge,
            onComplete: {
              challengeManager.completeChallenge(success: true)
            },
            appSettings: appSettings
          )
        }
      }
    }
  }
}

struct AppCard: View {
  @Environment(\.themeColors) private var colors
  let app: InstalledApp
  let isAllowed: Bool
  var onTap: (() -> Void)? = nil
  
  var body: some View {
    Button(action: {
      onTap?()
    }) {
      HStack {
        Image(systemName: app.icon)
          .font(.system(size: 32))
          .foregroundColor(colors.primary)
          .frame(width: 50)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(app.name)
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          
          Text(isAllowed ? "Allowed" : "Challenge Required")
            .font(.caption)
            .foregroundColor(isAllowed ? colors.success : colors.warning)
        }
        
        Spacer()
        
        if !isAllowed {
          Image(systemName: "lock.fill")
            .foregroundColor(colors.warning)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(colors.success)
        }
      }
      .padding()
      .background(colors.surface)
      .cornerRadius(12)
    }
    .disabled(isAllowed)
  }
}

struct ChallengeSheetView: View {
  let challenge: any Challenge
  let onComplete: () -> Void
  let appSettings: AppSettings
  
  var body: some View {
    challenge.view(onComplete: onComplete, appSettings: appSettings)
  }
}

#Preview {
  HomeView()
    .environmentObject(AppSettings())
    .environmentObject(ChallengeManager())
}

