import SwiftUI
import Combine

/// Manages app settings with iCloud sync
/// Uses NSUbiquitousKeyValueStore for iCloud storage with local UserDefaults backup
@MainActor
class AppSettings: ObservableObject {
  
  // MARK: - Storage Keys
  
  private enum Keys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let allowedApps = "allowedApps"
    static let challengesPaused = "challengesPaused"
    static let challengeCancelDelaySeconds = "challengeCancelDelaySeconds"
    static let enabledChallengeTypes = "enabledChallengeTypes"
    static let activeBlockingHours = "activeBlockingHours"
    static let use24HourClock = "use24HourClock"
    static let lastSyncDate = "settingsLastSyncDate"
  }
  
  // MARK: - Storage
  
  private let cloudStore = NSUbiquitousKeyValueStore.default
  private let localStore = UserDefaults.standard
  
  // MARK: - Published Properties
  
  @Published var hasCompletedOnboarding: Bool = false {
    didSet { if oldValue != hasCompletedOnboarding { saveSettings() } }
  }
  
  @Published var challengesPaused: Bool = false {
    didSet { if oldValue != challengesPaused { saveSettings() } }
  }
  
  @Published var challengeCancelDelaySeconds: Int = 60 {
    didSet { if oldValue != challengeCancelDelaySeconds { saveSettings() } }
  }
  
  @Published var use24HourClock: Bool = true {
    didSet { if oldValue != use24HourClock { saveSettings() } }
  }
  
  @Published var allowedApps: Set<String> = []
  @Published var enabledChallengeTypes: Set<ChallengeType> = Set(ChallengeType.allCases)
  @Published var activeBlockingHours: Set<Int> = Set(0...23)
  @Published var lastSyncDate: Date?
  
  // MARK: - Initialization
  
  init() {
    loadSettings()
    
    // Setup iCloud sync notification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(iCloudStoreDidChange),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: cloudStore
    )
    
    // Synchronize with iCloud on init
    cloudStore.synchronize()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Load Settings
  
  private func loadSettings() {
    // Try iCloud first, fallback to local
    if cloudStore.object(forKey: Keys.hasCompletedOnboarding) != nil {
      loadFromCloud()
      print("⚙️ Settings loaded from iCloud")
    } else {
      loadFromLocal()
      print("⚙️ Settings loaded from local storage")
    }
  }
  
  private func loadFromCloud() {
    hasCompletedOnboarding = cloudStore.bool(forKey: Keys.hasCompletedOnboarding)
    challengesPaused = cloudStore.bool(forKey: Keys.challengesPaused)
    use24HourClock = cloudStore.bool(forKey: Keys.use24HourClock)
    
    let delayValue = cloudStore.longLong(forKey: Keys.challengeCancelDelaySeconds)
    challengeCancelDelaySeconds = delayValue > 0 ? Int(delayValue) : 60
    
    // Load allowed apps
    if let data = cloudStore.data(forKey: Keys.allowedApps),
       let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
      allowedApps = decoded
    }
    
    // Load enabled challenge types
    if let data = cloudStore.data(forKey: Keys.enabledChallengeTypes),
       let decoded = try? JSONDecoder().decode([String].self, from: data) {
      let types = decoded.compactMap { ChallengeType(rawValue: $0) }
      enabledChallengeTypes = types.isEmpty ? Set(ChallengeType.allCases) : Set(types)
    }
    
    // Load active blocking hours
    if let data = cloudStore.data(forKey: Keys.activeBlockingHours),
       let decoded = try? JSONDecoder().decode([Int].self, from: data) {
      let validHours = decoded.filter { (0...23).contains($0) }
      activeBlockingHours = Set(validHours)
    }
    
    if let syncTimestamp = cloudStore.object(forKey: Keys.lastSyncDate) as? Double {
      lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
    }
  }
  
  private func loadFromLocal() {
    hasCompletedOnboarding = localStore.bool(forKey: Keys.hasCompletedOnboarding)
    challengesPaused = localStore.bool(forKey: Keys.challengesPaused)
    use24HourClock = localStore.bool(forKey: Keys.use24HourClock)
    
    let delayValue = localStore.integer(forKey: Keys.challengeCancelDelaySeconds)
    challengeCancelDelaySeconds = delayValue > 0 ? delayValue : 60
    
    // Load allowed apps
    if let data = localStore.data(forKey: Keys.allowedApps),
       let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
      allowedApps = decoded
    }
    
    // Load enabled challenge types
    if let data = localStore.data(forKey: Keys.enabledChallengeTypes),
       let decoded = try? JSONDecoder().decode([String].self, from: data) {
      let types = decoded.compactMap { ChallengeType(rawValue: $0) }
      enabledChallengeTypes = types.isEmpty ? Set(ChallengeType.allCases) : Set(types)
    } else {
      enabledChallengeTypes = Set(ChallengeType.allCases)
    }
    
    // Load active blocking hours
    if let data = localStore.data(forKey: Keys.activeBlockingHours),
       let decoded = try? JSONDecoder().decode([Int].self, from: data) {
      let validHours = decoded.filter { (0...23).contains($0) }
      activeBlockingHours = Set(validHours)
    } else {
      activeBlockingHours = Set(0...23)
    }
    
    if let syncTimestamp = localStore.object(forKey: Keys.lastSyncDate) as? Double {
      lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
    }
  }
  
  // MARK: - Save Settings
  
  private func saveSettings() {
    let timestamp = Date().timeIntervalSince1970
    
    // Encode complex types
    let allowedAppsData = try? JSONEncoder().encode(allowedApps)
    let challengeTypesData = try? JSONEncoder().encode(enabledChallengeTypes.map { $0.rawValue })
    let blockingHoursData = try? JSONEncoder().encode(Array(activeBlockingHours).sorted())
    
    // Save to iCloud
    cloudStore.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
    cloudStore.set(challengesPaused, forKey: Keys.challengesPaused)
    cloudStore.set(use24HourClock, forKey: Keys.use24HourClock)
    cloudStore.set(Int64(challengeCancelDelaySeconds), forKey: Keys.challengeCancelDelaySeconds)
    cloudStore.set(timestamp, forKey: Keys.lastSyncDate)
    
    if let data = allowedAppsData {
      cloudStore.set(data, forKey: Keys.allowedApps)
    }
    if let data = challengeTypesData {
      cloudStore.set(data, forKey: Keys.enabledChallengeTypes)
    }
    if let data = blockingHoursData {
      cloudStore.set(data, forKey: Keys.activeBlockingHours)
    }
    
    cloudStore.synchronize()
    
    // Also save locally as backup
    localStore.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
    localStore.set(challengesPaused, forKey: Keys.challengesPaused)
    localStore.set(use24HourClock, forKey: Keys.use24HourClock)
    localStore.set(challengeCancelDelaySeconds, forKey: Keys.challengeCancelDelaySeconds)
    localStore.set(timestamp, forKey: Keys.lastSyncDate)
    
    if let data = allowedAppsData {
      localStore.set(data, forKey: Keys.allowedApps)
    }
    if let data = challengeTypesData {
      localStore.set(data, forKey: Keys.enabledChallengeTypes)
    }
    if let data = blockingHoursData {
      localStore.set(data, forKey: Keys.activeBlockingHours)
    }
    
    lastSyncDate = Date()
    
    print("⚙️ Settings saved to iCloud and local storage")
  }
  
  // MARK: - iCloud Sync Handler
  
  @objc private nonisolated func iCloudStoreDidChange(_ notification: Notification) {
    print("☁️ iCloud settings changed externally")
    
    Task { @MainActor [weak self] in
      self?.loadFromCloud()
    }
  }
  
  // MARK: - Allowed Apps
  
  func saveAllowedApps() {
    saveSettings()
  }
  
  func addAllowedApp(_ bundleId: String) {
    allowedApps.insert(bundleId)
    saveSettings()
  }
  
  func removeAllowedApp(_ bundleId: String) {
    allowedApps.remove(bundleId)
    saveSettings()
  }
  
  func isAppAllowed(_ bundleId: String) -> Bool {
    return allowedApps.contains(bundleId)
  }
  
  // MARK: - Challenge Types
  
  func saveEnabledChallengeTypes() {
    saveSettings()
  }
  
  func setEnabledChallengeTypes(_ types: Set<ChallengeType>) {
    enabledChallengeTypes = types
    saveSettings()
  }
  
  func toggleChallengeType(_ type: ChallengeType, isEnabled: Bool) {
    if isEnabled {
      enabledChallengeTypes.insert(type)
    } else {
      enabledChallengeTypes.remove(type)
    }
    saveSettings()
  }

  // MARK: - Blocking Schedule
  
  func saveActiveBlockingHours() {
    saveSettings()
  }
  
  func setBlockingHours(_ hours: Set<Int>) {
    let filteredHours = hours.filter { (0...23).contains($0) }
    activeBlockingHours = Set(filteredHours)
    saveSettings()
  }
  
  func setBlockingHour(_ hour: Int, isActive: Bool) {
    guard (0...23).contains(hour) else { return }
    
    if isActive {
      activeBlockingHours.insert(hour)
    } else {
      activeBlockingHours.remove(hour)
    }
    saveSettings()
  }
  
  func resetBlockingHoursToAll() {
    activeBlockingHours = Set(0...23)
    saveSettings()
  }
  
  func isBlockingActive(for date: Date = Date()) -> Bool {
    let hour = Calendar.current.component(.hour, from: date)
    return activeBlockingHours.contains(hour)
  }
  
  // MARK: - Sync
  
  /// Force sync with iCloud
  func syncWithiCloud() {
    cloudStore.synchronize()
    print("☁️ Forced iCloud settings sync")
  }
  
  /// Reset all settings (for testing/debugging)
  func resetSettings() {
    hasCompletedOnboarding = false
    challengesPaused = false
    challengeCancelDelaySeconds = 60
    use24HourClock = true
    allowedApps = []
    enabledChallengeTypes = Set(ChallengeType.allCases)
    activeBlockingHours = Set(0...23)
    lastSyncDate = nil
    
    // Clear iCloud
    cloudStore.removeObject(forKey: Keys.hasCompletedOnboarding)
    cloudStore.removeObject(forKey: Keys.challengesPaused)
    cloudStore.removeObject(forKey: Keys.challengeCancelDelaySeconds)
    cloudStore.removeObject(forKey: Keys.use24HourClock)
    cloudStore.removeObject(forKey: Keys.allowedApps)
    cloudStore.removeObject(forKey: Keys.enabledChallengeTypes)
    cloudStore.removeObject(forKey: Keys.activeBlockingHours)
    cloudStore.removeObject(forKey: Keys.lastSyncDate)
    cloudStore.synchronize()
    
    // Clear local
    localStore.removeObject(forKey: Keys.hasCompletedOnboarding)
    localStore.removeObject(forKey: Keys.challengesPaused)
    localStore.removeObject(forKey: Keys.challengeCancelDelaySeconds)
    localStore.removeObject(forKey: Keys.use24HourClock)
    localStore.removeObject(forKey: Keys.allowedApps)
    localStore.removeObject(forKey: Keys.enabledChallengeTypes)
    localStore.removeObject(forKey: Keys.activeBlockingHours)
    localStore.removeObject(forKey: Keys.lastSyncDate)
    
    print("⚙️ Settings reset")
  }
}
