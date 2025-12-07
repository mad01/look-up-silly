import AppIntents
import SwiftUI

@available(iOS 16.0, *)
struct PauseChallengesIntent: AppIntent {
    static let title: LocalizedStringResource = "Pause Challenges"
    
    static let description = IntentDescription("Temporarily pause app challenges instead of deleting the app")
    
    static let openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Toggle the paused state
        let settings = AppSettings()
        settings.challengesPaused.toggle()
        
        let message = settings.challengesPaused ? 
            "Challenges paused. All apps are now accessible without challenges." :
            "Challenges resumed. Blocked apps now require challenges to access."
        
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

@available(iOS 16.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PauseChallengesIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "Pause challenges in \(.applicationName)"
            ],
            shortTitle: "Pause Challenges",
            systemImageName: "pause.circle.fill"
        )
    }
}

