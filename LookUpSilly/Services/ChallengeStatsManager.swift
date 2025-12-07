import Foundation
import Combine

/// Manages challenge statistics with iCloud sync
/// Uses NSUbiquitousKeyValueStore for simple key-value iCloud storage
/// Works in both simulator and device
@MainActor
class ChallengeStatsManager: ObservableObject {
  static let shared = ChallengeStatsManager()
  
  // MARK: - Published Properties
  
  @Published var totalChallengesCompleted: Int = 0
  @Published var mathChallengesCompleted: Int = 0
  @Published var ticTacToeChallengesCompleted: Int = 0
  @Published var micro2048ChallengesCompleted: Int = 0
  @Published var lastSyncDate: Date?
  
  // MARK: - Storage Keys
  
  private enum Keys {
    static let totalChallenges = "totalChallengesCompleted"
    static let mathChallenges = "mathChallengesCompleted"
    static let ticTacToeChallenges = "ticTacToeChallengesCompleted"
    static let micro2048Challenges = "micro2048ChallengesCompleted"
    static let lastSync = "lastSyncDate"
  }
  
  // MARK: - Storage
  
  private let cloudStore = NSUbiquitousKeyValueStore.default
  private let localStore = UserDefaults.standard
  
  // MARK: - Initialization
  
  private init() {
    // Load initial values
    loadStats()
    
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
  
  // MARK: - Load Stats
  
  private func loadStats() {
    // Try iCloud first, fallback to local
    if cloudStore.object(forKey: Keys.totalChallenges) != nil {
      // Load from iCloud
      totalChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.totalChallenges))
      mathChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.mathChallenges))
      ticTacToeChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.ticTacToeChallenges))
      micro2048ChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.micro2048Challenges))
      
      if let syncTimestamp = cloudStore.object(forKey: Keys.lastSync) as? Double {
        lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
      }
      
      print("📊 Stats loaded from iCloud: \(totalChallengesCompleted) total challenges")
    } else {
      // Load from local storage (fallback)
      totalChallengesCompleted = localStore.integer(forKey: Keys.totalChallenges)
      mathChallengesCompleted = localStore.integer(forKey: Keys.mathChallenges)
      ticTacToeChallengesCompleted = localStore.integer(forKey: Keys.ticTacToeChallenges)
      micro2048ChallengesCompleted = localStore.integer(forKey: Keys.micro2048Challenges)
      
      if let syncTimestamp = localStore.object(forKey: Keys.lastSync) as? Double {
        lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
      }
      
      print("📊 Stats loaded from local storage: \(totalChallengesCompleted) total challenges")
    }
  }
  
  // MARK: - Save Stats
  
  private func saveStats() {
    let timestamp = Date().timeIntervalSince1970
    
    // Save to iCloud
    cloudStore.set(Int64(totalChallengesCompleted), forKey: Keys.totalChallenges)
    cloudStore.set(Int64(mathChallengesCompleted), forKey: Keys.mathChallenges)
    cloudStore.set(Int64(ticTacToeChallengesCompleted), forKey: Keys.ticTacToeChallenges)
    cloudStore.set(Int64(micro2048ChallengesCompleted), forKey: Keys.micro2048Challenges)
    cloudStore.set(timestamp, forKey: Keys.lastSync)
    cloudStore.synchronize()
    
    // Also save locally as backup
    localStore.set(totalChallengesCompleted, forKey: Keys.totalChallenges)
    localStore.set(mathChallengesCompleted, forKey: Keys.mathChallenges)
    localStore.set(ticTacToeChallengesCompleted, forKey: Keys.ticTacToeChallenges)
    localStore.set(micro2048ChallengesCompleted, forKey: Keys.micro2048Challenges)
    localStore.set(timestamp, forKey: Keys.lastSync)
    
    lastSyncDate = Date()
    
    print("📊 Stats saved: \(totalChallengesCompleted) total challenges")
  }
  
  // MARK: - iCloud Sync Handler
  
  @objc private func iCloudStoreDidChange(_ notification: Notification) {
    print("☁️ iCloud store changed externally")
    
    Task { @MainActor in
      loadStats()
    }
  }
  
  // MARK: - Public Methods
  
  /// Record a completed challenge
  func recordChallengeCompleted(type: ChallengeType, isTestMode: Bool = false) {
    guard !isTestMode else {
      print("📊 Test mode - not recording stats")
      return
    }
    
    totalChallengesCompleted += 1
    
    switch type {
    case .math:
      mathChallengesCompleted += 1
    case .ticTacToe:
      ticTacToeChallengesCompleted += 1
    case .micro2048:
      micro2048ChallengesCompleted += 1
    }
    
    saveStats()
    
    print("📊 Challenge completed! Total: \(totalChallengesCompleted)")
  }
  
  /// Get formatted stats string
  func getStatsString() -> String {
    if totalChallengesCompleted == 0 {
      return "No challenges completed yet"
    } else if totalChallengesCompleted == 1 {
      return "1 challenge completed"
    } else {
      return "\(totalChallengesCompleted) challenges completed"
    }
  }
  
  /// Get breakdown stats
  func getBreakdownStats() -> (math: Int, ticTacToe: Int, micro2048: Int) {
    return (mathChallengesCompleted, ticTacToeChallengesCompleted, micro2048ChallengesCompleted)
  }
  
  /// Reset all stats (for testing/debugging)
  func resetStats() {
    totalChallengesCompleted = 0
    mathChallengesCompleted = 0
    ticTacToeChallengesCompleted = 0
    micro2048ChallengesCompleted = 0
    lastSyncDate = nil
    
    // Clear iCloud
    cloudStore.removeObject(forKey: Keys.totalChallenges)
    cloudStore.removeObject(forKey: Keys.mathChallenges)
    cloudStore.removeObject(forKey: Keys.ticTacToeChallenges)
    cloudStore.removeObject(forKey: Keys.micro2048Challenges)
    cloudStore.removeObject(forKey: Keys.lastSync)
    cloudStore.synchronize()
    
    // Clear local
    localStore.removeObject(forKey: Keys.totalChallenges)
    localStore.removeObject(forKey: Keys.mathChallenges)
    localStore.removeObject(forKey: Keys.ticTacToeChallenges)
    localStore.removeObject(forKey: Keys.micro2048Challenges)
    localStore.removeObject(forKey: Keys.lastSync)
    
    print("📊 Stats reset")
  }
  
  /// Force sync with iCloud
  func syncWithiCloud() {
    cloudStore.synchronize()
    print("☁️ Forced iCloud sync")
  }
}

