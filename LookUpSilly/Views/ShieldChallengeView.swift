import SwiftUI

/// View shown when app is opened from a shield to complete a challenge
/// Automatically starts a random challenge and grants temporary access on completion
struct ShieldChallengeView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
  
  @Binding var isPresented: Bool
  @State private var currentChallenge: (any Challenge)?
  @State private var currentChallengeType: ChallengeType = .math
  @State private var showingChallenge = false
  @State private var challengeCompleted = false
  @State private var accessGrantedMinutes: Int = 5
  
  private var pauseDurationMinutes: Int {
    let stored = UserDefaults.shared.integer(forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
    return stored > 0 ? stored : SharedConstants.defaultPauseDurationMinutes
  }
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      if challengeCompleted {
        // Success view
        successView
      } else if showingChallenge, let challenge = currentChallenge {
        // Challenge view
        ChallengeSheetView(
          challenge: challenge,
          onComplete: {
            handleChallengeCompleted()
          },
          appSettings: appSettings,
          onCancelAction: { @MainActor in
            // If user skips/cancels, still grant access
            handleChallengeCompleted()
          }
        )
      } else {
        // Loading/preparing view
        preparingView
      }
    }
    .onAppear {
      startRandomChallenge()
    }
  }
  
  private var preparingView: some View {
    VStack(spacing: 24) {
      Image("AppLogo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
      
      Text("Preparing Challenge...")
        .font(.system(size: 24, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
      
      ProgressView()
        .scaleEffect(1.5)
        .tint(colors.primary)
    }
  }
  
  private var successView: some View {
    VStack(spacing: 32) {
      Spacer()
      
      // Success icon
      ZStack {
        Circle()
          .fill(colors.success.opacity(0.2))
          .frame(width: 120, height: 120)
        
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 80))
          .foregroundStyle(colors.success.gradient)
      }
      
      VStack(spacing: 12) {
        Text(NSLocalizedString("shield.challenge.success.title", comment: ""))
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundColor(colors.textPrimary)
        
        Text(String(format: NSLocalizedString("shield.challenge.success.subtitle", comment: ""), accessGrantedMinutes))
          .font(.body)
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
      }
      
      Spacer()
      
      // Close button
      Button(action: {
        closeAndReturn()
      }) {
        HStack {
          Image(systemName: "arrow.backward.circle.fill")
            .font(.title2)
          Text(NSLocalizedString("shield.challenge.success.continue", comment: ""))
            .font(.headline)
        }
        .foregroundColor(colors.textOnAccent)
        .frame(maxWidth: .infinity)
        .padding()
        .background(colors.success)
        .cornerRadius(12)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
    }
  }
  
  private func startRandomChallenge() {
    // Get enabled challenge types
    let availableTypes = appSettings.enabledChallengeTypes.isEmpty 
      ? Set(ChallengeType.allCases) 
      : appSettings.enabledChallengeTypes
    
    currentChallengeType = availableTypes.randomElement() ?? .math
    
    // Record that challenge was triggered
    statsManager.recordChallengeTriggered(type: currentChallengeType)
    
    // Create the challenge
    switch currentChallengeType {
    case .math:
      currentChallenge = MathChallenge()
    case .ticTacToe:
      currentChallenge = TicTacToeChallenge()
    case .micro2048:
      currentChallenge = Micro2048Challenge()
    case .colorTap:
      currentChallenge = ColorTapChallenge()
    case .pathRecall:
      currentChallenge = PathRecallChallenge()
    }
    
    // Small delay before showing challenge
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      showingChallenge = true
    }
  }
  
  private func handleChallengeCompleted() {
    // Record completion
    statsManager.recordChallengeContinued(type: currentChallengeType)
    
    // Get pause duration
    accessGrantedMinutes = pauseDurationMinutes
    let duration = TimeInterval(accessGrantedMinutes * 60)
    
    // Grant temporary access
    screenTimeManager.grantTemporaryAccess(duration: duration)
    
    // Also set the pause state so it persists
    let endTime = Date().addingTimeInterval(duration)
    UserDefaults.standard.set(endTime, forKey: "pauseEndTime")
    UserDefaults.shared.set(endTime, forKey: "pauseEndTime")
    appSettings.challengesPaused = true
    
    // Clear the pending challenge flag
    UserDefaults.shared.removeObject(forKey: "pendingShieldChallenge")
    
    // Show success view
    withAnimation {
      showingChallenge = false
      challengeCompleted = true
    }
    
    // Auto-close after showing success
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      closeAndReturn()
    }
  }
  
  private func closeAndReturn() {
    isPresented = false
    
    // Schedule auto-resume of shields
    let duration = TimeInterval(accessGrantedMinutes * 60)
    Task {
      try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      
      await MainActor.run {
        // Check if pause end time hasn't been changed
        if let storedEndTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date {
          if Date() >= storedEndTime {
            appSettings.challengesPaused = false
            UserDefaults.standard.removeObject(forKey: "pauseEndTime")
            UserDefaults.shared.removeObject(forKey: "pauseEndTime")
            screenTimeManager.updateShielding()
          }
        }
      }
    }
  }
}

#Preview {
  ShieldChallengeView(isPresented: .constant(true))
    .environmentObject(AppSettings())
}
