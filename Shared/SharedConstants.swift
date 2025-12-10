import Foundation

/// Shared constants between main app and extensions
enum SharedConstants {
  /// App Group identifier for sharing data between app and extensions
  static let appGroupIdentifier = "group.com.lookupsilly.app"
  
  /// URL scheme for deep linking
  static let urlScheme = "lookupsilly"
  
  /// UserDefaults keys shared between app and extensions
  enum UserDefaultsKeys {
    static let pauseDurationMinutes = "shieldPauseDurationMinutes"
    static let challengesPaused = "challengesPaused"
    static let pauseEndTime = "pauseEndTime"
  }
  
  /// Default pause duration in minutes after completing a challenge from shield
  static let defaultPauseDurationMinutes = 5
}

/// Shared UserDefaults accessor for App Group
extension UserDefaults {
  static var shared: UserDefaults {
    UserDefaults(suiteName: SharedConstants.appGroupIdentifier) ?? .standard
  }
}
