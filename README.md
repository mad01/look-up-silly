# Look Up, Silly! 👀

An iOS app to help you break free from doomscrolling by requiring challenges to access certain apps.

## Features

- **Allowlist System**: Choose which apps you can access freely
- **Challenge System**: Solve puzzles to access blocked apps
  - Math Challenge: Solve 5 random math problems
  - Tic-Tac-Toe: Win 1 game against the computer
- **Onboarding Flow**: Easy setup with app selection
- **Settings**: Manage your allowed apps list

## Setup

### Prerequisites

- Xcode 16+ (for iOS 26 support)
- XcodeGen installed (`brew install xcodegen`)

### Installation

1. Clone the repository
2. Run the setup script:
   ```bash
   ./setup.sh
   ```

Or manually:
```bash
xcodegen generate
open LookUpSilly-iOS.xcodeproj
```

### App Icons

The project is set up with placeholder icon paths. To add proper icons:

1. Place your app icons in `LookUpSilly/Assets.xcassets/AppIcon.appiconset/`
2. You need the following sizes:
   - icon-20@2x.png (40x40)
   - icon-20@3x.png (60x60)
   - icon-29@2x.png (58x58)
   - icon-29@3x.png (87x87)
   - icon-40@2x.png (80x80)
   - icon-40@3x.png (120x120)
   - icon-60@2x.png (120x120)
   - icon-60@3x.png (180x180)
   - icon-1024.png (1024x1024)

## Project Structure

```
LookUpSilly/
├── LookUpSillyApp.swift        # App entry point
├── ContentView.swift            # Main content router
├── Models/
│   ├── AppSettings.swift        # App settings & storage
│   ├── InstalledApp.swift       # App model
│   ├── ChallengeProtocol.swift  # Challenge protocol
│   └── ChallengeManager.swift   # Challenge orchestration
├── Views/
│   ├── StartupView.swift        # Splash screen
│   ├── OnboardingView.swift     # Onboarding flow
│   ├── MainTabView.swift        # Main tab navigation
│   ├── HomeView.swift           # Home screen
│   └── SettingsView.swift       # Settings screen
├── Challenges/
│   ├── MathChallenge.swift      # Math puzzle challenge
│   └── TicTacToeChallenge.swift # Tic-Tac-Toe game challenge
├── Assets.xcassets/             # App assets
└── en.lproj/                    # Localizations
    └── Localizable.strings
```

## Architecture

### Challenge System

The app uses a protocol-based challenge system that makes it easy to add new challenges:

1. Create a new class conforming to `Challenge` protocol
2. Implement the required properties and view
3. Add to `ChallengeManager` selection logic

Each challenge is self-contained in a single file.

### Adding New Challenges

Example:
```swift
class MyChallenge: Challenge {
  let type = ChallengeType.myType
  var isCompleted = false
  
  func view(onComplete: @escaping () -> Void) -> AnyView {
    AnyView(MyChallengeView(onComplete: onComplete))
  }
}
```

## Building

1. Open the project in Xcode
2. Select your development team in Signing & Capabilities
3. Build and run on simulator or device

## License

MIT License

