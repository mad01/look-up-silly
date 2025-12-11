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

enum ChallengeSeries {
  case triggered
  case continued
}

/// Manages challenge statistics with iCloud sync
/// Uses NSUbiquitousKeyValueStore for simple key-value iCloud storage
/// Works in both simulator and device
@MainActor
class ChallengeStatsManager: ObservableObject {
  static let shared = ChallengeStatsManager()
  
  // MARK: - Published Properties
  
  @Published var totalChallengesCompleted: Int = 0
  @Published var totalChallengesTriggered: Int = 0
  @Published var totalChallengesContinued: Int = 0
  @Published var totalChallengesCancelled: Int = 0
  @Published var mathChallengesCompleted: Int = 0
  @Published var ticTacToeChallengesCompleted: Int = 0
  @Published var micro2048ChallengesCompleted: Int = 0
  @Published var colorTapChallengesCompleted: Int = 0
  @Published var pathRecallChallengesCompleted: Int = 0
  @Published var gravityDropChallengesCompleted: Int = 0
  @Published var lastSyncDate: Date?
  @Published var completionEvents: [ChallengeCompletionEvent] = []
  @Published var triggeredEvents: [Date] = []
  @Published var continuedEvents: [Date] = []
  @Published var cancelledEvents: [Date] = []
  
  // MARK: - Storage Keys
  
