import SwiftUI
import FamilyControls
import ManagedSettings

@MainActor
class ScreenTimeManager: ObservableObject {
  static let shared = ScreenTimeManager()
  
  private let center = AuthorizationCenter.shared
  private let store = ManagedSettingsStore()
  
  @Published var isAuthorized = false
  @Published var blockedApps: FamilyActivitySelection = FamilyActivitySelection()
  @Published var allowedApps: FamilyActivitySelection = FamilyActivitySelection()
  
  private init() {
    checkAuthorizationStatus()
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
    applyShield()
  }
  
  func setAllowedApps(_ selection: FamilyActivitySelection) {
    allowedApps = selection
    // Note: We shield everything EXCEPT allowed apps
    applyShield()
  }
  
  private func applyShield() {
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
  }
  
  func removeAllShields() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
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

