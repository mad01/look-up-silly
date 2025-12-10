import ManagedSettings
import ManagedSettingsUI
import os.log
import UIKit

private let logger = Logger(subsystem: "com.lookupsilly.app.ShieldConfiguration", category: "Shield")

/// Custom shield configuration that appears when users try to open blocked apps
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  
  private func makeConfiguration(isWebDomain: Bool = false) -> ShieldConfiguration {
    logger.info("🛡️ ShieldConfigurationExtension: makeConfiguration called, isWebDomain=\(isWebDomain)")
    // Get pause duration from shared UserDefaults
    let pauseMinutes = UserDefaults.shared.integer(forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
    let duration = pauseMinutes > 0 ? pauseMinutes : SharedConstants.defaultPauseDurationMinutes
    
    let subtitleText = isWebDomain
      ? "Complete a quick challenge to unlock this site for \(duration) minutes"
      : "Complete a quick challenge to unlock this app for \(duration) minutes"
    
    return ShieldConfiguration(
      backgroundBlurStyle: .systemUltraThinMaterialDark,
      backgroundColor: UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
      icon: nil, // Extensions can't access main app's assets
      title: ShieldConfiguration.Label(
        text: "Time to Look Up!",
        color: UIColor(red: 0.98, green: 0.82, blue: 0.65, alpha: 1.0)
      ),
      subtitle: ShieldConfiguration.Label(
        text: subtitleText,
        color: UIColor.white.withAlphaComponent(0.8)
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: "Open Challenge",
        color: UIColor.white
      ),
      primaryButtonBackgroundColor: UIColor(red: 0.85, green: 0.55, blue: 0.35, alpha: 1.0),
      secondaryButtonLabel: ShieldConfiguration.Label(
        text: "Not Now",
        color: UIColor.white.withAlphaComponent(0.6)
      )
    )
  }
  
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    makeConfiguration(isWebDomain: false)
  }
  
  override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
    makeConfiguration(isWebDomain: false)
  }
  
  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    makeConfiguration(isWebDomain: true)
  }
  
  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
    makeConfiguration(isWebDomain: true)
  }
}