  private enum Keys {
    static let totalChallenges = "totalChallengesCompleted"
    static let totalChallengesTriggered = "totalChallengesTriggered"
    static let totalChallengesContinued = "totalChallengesContinued"
    static let totalChallengesCancelled = "totalChallengesCancelled"
    static let mathChallenges = "mathChallengesCompleted"
    static let ticTacToeChallenges = "ticTacToeChallengesCompleted"
    static let micro2048Challenges = "micro2048ChallengesCompleted"
    static let colorTapChallenges = "colorTapChallengesCompleted"
    static let pathRecallChallenges = "pathRecallChallengesCompleted"
    static let gravityDropChallenges = "gravityDropChallengesCompleted"
    static let lastSync = "lastSyncDate"
    static let completionEvents = "completionEvents"
    static let triggeredEvents = "triggeredEvents"
    static let continuedEvents = "continuedEvents"
    static let cancelledEvents = "cancelledEvents"
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
      totalChallengesTriggered = Int(cloudStore.longLong(forKey: Keys.totalChallengesTriggered))
      totalChallengesContinued = Int(cloudStore.longLong(forKey: Keys.totalChallengesContinued))
      totalChallengesCancelled = Int(cloudStore.longLong(forKey: Keys.totalChallengesCancelled))
      mathChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.mathChallenges))
      ticTacToeChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.ticTacToeChallenges))
      micro2048ChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.micro2048Challenges))
      colorTapChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.colorTapChallenges))
      pathRecallChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.pathRecallChallenges))
      gravityDropChallengesCompleted = Int(cloudStore.longLong(forKey: Keys.gravityDropChallenges))
      
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
      
      // Load triggered events
      if let triggeredData = cloudStore.data(forKey: Keys.triggeredEvents) {
        triggeredEvents = decodeDates(from: triggeredData)
      }
      
      if let continuedData = cloudStore.data(forKey: Keys.continuedEvents) {
        continuedEvents = decodeDates(from: continuedData)
      }
      
      if let cancelledData = cloudStore.data(forKey: Keys.cancelledEvents) {
        cancelledEvents = decodeDates(from: cancelledData)
      }
      
      print("📊 Stats loaded from iCloud: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
    } else {
      // Load from local storage (fallback)
      totalChallengesCompleted = localStore.integer(forKey: Keys.totalChallenges)
      totalChallengesTriggered = localStore.integer(forKey: Keys.totalChallengesTriggered)
      totalChallengesContinued = localStore.integer(forKey: Keys.totalChallengesContinued)
      totalChallengesCancelled = localStore.integer(forKey: Keys.totalChallengesCancelled)
      mathChallengesCompleted = localStore.integer(forKey: Keys.mathChallenges)
      ticTacToeChallengesCompleted = localStore.integer(forKey: Keys.ticTacToeChallenges)
      micro2048ChallengesCompleted = localStore.integer(forKey: Keys.micro2048Challenges)
      colorTapChallengesCompleted = localStore.integer(forKey: Keys.colorTapChallenges)
      pathRecallChallengesCompleted = localStore.integer(forKey: Keys.pathRecallChallenges)
      gravityDropChallengesCompleted = localStore.integer(forKey: Keys.gravityDropChallenges)
      
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
      
      if let triggeredData = localStore.data(forKey: Keys.triggeredEvents) {
        triggeredEvents = decodeDates(from: triggeredData)
      }
      
      if let continuedData = localStore.data(forKey: Keys.continuedEvents) {
        continuedEvents = decodeDates(from: continuedData)
      }
      
      if let cancelledData = localStore.data(forKey: Keys.cancelledEvents) {
        cancelledEvents = decodeDates(from: cancelledData)
      }
      
      print("📊 Stats loaded from local storage: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
    }
  }
  
  // MARK: - Save Stats
  
  private func saveStats() {
    let timestamp = Date().timeIntervalSince1970
    
    // Encode completion events
    let eventsData: Data? = try? JSONEncoder().encode(completionEvents)
    let triggeredData = encodeDates(triggeredEvents)
    let continuedData = encodeDates(continuedEvents)
    let cancelledData = encodeDates(cancelledEvents)
    
    // Save to iCloud
    cloudStore.set(Int64(totalChallengesCompleted), forKey: Keys.totalChallenges)
    cloudStore.set(Int64(totalChallengesTriggered), forKey: Keys.totalChallengesTriggered)
    cloudStore.set(Int64(totalChallengesContinued), forKey: Keys.totalChallengesContinued)
    cloudStore.set(Int64(totalChallengesCancelled), forKey: Keys.totalChallengesCancelled)
    cloudStore.set(Int64(mathChallengesCompleted), forKey: Keys.mathChallenges)
    cloudStore.set(Int64(ticTacToeChallengesCompleted), forKey: Keys.ticTacToeChallenges)
    cloudStore.set(Int64(micro2048ChallengesCompleted), forKey: Keys.micro2048Challenges)
    cloudStore.set(Int64(colorTapChallengesCompleted), forKey: Keys.colorTapChallenges)
    cloudStore.set(Int64(pathRecallChallengesCompleted), forKey: Keys.pathRecallChallenges)
    cloudStore.set(Int64(gravityDropChallengesCompleted), forKey: Keys.gravityDropChallenges)
    cloudStore.set(timestamp, forKey: Keys.lastSync)
    if let eventsData = eventsData {
      cloudStore.set(eventsData, forKey: Keys.completionEvents)
    }
    if let triggeredData {
      cloudStore.set(triggeredData, forKey: Keys.triggeredEvents)
    }
    if let continuedData {
      cloudStore.set(continuedData, forKey: Keys.continuedEvents)
    }
    if let cancelledData {
      cloudStore.set(cancelledData, forKey: Keys.cancelledEvents)
    }
    cloudStore.synchronize()
    
    // Also save locally as backup
    localStore.set(totalChallengesCompleted, forKey: Keys.totalChallenges)
    localStore.set(totalChallengesTriggered, forKey: Keys.totalChallengesTriggered)
    localStore.set(totalChallengesContinued, forKey: Keys.totalChallengesContinued)
    localStore.set(totalChallengesCancelled, forKey: Keys.totalChallengesCancelled)
    localStore.set(mathChallengesCompleted, forKey: Keys.mathChallenges)
    localStore.set(ticTacToeChallengesCompleted, forKey: Keys.ticTacToeChallenges)
    localStore.set(micro2048ChallengesCompleted, forKey: Keys.micro2048Challenges)
    localStore.set(colorTapChallengesCompleted, forKey: Keys.colorTapChallenges)
    localStore.set(pathRecallChallengesCompleted, forKey: Keys.pathRecallChallenges)
    localStore.set(gravityDropChallengesCompleted, forKey: Keys.gravityDropChallenges)
    localStore.set(timestamp, forKey: Keys.lastSync)
    if let eventsData = eventsData {
      localStore.set(eventsData, forKey: Keys.completionEvents)
    }
    if let triggeredData {
      localStore.set(triggeredData, forKey: Keys.triggeredEvents)
    }
    if let continuedData {
      localStore.set(continuedData, forKey: Keys.continuedEvents)
    }
    if let cancelledData {
      localStore.set(cancelledData, forKey: Keys.cancelledEvents)
    }
    
    lastSyncDate = Date()
    
    print("📊 Stats saved: \(totalChallengesCompleted) total challenges, \(completionEvents.count) events")
  }
  
  private func encodeDates(_ dates: [Date]) -> Data? {
    let timestamps = dates.map { $0.timeIntervalSince1970 }
    return try? JSONEncoder().encode(timestamps)
  }
  
  private func decodeDates(from data: Data) -> [Date] {
    if let timestamps = try? JSONDecoder().decode([TimeInterval].self, from: data) {
      return timestamps.map { Date(timeIntervalSince1970: $0) }
    }
    return []
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
    case .colorTap:
      colorTapChallengesCompleted += 1
    case .pathRecall:
      pathRecallChallengesCompleted += 1
    case .gravityDrop:
      gravityDropChallengesCompleted += 1
    }
    
    // Add completion event with timestamp
    let event = ChallengeCompletionEvent(type: type)
    completionEvents.append(event)
    
    // Continuing to app is also a continuation event
    recordChallengeContinued(type: type, isTestMode: isTestMode, saveAfter: false)
    
    saveStats()
    
    print("📊 Challenge completed! Total: \(totalChallengesCompleted)")
  }
  
  func recordChallengeTriggered(type: ChallengeType, isTestMode: Bool = false) {
    guard !isTestMode else {
      print("📊 Test mode - not recording trigger")
      return
    }
    
    totalChallengesTriggered += 1
    triggeredEvents.append(Date())
    saveStats()
    print("📊 Challenge triggered! Total: \(totalChallengesTriggered)")
  }
  
  func recordChallengeContinued(type: ChallengeType, isTestMode: Bool = false, saveAfter: Bool = true) {
    guard !isTestMode else {
      print("📊 Test mode - not recording continue")
      return
    }
    
    totalChallengesContinued += 1
    continuedEvents.append(Date())
    if saveAfter { saveStats() }
    print("📊 Challenge continued to app! Total: \(totalChallengesContinued)")
  }
  
  func recordChallengeCancelled(type: ChallengeType, isTestMode: Bool = false) {
    guard !isTestMode else {
      print("📊 Test mode - not recording cancel")
      return
    }
    
    totalChallengesCancelled += 1
    cancelledEvents.append(Date())
    saveStats()
    
    print("📊 Challenge cancelled/abandoned! Total: \(totalChallengesCancelled)")
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
  func getBreakdownStats() -> [ChallengeType: Int] {
    [
      .math: mathChallengesCompleted,
      .ticTacToe: ticTacToeChallengesCompleted,
      .micro2048: micro2048ChallengesCompleted,
      .colorTap: colorTapChallengesCompleted,
      .pathRecall: pathRecallChallengesCompleted,
      .gravityDrop: gravityDropChallengesCompleted
    ]
  }
  
  /// Reset all stats (for testing/debugging)
  func resetStats() {
    totalChallengesCompleted = 0
    totalChallengesTriggered = 0
    totalChallengesContinued = 0
    totalChallengesCancelled = 0
    mathChallengesCompleted = 0
    ticTacToeChallengesCompleted = 0
    micro2048ChallengesCompleted = 0
    colorTapChallengesCompleted = 0
    pathRecallChallengesCompleted = 0
    gravityDropChallengesCompleted = 0
    lastSyncDate = nil
    completionEvents = []
    triggeredEvents = []
    continuedEvents = []
    cancelledEvents = []
    
    // Clear iCloud
    cloudStore.removeObject(forKey: Keys.totalChallenges)
    cloudStore.removeObject(forKey: Keys.totalChallengesTriggered)
    cloudStore.removeObject(forKey: Keys.totalChallengesContinued)
    cloudStore.removeObject(forKey: Keys.totalChallengesCancelled)
    cloudStore.removeObject(forKey: Keys.mathChallenges)
    cloudStore.removeObject(forKey: Keys.ticTacToeChallenges)
    cloudStore.removeObject(forKey: Keys.micro2048Challenges)
    cloudStore.removeObject(forKey: Keys.colorTapChallenges)
    cloudStore.removeObject(forKey: Keys.pathRecallChallenges)
    cloudStore.removeObject(forKey: Keys.gravityDropChallenges)
    cloudStore.removeObject(forKey: Keys.lastSync)
    cloudStore.removeObject(forKey: Keys.completionEvents)
    cloudStore.removeObject(forKey: Keys.triggeredEvents)
    cloudStore.removeObject(forKey: Keys.continuedEvents)
    cloudStore.removeObject(forKey: Keys.cancelledEvents)
    cloudStore.synchronize()
    
    // Clear local
    localStore.removeObject(forKey: Keys.totalChallenges)
    localStore.removeObject(forKey: Keys.totalChallengesTriggered)
    localStore.removeObject(forKey: Keys.totalChallengesContinued)
    localStore.removeObject(forKey: Keys.totalChallengesCancelled)
    localStore.removeObject(forKey: Keys.mathChallenges)
    localStore.removeObject(forKey: Keys.ticTacToeChallenges)
    localStore.removeObject(forKey: Keys.micro2048Challenges)
    localStore.removeObject(forKey: Keys.colorTapChallenges)
    localStore.removeObject(forKey: Keys.pathRecallChallenges)
    localStore.removeObject(forKey: Keys.gravityDropChallenges)
    localStore.removeObject(forKey: Keys.lastSync)
    localStore.removeObject(forKey: Keys.completionEvents)
    localStore.removeObject(forKey: Keys.triggeredEvents)
    localStore.removeObject(forKey: Keys.continuedEvents)
    localStore.removeObject(forKey: Keys.cancelledEvents)
    
    print("📊 Stats reset")
  }
  
  /// Get chart data points for the line chart (cumulative over time)
  func getChartDataPoints(for days: Int = 7, series: ChallengeSeries = .continued) -> [ChartDataPoint] {
    let events: [Date]
    switch series {
    case .triggered:
      events = triggeredEvents
    case .continued:
      events = continuedEvents
    }
    
    let calendar = Calendar.current
    let now = Date()
    let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: now))!
    
    // Sort events by date
    let sortedEvents = events.sorted { $0 < $1 }
    
    // Generate data points for each day
    var dataPoints: [ChartDataPoint] = []
    var cumulativeCount = 0
    
    // Count events before the start date
    for event in sortedEvents {
      if event < startDate {
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
      let eventsThisDay = sortedEvents.filter { $0 >= dayStart && $0 < dayEnd }
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

