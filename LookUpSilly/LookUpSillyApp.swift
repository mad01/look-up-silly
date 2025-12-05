import SwiftUI

@main
struct LookUpSillyApp: App {
  @StateObject private var appSettings = AppSettings()
  @State private var isReady = false
  
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
        if isReady {
          ContentView()
            .environmentObject(appSettings)
        } else {
          StartupView()
        }
      }
      .preferredColorScheme(.dark)
      .task {
        // Simulate brief startup delay for splash screen
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        withAnimation {
          isReady = true
        }
      }
    }
  }
}

