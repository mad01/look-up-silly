# Screen Time Integration 🛡️

## Overview

Look Up, Silly! uses Apple's **Screen Time API** (FamilyControls and ManagedSettings frameworks) to actually block apps on your device and require challenges to access them.

## How It Works

### 1. Authorization Flow
- On first launch, the app requests Screen Time authorization
- User must grant permission in the system dialog
- Authorization is required to manage app blocking

### 2. App Selection
- Uses `FamilyActivityPicker` to select apps to block
- Can also select categories (Social Media, Games, etc.)
- Apps not in the block list or allow list are unaffected

### 3. App Blocking (Shielding)
- Blocked apps show an iOS system shield when opened
- The shield cannot be bypassed
- User must open Look Up, Silly! to unlock

### 4. Challenge & Unlock
- User opens Look Up, Silly!
- Completes a challenge (Math or Tic-Tac-Toe)
- All blocked apps unlock for **5 minutes**
- After 5 minutes, shields automatically reactivate

## Technical Implementation

### Frameworks Used

```swift
import FamilyControls     // Authorization and app selection
import ManagedSettings    // App shielding/blocking
```

### Key Components

#### 1. ScreenTimeManager (`Services/ScreenTimeManager.swift`)
- Singleton manager for all Screen Time operations
- Handles authorization
- Manages app shields
- Provides temporary access after challenges

#### 2. ScreenTimeAuthView (`Views/ScreenTimeAuthView.swift`)
- UI for requesting Screen Time authorization
- Shows during onboarding

#### 3. FamilyActivityPickerView (`Views/FamilyActivityPickerView.swift`)
- Wraps iOS's `FamilyActivityPicker`
- Lets users select apps to block or allow

#### 4. Entitlements
- `com.apple.developer.family-controls` - Required for Screen Time API

### App Flow

```
1. Launch App
   ↓
2. Request Screen Time Authorization
   ↓
3. User Selects Apps to Block
   ↓
4. Apps are Shielded
   ↓
5. User Tries to Open Blocked App
   ↓
6. iOS Shows Shield Screen
   ↓
7. User Opens Look Up, Silly!
   ↓
8. User Completes Challenge
   ↓
9. Shields Removed for 5 Minutes
   ↓
10. Shields Automatically Reactivate
```

## API Methods

### ScreenTimeManager

```swift
// Request authorization
try await screenTimeManager.requestAuthorization()

// Set blocked apps
screenTimeManager.setBlockedApps(selection)

// Set allowed apps
screenTimeManager.setAllowedApps(selection)

// Grant temporary access (default 5 minutes)
screenTimeManager.grantTemporaryAccess(duration: 300)

// Remove all shields
screenTimeManager.removeAllShields()
```

## Limitations & Considerations

### What Works
✅ Block any installed apps
✅ Block app categories
✅ System-level blocking (can't be bypassed)
✅ Automatic re-activation after timeout
✅ Works even if Look Up, Silly! is closed

### What Doesn't Work
❌ Can't intercept app launch directly
❌ Can't show challenges on shield screen
❌ Can't selectively unlock individual apps
❌ User must manually open Look Up, Silly! to unlock

### iOS Requirements
- iOS 15.0+ (Screen Time API introduced)
- iOS 16.0+ (for some shield customizations)
- iOS 26.0 (current target)

### Privacy & Permissions
- Requires "Screen Time" permission (system-level)
- User can revoke permission in Settings > Screen Time
- App doesn't collect or transmit any usage data
- All data stays on device

## User Experience

### First Time Setup
1. Grant Screen Time permission
2. Select distracting apps to block
3. Apps are immediately shielded

### Daily Use
1. Try to open blocked app → Shield appears
2. Open Look Up, Silly!
3. Complete challenge
4. All blocked apps unlock for 5 minutes
5. Continue browsing or using apps
6. After 5 minutes, automatic re-lock

### Customization
- Add/remove blocked apps anytime
- Change allowed apps list
- Temporarily disable all shields
- Reset and start over

## Future Enhancements

Possible improvements:
- [ ] Custom shield messages (iOS 16+)
- [ ] Per-app unlock instead of all-or-nothing
- [ ] Adjustable timeout duration
- [ ] Daily usage statistics
- [ ] Challenge difficulty levels
- [ ] Streak tracking and rewards
- [ ] Scheduled blocking (work hours, sleep time)
- [ ] Emergency bypass codes

## Testing

### On Simulator
⚠️ **Screen Time API may not work fully in simulator**
- Authorization may fail
- Shields may not appear
- Test on real device for full functionality

### On Device
✅ Test on physical iPhone
- Grant Screen Time permission
- Add a test app (like Safari) to block list
- Try to open it → should see shield
- Complete challenge in Look Up, Silly!
- Verify app unlocks for 5 minutes

## Troubleshooting

### "Screen Time authorization denied"
- Check Settings > Screen Time
- Ensure Look Up, Silly! has permission
- Try resetting permissions and re-authorizing

### "Shields not appearing"
- Verify app is in blocked list
- Check that shields were applied
- Restart device if needed

### "Can't select apps"
- Ensure Screen Time permission granted
- Check that FamilyActivityPicker is showing
- Try re-requesting authorization

## Resources

- [Apple FamilyControls Documentation](https://developer.apple.com/documentation/familycontrols)
- [Apple ManagedSettings Documentation](https://developer.apple.com/documentation/managedsettings)
- [Screen Time API WWDC Session](https://developer.apple.com/videos/play/wwdc2021/10123/)

