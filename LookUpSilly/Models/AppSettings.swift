import SwiftUI

class AppSettings: ObservableObject {
  @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
  @AppStorage("allowedApps") private var allowedAppsData: Data = Data()
  @AppStorage("challengesPaused") var challengesPaused: Bool = false
  @AppStorage("challengeCancelDelaySeconds") var challengeCancelDelaySeconds: Int = 60
  @AppStorage("enabledChallengeTypes") private var enabledChallengeTypesData: Data = Data()
  @AppStorage("activeBlockingHours") private var activeBlockingHoursData: Data = Data()
  @AppStorage("use24HourClock") var use24HourClock: Bool = true
  
  @Published var allowedApps: Set<String> = []
  @Published var enabledChallengeTypes: Set<ChallengeType> = Set(ChallengeType.allCases)
  @Published var activeBlockingHours: Set<Int> = Set(0...23)
  
  init() {
    loadAllowedApps()
    loadEnabledChallengeTypes()
    loadActiveBlockingHours()
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

  // MARK: - Blocking Schedule
  
  func loadActiveBlockingHours() {
    if let decoded = try? JSONDecoder().decode([Int].self, from: activeBlockingHoursData) {
      let validHours = decoded.filter { (0...23).contains($0) }
      activeBlockingHours = Set(validHours)
    } else {
      activeBlockingHours = Set(0...23)
    }
  }
  
  func saveActiveBlockingHours() {
    let sortedHours = Array(activeBlockingHours).sorted()
    if let encoded = try? JSONEncoder().encode(sortedHours) {
      activeBlockingHoursData = encoded
    }
  }
  
  func setBlockingHours(_ hours: Set<Int>) {
    let filteredHours = hours.filter { (0...23).contains($0) }
    activeBlockingHours = Set(filteredHours)
    saveActiveBlockingHours()
  }
  
  func setBlockingHour(_ hour: Int, isActive: Bool) {
    guard (0...23).contains(hour) else { return }
    
    if isActive {
      activeBlockingHours.insert(hour)
    } else {
      activeBlockingHours.remove(hour)
    }
    saveActiveBlockingHours()
  }
  
  func resetBlockingHoursToAll() {
    activeBlockingHours = Set(0...23)
    saveActiveBlockingHours()
  }
  
  func isBlockingActive(for date: Date = Date()) -> Bool {
    let hour = Calendar.current.component(.hour, from: date)
    return activeBlockingHours.contains(hour)
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

