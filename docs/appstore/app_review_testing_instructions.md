# App Review Testing Instructions - Look Up, Silly!

## TESTING INSTRUCTIONS (No login required)

### CONTRIBUTION TESTING:

**Method 1 (Primary - Onboarding):**
1. Launch app → Complete onboarding steps
2. Contribution screen appears after app selection
3. Tap any contribution option ($5, $10, or $15)
4. Complete purchase with sandbox test account
5. "Thank You" confirmation appears

**Method 2 (Alternative - Settings):**
1. Tap **Settings** tab
2. Scroll to **Contributions** section
3. Tap **"Support Development"** button
4. Select contribution amount
5. Complete purchase

**Verification After Contribution:**
- Settings shows "Thank You! ✓" badge
- Contribution options show checkmark
- Can restore purchases on other devices

**Contribution Tiers:**
- $4.99 - Buy us a coffee
- $9.99 - Support development
- $14.99 - Super supporter

**Important:** All contributions are **optional one-time payments**. The app is fully functional without any payment.

---

## QUICK TEST FLOW:

**Core App Functionality:**
1. **Onboarding** → Grant Screen Time permission → Select apps to block
2. **Home** → Shows blocked app status and challenge statistics
3. **Try to open blocked app** → Challenge appears
4. **Complete challenge** → App unlocks temporarily
5. **Settings** → Manage blocked/allowed apps, pause challenges

**Challenge Types:**
1. **Path Recall** - Remember and trace a pattern
2. **Color Tap** - Tap the word with the matching color
3. **Math** - Solve simple arithmetic
4. **Tic-Tac-Toe** - Win against AI opponent
5. **Micro 2048** - Complete a 2048 puzzle

---

## CONTEXT

**Purpose:** Screen time management app that requires completing a mindfulness challenge before accessing specified apps. Designed to create a "pause" moment before mindless phone use.

**Core Features:**
- Block any app with Screen Time API
- 5 unique challenge types
- Pause challenges temporarily
- Schedule blocking times
- Track challenge statistics
- iCloud sync for settings

---

## PRIVACY:

- Zero analytics, tracking, or data collection
- All settings synced via user's private iCloud
- No company servers
- Screen Time API used locally only
- GDPR compliant

---

## CONTRIBUTION (In-App Purchase):

**Type:** Non-Consumable (one-time payment)

**Products:**
| Product ID | Price | Description |
|------------|-------|-------------|
| `com.lookupsilly.app.contribution.small` | $4.99 | Small Contribution |
| `com.lookupsilly.app.contribution.medium` | $9.99 | Medium Contribution |
| `com.lookupsilly.app.contribution.large` | $14.99 | Large Contribution |

**Implementation:** RevenueCat SDK, StoreKit Testing configured

**Important:** These are **voluntary contributions** to support development. All app features work without payment. Users can skip contributions entirely.

---

## TECHNICAL:

- iOS 26.0+
- Swift 6, SwiftUI
- Screen Time API (FamilyControls)
- CloudKit for settings sync
- RevenueCat for contributions
- StoreKit Testing configured

---

## EXPECTED BEHAVIOR:

**Launch:** Onboarding if first launch, otherwise Home view
**Blocking:** Blocked apps show challenge overlay
**Challenges:** Random challenge type, complete to unlock
**Unlock:** Configurable unlock duration (default 15 minutes)
**Offline:** Full functionality offline, syncs when connected

---

## FAQ:

**Q: Screen Time permission?**
A: Required for blocking apps. Uses FamilyControls API.

**Q: Privacy?**
A: Zero tracking. All local/iCloud only.

**Q: Contributions?**
A: 100% optional. App fully free without payment.

**Q: Why one-time payment?**
A: No subscriptions. Pay once if you want, enjoy forever.

**Q: Restore purchases?**
A: Settings → Contributions → "Restore Purchases"

---

## SUMMARY:

✅ No login - works immediately
✅ Standard iOS in-app purchase (non-consumable)
✅ Settings in user's private iCloud
✅ Zero tracking
✅ GDPR compliant
✅ Fully functional without payment
✅ Offline-capable with auto sync

**Test Contributions:** Settings → "Support Development" or during onboarding

