import SwiftUI

class AppSettings: ObservableObject {
  @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
  @AppStorage("allowedApps") private var allowedAppsData: Data = Data()
  @AppStorage("challengesPaused") var challengesPaused: Bool = false
  
  @Published var allowedApps: Set<String> = []
  
  init() {
    loadAllowedApps()
  }
  
  func loadAllowedApps() {
    if let decoded = try? JSONDecoder().decode(Set<String>.self, from: allowedAppsData) {
      allowedApps = decoded
    }
  }
  
  func saveAllowedApps() {
    if let encoded = try? JSONEncoder().encode(allowedApps) {
      allowedAppsData = encoded
    }
  }
  
  func addAllowedApp(_ bundleId: String) {
    allowedApps.insert(bundleId)
    saveAllowedApps()
  }
  
  func removeAllowedApp(_ bundleId: String) {
    allowedApps.remove(bundleId)
    saveAllowedApps()
  }
  
  func isAppAllowed(_ bundleId: String) -> Bool {
    return allowedApps.contains(bundleId)
  }
}

