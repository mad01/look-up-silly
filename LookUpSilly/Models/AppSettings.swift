import SwiftUI

class AppSettings: ObservableObject {
  @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
  @AppStorage("allowedApps") private var allowedAppsData: Data = Data()
  @AppStorage("challengesPaused") var challengesPaused: Bool = false
  @AppStorage("challengeCancelDelaySeconds") var challengeCancelDelaySeconds: Int = 60
  @AppStorage("enabledChallengeTypes") private var enabledChallengeTypesData: Data = Data()
  
  @Published var allowedApps: Set<String> = []
  @Published var enabledChallengeTypes: Set<ChallengeType> = Set(ChallengeType.allCases)
  
  init() {
    loadAllowedApps()
    loadEnabledChallengeTypes()
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
  
  func loadEnabledChallengeTypes() {
    if let decoded = try? JSONDecoder().decode([String].self, from: enabledChallengeTypesData) {
      let types = decoded.compactMap { ChallengeType(rawValue: $0) }
      enabledChallengeTypes = types.isEmpty ? Set(ChallengeType.allCases) : Set(types)
    } else {
      enabledChallengeTypes = Set(ChallengeType.allCases)
    }
  }
  
  func saveEnabledChallengeTypes() {
    let rawValues = enabledChallengeTypes.map { $0.rawValue }
    if let encoded = try? JSONEncoder().encode(rawValues) {
      enabledChallengeTypesData = encoded
    }
  }
  
  func setEnabledChallengeTypes(_ types: Set<ChallengeType>) {
    enabledChallengeTypes = types
    saveEnabledChallengeTypes()
  }
  
  func toggleChallengeType(_ type: ChallengeType, isEnabled: Bool) {
    if isEnabled {
      enabledChallengeTypes.insert(type)
    } else {
      enabledChallengeTypes.remove(type)
    }
    saveEnabledChallengeTypes()
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

