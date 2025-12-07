import SwiftUI
import AppIntents
import UIKit

@main
struct LookUpSillyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject private var appSettings = AppSettings()
  @State private var isReady = false
  @State private var showPauseDurationSheet = false
  @Environment(\.scenePhase) private var scenePhase
  
  init() {
    // MARK: - RevenueCat Configuration
    // Uncomment to enable contribution system
    // Requires: RevenueCat account, API key, and product setup
    // See: REVENUECAT_SETUP.md for instructions
    
    // Task { @MainActor in
    //   RevenueCatManager.shared.configure()
    // }
  }
  
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
      }
      .onChange(of: scenePhase) { oldPhase, newPhase in
        if newPhase == .active {
          // Update quick actions when app becomes active
          appDelegate.updateQuickActions()
          
          // Check if pause has expired when app becomes active
          checkPauseExpiration()
        }
      }
    }
  }
  
  private func checkPauseExpiration() {
    if let pauseEndTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date {
      if Date() >= pauseEndTime {
        // Pause has expired, resume challenges
        appSettings.challengesPaused = false
        UserDefaults.standard.removeObject(forKey: "pauseEndTime")
        ScreenTimeManager.shared.updateShielding()
        appDelegate.updateQuickActions()
      }
    }
  }
}

