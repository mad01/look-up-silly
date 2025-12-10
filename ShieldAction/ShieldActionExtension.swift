import Foundation
import ManagedSettings
import ManagedSettingsUI

/// Handles button taps on the shield view
class ShieldActionExtension: ShieldActionDelegate {
  
  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      // Open main app with deep link to start challenge
      openMainAppForChallenge()
      // Close the shield (app will re-shield if challenge not completed)
      completionHandler(.close)
      
    case .secondaryButtonPressed:
      // User chose "Not Now" - just close the shield without opening app
      completionHandler(.close)
      
    @unknown default:
      completionHandler(.close)
    }
  }
  
  override func handle(
    action: ShieldAction,
    for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      openMainAppForChallenge()
      completionHandler(.close)
      
    case .secondaryButtonPressed:
      completionHandler(.close)
      
    @unknown default:
      completionHandler(.close)
    }
  }
  
  override func handle(
    action: ShieldAction,
    for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      openMainAppForChallenge()
      completionHandler(.close)
      
    case .secondaryButtonPressed:
      completionHandler(.close)
      
    @unknown default:
      completionHandler(.close)
    }
  }
  
  private func openMainAppForChallenge() {
    // Mark that we need to show a challenge when app opens
    UserDefaults.shared.set(true, forKey: "pendingShieldChallenge")
    UserDefaults.shared.synchronize()
    
    // Open main app via URL scheme
    // Note: Extensions have limited ability to open URLs, but we can try
    // The main app will also check for pendingShieldChallenge on launch
    if let url = URL(string: "\(SharedConstants.urlScheme)://challenge") {
      // Extensions can't directly open URLs, but the flag in UserDefaults
      // will be checked when user manually opens the app
      _ = url // Silence unused warning
    }
  }
}
