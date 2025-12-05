import SwiftUI

struct HomeView: View {
  @EnvironmentObject var appSettings: AppSettings
  @EnvironmentObject var challengeManager: ChallengeManager
  @State private var showingChallengeSheet = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
              Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
              
              Text("Look Up, Silly!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
              
              Text("Stay focused, break the scroll")
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            // Allowed Apps Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Allowed Apps")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
              
              if appSettings.allowedApps.isEmpty {
                Text("No allowed apps yet. Add some in Settings.")
                  .foregroundColor(.gray)
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
                .foregroundColor(.white)
                .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
                ForEach(InstalledApp.commonApps.filter { !appSettings.allowedApps.contains($0.bundleId) }) { app in
                  AppCard(app: app, isAllowed: false) {
                    challengeManager.requestAppAccess(app: app) { success in
                      if success {
                        // App unlocked temporarily
                      }
                    }
                    showingChallengeSheet = true
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
            challengeManager.completeChallenge(success: true)
          }
        }
      }
    }
  }
}

struct AppCard: View {
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
          .foregroundColor(.blue)
          .frame(width: 50)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(app.name)
            .font(.headline)
            .foregroundColor(.white)
          
          Text(isAllowed ? "Allowed" : "Challenge Required")
            .font(.caption)
            .foregroundColor(isAllowed ? .green : .orange)
        }
        
        Spacer()
        
        if !isAllowed {
          Image(systemName: "lock.fill")
            .foregroundColor(.orange)
        } else {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
        }
      }
      .padding()
      .background(Color.white.opacity(0.1))
      .cornerRadius(12)
    }
    .disabled(isAllowed)
  }
}

struct ChallengeSheetView: View {
  let challenge: any Challenge
  let onComplete: () -> Void
  
  var body: some View {
    challenge.view(onComplete: onComplete)
  }
}

#Preview {
  HomeView()
    .environmentObject(AppSettings())
    .environmentObject(ChallengeManager())
}

