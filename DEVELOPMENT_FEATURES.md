# Development Features 🛠️

## Overview

Look Up, Silly! includes several features to make development and testing easier, plus fun features for users to practice challenges.

## 1. Test Challenges from Settings (Development Mode)

**What:** Test challenge mechanics during development without affecting app blocking.

**Where:** Settings → "Test Challenges" (only visible in DEBUG builds)

**How it Works:**
- Only appears when building with DEBUG configuration
- Opens `ChallengeTestView` in development mode
- Challenges work normally but DON'T unlock apps
- Returns to app after completion
- Useful for testing challenge logic

**Usage:**
```swift
#if DEBUG
Button("Test Challenges") {
  showingTestChallenges = true
}
#endif
```

**When to Use:**
- Testing new challenge implementations
- Debugging challenge UI
- Verifying challenge completion logic
- Testing without needing blocked apps

---

## 2. Play for Fun (User Feature)

**What:** Users can practice challenges anytime for fun, without needing to unlock apps.

**Where:** Home → "Practice" → "Play Challenges for Fun"

**How it Works:**
- Available to all users (not just DEBUG)
- Opens `ChallengeTestView` in "play for fun" mode
- Select challenge type (Math or Tic-Tac-Toe)
- Complete challenges without unlocking anything
- Just for practice and entertainment

**Usage:**
```swift
Button("Play Challenges for Fun") {
  showingPlayForFun = true
}
```

**Benefits:**
- Helps users practice before real challenges
- Makes challenges feel less stressful
- Adds entertainment value
- Users can improve their skills

---

## 3. RevenueCat - Easily Disabled

**What:** RevenueCat integration is commented out by default for easy development.

**Where:** `LookUpSillyApp.swift` init method

**Current State - DISABLED:**
```swift
init() {
  // MARK: - RevenueCat Configuration
  // Uncomment to enable contribution system
  // Requires: RevenueCat account, API key, and product setup
  // See: REVENUECAT_SETUP.md for instructions
  
  // Task { @MainActor in
  //   RevenueCatManager.shared.configure()
  // }
}
```

**To Enable:**
1. Uncomment the RevenueCat configuration
2. Add your API key to `RevenueCatManager.swift`
3. Set up products in RevenueCat dashboard
4. Uncomment contribution page in `OnboardingViewNew.swift`

**Why Disabled:**
- Easier initial development
- No need for RevenueCat setup to test app
- Can focus on core features first
- Easy to enable when ready

**Onboarding Flow Without RevenueCat:**
```
Welcome → App Selection → Ready
```

**Onboarding Flow With RevenueCat:**
```
Welcome → Contribution → App Selection → Ready
```

---

## Challenge Test View Details

### File: `ChallengeTestView.swift`

Unified view for both development testing and user practice.

### Features:

1. **Challenge Type Selection**
   - Visual cards for each challenge type
   - Shows challenge name, icon, and description
   - Selected state with blue highlight

2. **Start Challenge**
   - Big blue "Start Challenge" button
   - Opens selected challenge in modal

3. **Mode Indicator**
   - Development mode: Shows orange info box
   - Fun mode: Shows practice instructions

4. **Challenge Completion**
   - Development: Just closes modal
   - Fun: Closes modal with success message
   - Neither mode unlocks apps

### UI:

```
┌─────────────────────────┐
│   Test Challenges       │ (Development)
│   Play for Fun          │ (User)
├─────────────────────────┤
│  [Icon]                 │
│  Select Challenge Type  │
│                         │
│  ┌─────────────────┐   │
│  │ Math Challenge  │   │ ← Card 1
│  └─────────────────┘   │
│  ┌─────────────────┐   │
│  │ Tic-Tac-Toe    │   │ ← Card 2
│  └─────────────────┘   │
│                         │
│  ┌─────────────────┐   │
│  │ Start Challenge │   │ ← Button
│  └─────────────────┘   │
│                         │
│  [Development Info]     │ (if dev mode)
└─────────────────────────┘
```

---

## How to Use - Development Workflow

### 1. Testing New Challenge

```swift
// 1. Create new challenge
class MyChallenge: Challenge {
  // Implementation
}

// 2. Add to ChallengeType enum
enum ChallengeType {
  case math
  case ticTacToe
  case myChallenge // NEW
}

// 3. Test from Settings
// Settings → Test Challenges → Select "My Challenge" → Test
```

