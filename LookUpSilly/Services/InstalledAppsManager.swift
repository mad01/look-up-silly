import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
class InstalledAppsManager: ObservableObject {
  static let shared = InstalledAppsManager()
  
  @Published var commonApps: [SuggestedApp] = []
  
  private init() {
    // Generate suggested apps based on common distracting apps
    // Note: FamilyActivityPicker will show actual installed apps
    // These are just suggestions to help users understand what to block
    commonApps = Self.generateSuggestions()
  }
  
  // Common distracting apps to suggest blocking
  static func generateSuggestions() -> [SuggestedApp] {
    return [
      SuggestedApp(
        name: "Social Media",
        description: "Instagram, TikTok, X, Facebook, etc.",
        icon: "person.2.circle.fill",
        category: .socialNetworking
      ),
      SuggestedApp(
        name: "Video Platforms",
        description: "YouTube, Netflix, etc.",
        icon: "play.circle.fill",
        category: .entertainment
      ),
      SuggestedApp(
        name: "News Apps",
        description: "News apps and websites",
        icon: "newspaper.circle.fill",
        category: .newsAndReading
      ),
      SuggestedApp(
        name: "Games",
        description: "Mobile games",
        icon: "gamecontroller.circle.fill",
        category: .games
      ),
      SuggestedApp(
        name: "Shopping",
        description: "Shopping and marketplace apps",
        icon: "cart.circle.fill",
        category: .shopping
      ),
      SuggestedApp(
        name: "Safari",
        description: "Web browser",
        icon: "safari.fill",
        category: .webBrowser
      )
    ]
  }
}

struct SuggestedApp: Identifiable {
  let id = UUID()
  let name: String
  let description: String
  let icon: String
  let category: ActivityCategoryToken?
  
  init(name: String, description: String, icon: String, category: ActivityCategoryToken? = nil) {
    self.name = name
    self.description = description
    self.icon = icon
    self.category = category
  }
}

// Helper extension to get category tokens
extension ActivityCategoryToken {
  static var socialNetworking: ActivityCategoryToken? {
    // Social networking category
    return nil // Will be set by FamilyActivityPicker
  }
  
  static var entertainment: ActivityCategoryToken? {
    return nil
  }
  
  static var newsAndReading: ActivityCategoryToken? {
    return nil
  }
  
  static var games: ActivityCategoryToken? {
    return nil
  }
  
  static var shopping: ActivityCategoryToken? {
    return nil
  }
  
  static var webBrowser: ActivityCategoryToken? {
    return nil
  }
}

