import SwiftUI
import AppIntents
import UIKit

@main
struct LookUpSillyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject private var appSettings = AppSettings()
  @State private var isReady = false
  @State private var showPauseDurationSheet = false
  @State private var showShieldChallenge = false
  @Environment(\.scenePhase) private var scenePhase
  
  // Note: RevenueCat is configured in AppDelegate.didFinishLaunchingWithOptions
  // to ensure it's ready before any purchase attempts
  
  var body: some Scene {
    WindowGroup {
      Group {
        ZStack {
          if isReady {
            ContentView()
              .environmentObject(appSettings)
              .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UpdateQuickActions"))) { _ in
                appDelegate.updateQuickActions()
              }
              .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowPauseDurationSheet"))) { _ in
                showPauseDurationSheet = true
              }
              .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ChallengesPausedStateChanged"))) { _ in
                // Reload app settings when pause state changes from quick action
                appSettings.objectWillChange.send()
              }
              .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowShieldChallenge"))) { _ in
                showShieldChallenge = true
              }
          } else {
            StartupView()
          }
          
          // Floating pause duration overlay
          if showPauseDurationSheet {
            PauseDurationSheet(isPresented: $showPauseDurationSheet)
              .environmentObject(appSettings)
              .transition(.opacity)
              .zIndex(1000)
          }
          
          // Shield challenge overlay (shown when opened from shield)
          if showShieldChallenge {
            ShieldChallengeView(isPresented: $showShieldChallenge)
              .environmentObject(appSettings)
              .transition(.opacity)
              .zIndex(1001)
          }
        }
      }
      .environment(\.themeColors, ThemeColors())
      .preferredColorScheme(.dark)
      .task {
        // Simulate brief startup delay for splash screen
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        withAnimation {
          isReady = true
        }
        // Update quick actions after app is ready
        appDelegate.updateQuickActions()
        
        // Check if pause has expired on launch
        checkPauseExpiration()
        
        // Check if there's a pending shield challenge
        checkPendingShieldChallenge()
      }
      .onChange(of: scenePhase) { oldPhase, newPhase in
        if newPhase == .active {
          // Update quick actions when app becomes active
          appDelegate.updateQuickActions()
          
          // Check if pause has expired when app becomes active
          checkPauseExpiration()
          
          // Check if there's a pending shield challenge
          checkPendingShieldChallenge()
        }
      }
      .onOpenURL { url in
        handleDeepLink(url: url)
      }
    }
  }
  
  private func checkPauseExpiration() {
    if let pauseEndTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date {
      if Date() >= pauseEndTime {
        // Pause has expired, resume challenges
        appSettings.challengesPaused = false
        UserDefaults.standard.removeObject(forKey: "pauseEndTime")
        UserDefaults.shared.removeObject(forKey: "pauseEndTime")
        ScreenTimeManager.shared.updateShielding()
        appDelegate.updateQuickActions()
      }
    }
  }
  
  private func checkPendingShieldChallenge() {
    // Check if user tapped "Open Challenge" on shield
    if UserDefaults.shared.bool(forKey: "pendingShieldChallenge") {
      // Show the challenge view
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        showShieldChallenge = true
      }
    }
  }
  
  private func handleDeepLink(url: URL) {
    guard url.scheme == SharedConstants.urlScheme else { return }
    
    switch url.host {
    case "challenge":
      // Open challenge from shield
      showShieldChallenge = true
    default:
      break
    }
  }
}

