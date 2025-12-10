import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Custom shield configuration that appears when users try to open blocked apps
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    // Get pause duration from shared UserDefaults
    let pauseMinutes = UserDefaults.shared.integer(forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
    let duration = pauseMinutes > 0 ? pauseMinutes : SharedConstants.defaultPauseDurationMinutes
    
    return ShieldConfiguration(
      backgroundBlurStyle: .systemUltraThinMaterialDark,
      backgroundColor: UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
      icon: UIImage(named: "AppIcon"),
      title: ShieldConfiguration.Label(
        text: "Time to Look Up!",
        color: UIColor(red: 0.98, green: 0.82, blue: 0.65, alpha: 1.0) // Warm sand color
      ),
      subtitle: ShieldConfiguration.Label(
        text: "Complete a quick challenge to unlock this app for \(duration) minutes",
        color: UIColor.white.withAlphaComponent(0.8)
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: "Open Challenge",
        color: UIColor.white
      ),
      primaryButtonBackgroundColor: UIColor(red: 0.85, green: 0.55, blue: 0.35, alpha: 1.0), // Warm orange
      secondaryButtonLabel: ShieldConfiguration.Label(
        text: "Not Now",
        color: UIColor.white.withAlphaComponent(0.6)
      )
    )
  }
  
  override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
    configuration(shielding: application)
  }
  
  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    let pauseMinutes = UserDefaults.shared.integer(forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
    let duration = pauseMinutes > 0 ? pauseMinutes : SharedConstants.defaultPauseDurationMinutes
    
    return ShieldConfiguration(
      backgroundBlurStyle: .systemUltraThinMaterialDark,
      backgroundColor: UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
      icon: UIImage(named: "AppIcon"),
      title: ShieldConfiguration.Label(
        text: "Time to Look Up!",
        color: UIColor(red: 0.98, green: 0.82, blue: 0.65, alpha: 1.0)
      ),
      subtitle: ShieldConfiguration.Label(
        text: "Complete a quick challenge to unlock this site for \(duration) minutes",
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
  
  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
    configuration(shielding: webDomain)
  }
}