### 2. Testing Without Screen Time

If you don't want to set up Screen Time yet:

```swift
// Skip Screen Time authorization in onboarding
// Just test challenge mechanics
// Use Settings → Test Challenges
```

### 3. Testing Challenge UI

```swift
// 1. Build in DEBUG mode
// 2. Go to Settings
// 3. Tap "Test Challenges"
// 4. Select challenge type
// 5. Start and complete
// 6. Verify UI/UX works correctly
```

---

## User Features

### Practice Mode

**Purpose:** Let users practice challenges without pressure

**Benefits:**
- Reduces anxiety about real challenges
- Helps users understand how challenges work
- Provides entertainment value
- Builds user confidence

**User Flow:**
```
1. User opens app
2. Goes to Home tab
3. Sees "Practice" section
4. Taps "Play Challenges for Fun"
5. Selects challenge type
6. Practices as many times as they want
7. No consequences, just fun
```

---

## Conditional Compilation

### DEBUG-only Features

Features that only appear in DEBUG builds:

```swift
#if DEBUG
// Test challenges button in Settings
Button("Test Challenges") { }

// Development info boxes
Text("Development Mode")

// Extra logging
print("🛠️ Dev mode active")
#endif
```

### How to Build for DEBUG:

```bash
# Xcode: Select "Debug" scheme
# Or use Xcode's default build (⌘R)
```

### How to Build for Release:

```bash
# Xcode: Product → Scheme → Edit Scheme
# Run → Build Configuration → Release
# Or archive for distribution
```

---

## Configuration States

### Development State (Default):

```yaml
RevenueCat: ❌ Disabled
Contribution Screen: ❌ Hidden
Test Challenges: ✅ Visible (DEBUG)
Play for Fun: ✅ Visible
```

### Production State:

```yaml
RevenueCat: ✅ Enabled
Contribution Screen: ✅ Visible
Test Challenges: ❌ Hidden (Release)
Play for Fun: ✅ Visible
```

---

## Re-enabling RevenueCat

### Step 1: Configure RevenueCat

```swift
// In RevenueCatManager.swift
private let apiKey = "appl_YOUR_ACTUAL_KEY"
```

### Step 2: Enable in App

```swift
// In LookUpSillyApp.swift
init() {
  Task { @MainActor in
    RevenueCatManager.shared.configure() // Uncomment
  }
}
```

### Step 3: Add to Onboarding

```swift
// In OnboardingViewNew.swift
TabView(selection: $currentPage) {
  welcomePage.tag(0)
  contributionPage.tag(1)  // Uncomment
  appSelectionPage.tag(2)
  readyPage.tag(3)
}
```

### Step 4: Update Page Navigation

```swift
// Update page numbers if adding contribution back
withAnimation { currentPage = 3 } // Instead of 2
```

---

## Testing Checklist

### Challenge Testing:

- [ ] Test Math Challenge
  - [ ] All 5 problems work
  - [ ] Correct answers advance
  - [ ] Incorrect answers show error
  - [ ] Completion works
  
- [ ] Test Tic-Tac-Toe
  - [ ] Board renders correctly
  - [ ] Can tap cells
  - [ ] Computer makes moves
  - [ ] Win detection works
  - [ ] Can play multiple games

### Development Mode:

- [ ] Test Challenges button appears (DEBUG)
- [ ] Button hidden in Release
- [ ] Can select challenge types
- [ ] Challenges complete without unlocking
- [ ] Returns to app properly

### Play for Fun Mode:

- [ ] Available from Home
- [ ] Works for all users
- [ ] Challenges work same as real
- [ ] No app unlocking
- [ ] Can practice repeatedly

### RevenueCat States:

- [ ] App works with RevenueCat disabled
- [ ] Onboarding skips contribution
- [ ] Can enable RevenueCat later
- [ ] Contribution works when enabled

---

## Summary

These development features make it easier to:

✅ **Test challenges** without Screen Time setup
✅ **Develop faster** without RevenueCat initially
✅ **Add user value** with practice mode
✅ **Deploy flexibly** - enable features when ready
✅ **Debug easily** with development-only tools

The app is fully functional even with RevenueCat disabled, making development smoother while keeping the option to enable monetization later.

