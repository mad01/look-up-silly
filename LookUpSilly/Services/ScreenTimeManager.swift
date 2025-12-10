import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
class ScreenTimeManager: ObservableObject {
  static let shared = ScreenTimeManager()
  
  private let center = AuthorizationCenter.shared
  private let store = ManagedSettingsStore()
  
  // UserDefaults keys for persistence
  private static let blockedAppsKey = "blockedAppsSelection"
  private static let allowedAppsKey = "allowedAppsSelection"
  
  @Published var isAuthorized = false
  @Published var blockedApps: FamilyActivitySelection = FamilyActivitySelection() {
    didSet { saveBlockedApps() }
  }
  @Published var allowedApps: FamilyActivitySelection = FamilyActivitySelection() {
    didSet { saveAllowedApps() }
  }
  
  private var scheduleTimer: Timer?
  
  private init() {
    checkAuthorizationStatus()
    loadSavedSelections()
    startScheduleTimer()
    // Apply shields on init if we have saved selections
    applyShield()
  }
  
  // MARK: - Persistence
  
  private func saveBlockedApps() {
    guard let data = try? JSONEncoder().encode(blockedApps) else { return }
    UserDefaults.shared.set(data, forKey: Self.blockedAppsKey)
  }
  
  private func saveAllowedApps() {
    guard let data = try? JSONEncoder().encode(allowedApps) else { return }
    UserDefaults.shared.set(data, forKey: Self.allowedAppsKey)
  }
  
  private func loadSavedSelections() {
    if let data = UserDefaults.shared.data(forKey: Self.blockedAppsKey),
       let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
      blockedApps = selection
    }
    
    if let data = UserDefaults.shared.data(forKey: Self.allowedAppsKey),
       let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
      allowedApps = selection
    }
  }
  
  // MARK: - Authorization
  
  nonisolated func requestAuthorization() async throws {
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      
      await MainActor.run {
        self.isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
      }
    } catch {
      print("Failed to request Screen Time authorization: \(error)")
      throw error
    }
  }
  
  func checkAuthorizationStatus() {
    isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
  }
  
  // MARK: - App Management
  
  func setBlockedApps(_ selection: FamilyActivitySelection) {
    blockedApps = selection
    logSelections(context: "setBlockedApps")
    applyShield()
  }
  
  func setAllowedApps(_ selection: FamilyActivitySelection) {
    allowedApps = selection
    logSelections(context: "setAllowedApps")
    // Note: We shield everything EXCEPT allowed apps
    applyShield()
  }
  
  private func applyShield() {
    logSelections(context: "applyShield-start")
    // Check if challenges are paused
    let challengesPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
    
    // If challenges are paused, don't apply shields
    if challengesPaused {
      removeAllShields()
      return
    }
    
    // If current hour isn't active, don't apply shields
    if !isWithinActiveSchedule() {
      removeAllShields()
      return
    }
    
    // Shield blocked applications, except allowed ones
    if !allowedApps.applicationTokens.isEmpty {
      // If we have allowed apps, shield blocked apps except the allowed ones
      let appsToShield = blockedApps.applicationTokens.subtracting(allowedApps.applicationTokens)
      store.shield.applications = appsToShield
    } else {
      // No allowed apps, shield all blocked apps
      store.shield.applications = blockedApps.applicationTokens
    }
    
    // Shield blocked categories, except allowed app tokens
    if !blockedApps.categoryTokens.isEmpty {
      store.shield.applicationCategories = .specific(
        blockedApps.categoryTokens,
        except: allowedApps.applicationTokens
      )
    } else {
      store.shield.applicationCategories = nil
    }
    logSelections(context: "applyShield-end")
  }

  private func logSelections(context: String) {
    let blockedCount = blockedApps.applicationTokens.count
    let allowedCount = allowedApps.applicationTokens.count
    let blockedCategories = blockedApps.categoryTokens.count
    let allowedCategories = allowedApps.categoryTokens.count
    print("🛡️ ScreenTimeManager [\(context)] blockedApps=\(blockedCount) allowedApps=\(allowedCount) blockedCategories=\(blockedCategories) allowedCategories=\(allowedCategories)")
  }
  
  func removeAllShields() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
  }
  
  func updateShielding() {
    applyShield()
  }
  
  private func startScheduleTimer() {
    scheduleTimer?.invalidate()
    scheduleTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
      Task { @MainActor in
        self?.applyShield()
      }
    }
  }
  
  private func isWithinActiveSchedule(date: Date = Date()) -> Bool {
    let currentHour = Calendar.current.component(.hour, from: date)
    
    guard let data = UserDefaults.standard.data(forKey: "activeBlockingHours"),
          let decoded = try? JSONDecoder().decode([Int].self, from: data) else {
      return true // Default: blocking is active all hours
    }
    
    let hours = decoded.filter { (0...23).contains($0) }
    let hourSet = Set(hours)
    if hourSet.isEmpty {
      return false
    }
    
    return hourSet.contains(currentHour)
  }
  
  // MARK: - Temporary Access
  
  func grantTemporaryAccess(duration: TimeInterval = 300) {
    // Remove shield temporarily (5 minutes default)
    removeAllShields()
    
    // Restore shield after duration
    Task {
      try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      applyShield()
    }
  }
}

