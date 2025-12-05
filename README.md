# Look Up, Silly! 👀

An iOS app to help you break free from doomscrolling by requiring challenges to access certain apps.

## Features

- **Real iOS Screen Time Integration**: Uses Apple's Screen Time API to actually block apps at the system level
- **App Blocking**: Choose which apps require challenges to access
- **Challenge System**: Solve puzzles to temporarily unlock blocked apps
  - Math Challenge: Solve 5 random math problems
  - Tic-Tac-Toe: Win 1 game against the computer
- **Temporary Unlock**: Complete a challenge to unlock all blocked apps for 5 minutes
- **FamilyActivityPicker**: Use iOS's native app selector to choose apps
- **Automatic Re-lock**: Apps automatically re-shield after the timeout
- **Onboarding Flow**: Easy setup with Screen Time authorization and app selection
- **Optional Contributions**: Support development with $5, $10, or $15 one-time contributions
- **Always Free**: No ads, no subscriptions, completely free to use
- **Settings**: Manage your blocked and allowed apps lists

## How It Works

1. **Block Apps**: Select distracting apps during onboarding
2. **Try to Open**: When you try to open a blocked app, iOS shows a shield
3. **Complete Challenge**: Open Look Up, Silly! and complete a challenge
4. **Temporary Access**: All blocked apps unlock for 5 minutes
5. **Auto Re-lock**: After 5 minutes, apps automatically shield again

This uses Apple's **Screen Time API** for real system-level blocking that can't be bypassed.

## Setup

### Prerequisites

- Xcode 16+ (for iOS 26 support)
- XcodeGen installed (`brew install xcodegen`)
- Physical iOS device (Screen Time API doesn't work fully in simulator)

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
3. **Build and run on a physical device** (Screen Time API requires real device)
4. Grant Screen Time permission when prompted
5. Select apps to block during onboarding
6. Test by trying to open a blocked app

### Important Notes

- **Screen Time API** requires a physical iOS device
- The app needs "Screen Time" permission (requested on first launch)
- Blocked apps will show an iOS system shield when opened
- Must complete a challenge in Look Up, Silly! to unlock

## Documentation

- **[SCREEN_TIME_INTEGRATION.md](SCREEN_TIME_INTEGRATION.md)** - Detailed Screen Time API documentation
- **[IMPLEMENTATION_NOTES.md](IMPLEMENTATION_NOTES.md)** - Implementation details and architecture
- **[REVENUECAT_SETUP.md](REVENUECAT_SETUP.md)** - RevenueCat contribution setup guide
- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide

## Requirements

- iOS 26.0+
- Xcode 16+
- Physical iOS device for testing
- Screen Time permission

## Privacy

- No data collection
- No analytics
- No network requests
- All data stays on device
- User has full control

## License

MIT License

