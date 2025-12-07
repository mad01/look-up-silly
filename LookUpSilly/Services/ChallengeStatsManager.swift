import Foundation
import Combine

/// Represents a single challenge completion event with timestamp
struct ChallengeCompletionEvent: Codable, Identifiable {
  let id: UUID
  let date: Date
  let type: String
  
  init(type: ChallengeType) {
    self.id = UUID()
    self.date = Date()
    self.type = type.rawValue
  }
}

/// Data point for the line chart
struct ChartDataPoint: Identifiable {
  let id = UUID()
  let date: Date
  let cumulativeCount: Int
}

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
  @Published var completionEvents: [ChallengeCompletionEvent] = []
  
  // MARK: - Storage Keys
  
  private enum Keys {
    static let totalChallenges = "totalChallengesCompleted"
    static let mathChallenges = "mathChallengesCompleted"
    static let ticTacToeChallenges = "ticTacToeChallengesCompleted"
    static let micro2048Challenges = "micro2048ChallengesCompleted"
    static let lastSync = "lastSyncDate"
    static let completionEvents = "completionEvents"
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
      
      // Load completion events from iCloud
      if let eventsData = cloudStore.data(forKey: Keys.completionEvents) {
        do {
          completionEvents = try JSONDecoder().decode([ChallengeCompletionEvent].self, from: eventsData)
        } catch {
          print("📊 Failed to decode completion events from iCloud: \(error)")
          completionEvents = []
        }
      }
      
      print("📊 Stats loaded from iCloud: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
    } else {
      // Load from local storage (fallback)
      totalChallengesCompleted = localStore.integer(forKey: Keys.totalChallenges)
      mathChallengesCompleted = localStore.integer(forKey: Keys.mathChallenges)
      ticTacToeChallengesCompleted = localStore.integer(forKey: Keys.ticTacToeChallenges)
      micro2048ChallengesCompleted = localStore.integer(forKey: Keys.micro2048Challenges)
      
      if let syncTimestamp = localStore.object(forKey: Keys.lastSync) as? Double {
        lastSyncDate = Date(timeIntervalSince1970: syncTimestamp)
      }
      
      // Load completion events from local storage
      if let eventsData = localStore.data(forKey: Keys.completionEvents) {
        do {
          completionEvents = try JSONDecoder().decode([ChallengeCompletionEvent].self, from: eventsData)
        } catch {
          print("📊 Failed to decode completion events from local: \(error)")
          completionEvents = []
        }
      }
      
      print("📊 Stats loaded from local storage: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
    }
  }
  
  // MARK: - Save Stats
  
  private func saveStats() {
    let timestamp = Date().timeIntervalSince1970
    
    // Encode completion events
    let eventsData: Data?
    do {
      eventsData = try JSONEncoder().encode(completionEvents)
    } catch {
      print("📊 Failed to encode completion events: \(error)")
      eventsData = nil
    }
    
    // Save to iCloud
    cloudStore.set(Int64(totalChallengesCompleted), forKey: Keys.totalChallenges)
    cloudStore.set(Int64(mathChallengesCompleted), forKey: Keys.mathChallenges)
    cloudStore.set(Int64(ticTacToeChallengesCompleted), forKey: Keys.ticTacToeChallenges)
    cloudStore.set(Int64(micro2048ChallengesCompleted), forKey: Keys.micro2048Challenges)
    cloudStore.set(timestamp, forKey: Keys.lastSync)
    if let eventsData = eventsData {
      cloudStore.set(eventsData, forKey: Keys.completionEvents)
    }
    cloudStore.synchronize()
    
    // Also save locally as backup
    localStore.set(totalChallengesCompleted, forKey: Keys.totalChallenges)
    localStore.set(mathChallengesCompleted, forKey: Keys.mathChallenges)
    localStore.set(ticTacToeChallengesCompleted, forKey: Keys.ticTacToeChallenges)
    localStore.set(micro2048ChallengesCompleted, forKey: Keys.micro2048Challenges)
    localStore.set(timestamp, forKey: Keys.lastSync)
    if let eventsData = eventsData {
      localStore.set(eventsData, forKey: Keys.completionEvents)
    }
    
    lastSyncDate = Date()
    
    print("📊 Stats saved: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
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
    
    // Add completion event with timestamp
    let event = ChallengeCompletionEvent(type: type)
    completionEvents.append(event)
    
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
    completionEvents = []
    
    // Clear iCloud
    cloudStore.removeObject(forKey: Keys.totalChallenges)
    cloudStore.removeObject(forKey: Keys.mathChallenges)
    cloudStore.removeObject(forKey: Keys.ticTacToeChallenges)
    cloudStore.removeObject(forKey: Keys.micro2048Challenges)
    cloudStore.removeObject(forKey: Keys.lastSync)
    cloudStore.removeObject(forKey: Keys.completionEvents)
    cloudStore.synchronize()
    
    // Clear local
    localStore.removeObject(forKey: Keys.totalChallenges)
    localStore.removeObject(forKey: Keys.mathChallenges)
    localStore.removeObject(forKey: Keys.ticTacToeChallenges)
    localStore.removeObject(forKey: Keys.micro2048Challenges)
    localStore.removeObject(forKey: Keys.lastSync)
    localStore.removeObject(forKey: Keys.completionEvents)
    
    print("📊 Stats reset")
  }
  
  /// Get chart data points for the line chart (cumulative over time)
  func getChartDataPoints(for days: Int = 7) -> [ChartDataPoint] {
    let calendar = Calendar.current
    let now = Date()
    let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: now))!
    
    // Sort events by date
    let sortedEvents = completionEvents.sorted { $0.date < $1.date }
    
    // Generate data points for each day
    var dataPoints: [ChartDataPoint] = []
    var cumulativeCount = 0
    
    // Count events before the start date
    for event in sortedEvents {
      if event.date < startDate {
        cumulativeCount += 1
      }
    }
    
    // Generate points for each day in the range
    for dayOffset in 0..<days {
      guard let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: startDate),
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
        continue
      }
      
      // Count events for this day
      let eventsThisDay = sortedEvents.filter { $0.date >= dayStart && $0.date < dayEnd }
      cumulativeCount += eventsThisDay.count
      
      // Use middle of the day for the data point
      let midDay = calendar.date(byAdding: .hour, value: 12, to: dayStart) ?? dayStart
      dataPoints.append(ChartDataPoint(date: midDay, cumulativeCount: cumulativeCount))
    }
    
    // If no events, ensure we have at least start and end points at 0
    if dataPoints.isEmpty {
      let midStart = calendar.date(byAdding: .hour, value: 12, to: startDate) ?? startDate
      let midEnd = calendar.date(byAdding: .hour, value: 12, to: now) ?? now
      return [
        ChartDataPoint(date: midStart, cumulativeCount: 0),
        ChartDataPoint(date: midEnd, cumulativeCount: 0)
      ]
    }
    
    return dataPoints
  }
  
  /// Force sync with iCloud
  func syncWithiCloud() {
    cloudStore.synchronize()
    print("☁️ Forced iCloud sync")
  }
}

