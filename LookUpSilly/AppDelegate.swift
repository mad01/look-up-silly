import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Handle shortcut item from cold start
    if let shortcutItem = options.shortcutItem {
      handleShortcutItem(shortcutItem)
    }
    
    let configuration = UISceneConfiguration(
      name: connectingSceneSession.configuration.name,
      sessionRole: connectingSceneSession.role
    )
    configuration.delegateClass = SceneDelegate.self
    return configuration
  }
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // Update quick actions on launch
    updateQuickActions()
    return true
  }
  
  private func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
    if shortcutItem.type == "com.lookupsilly.app.pauseChallenges" {
      let isPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
      
      if isPaused {
        // If already paused, resume immediately
        UserDefaults.standard.set(false, forKey: "challengesPaused")
        UserDefaults.standard.removeObject(forKey: "pauseEndTime")
        
        // Notify the app to update UI and shields
        NotificationCenter.default.post(
          name: NSNotification.Name("ChallengesPausedStateChanged"),
          object: nil
        )
        
        // Update quick actions to reflect new state
        updateQuickActions()
      } else {
        // If not paused, show duration selector
        NotificationCenter.default.post(
          name: NSNotification.Name("ShowPauseDurationSheet"),
          object: nil
        )
      }
    }
  }
  
  func updateQuickActions() {
    DispatchQueue.main.async {
      let isPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
      
      let pauseAction = UIApplicationShortcutItem(
        type: "com.lookupsilly.app.pauseChallenges",
        localizedTitle: isPaused ? "Resume Challenges" : "Pause Challenges",
        localizedSubtitle: isPaused ? "Reactivate app blocking" : "Disable blocking temporarily",
        icon: UIApplicationShortcutIcon(systemImageName: isPaused ? "play.circle.fill" : "pause.circle.fill"),
        userInfo: nil
      )
      
      UIApplication.shared.shortcutItems = [pauseAction]
    }
  }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    // Handle shortcut item when app is already running
    if shortcutItem.type == "com.lookupsilly.app.pauseChallenges" {
      let isPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
      
      if isPaused {
        // If already paused, resume immediately
        UserDefaults.standard.set(false, forKey: "challengesPaused")
        UserDefaults.standard.removeObject(forKey: "pauseEndTime")
        
        // Notify the app to update UI and shields
        NotificationCenter.default.post(
          name: NSNotification.Name("ChallengesPausedStateChanged"),
          object: nil
        )
        
        // Update quick actions to reflect new state
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
          appDelegate.updateQuickActions()
        }
      } else {
        // If not paused, show duration selector
        NotificationCenter.default.post(
          name: NSNotification.Name("ShowPauseDurationSheet"),
          object: nil
        )
      }
      
      completionHandler(true)
    } else {
      completionHandler(false)
    }
  }
}

