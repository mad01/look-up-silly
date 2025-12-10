import Foundation
import ManagedSettings
import ManagedSettingsUI
import os.log

private let logger = Logger(subsystem: "com.lookupsilly.app.ShieldAction", category: "Action")

/// Handles button taps on the shield view
final class ShieldActionExtension: ShieldActionDelegate {
  
  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }
  
  override func handle(
    action: ShieldAction,
    for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }
  
  override func handle(
    action: ShieldAction,
    for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }
  
  private func handleAction(_ action: ShieldAction, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    logger.info("🎬 ShieldActionExtension: handleAction called, action=\(String(describing: action))")
    switch action {
    case .primaryButtonPressed:
      // Mark that we need to show a challenge when app opens
      UserDefaults.shared.set(true, forKey: "pendingShieldChallenge")
      UserDefaults.shared.synchronize()
      completionHandler(.close)
      
    case .secondaryButtonPressed:
      completionHandler(.close)
      
    @unknown default:
      completionHandler(.close)
    }
  }
}
