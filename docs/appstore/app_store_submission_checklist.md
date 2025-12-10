# App Store Submission Checklist - Look Up, Silly!

Simplified checklist for Look Up, Silly! in-app purchase submission.

---

## ✅ 1. App Store Connect Setup

### Non-Consumable Products
- [ ] Go to: App Store Connect → Look Up Silly → Monetization → In-App Purchases
- [ ] Create 3 Non-Consumable products

### Product Details
| Product ID | Reference Name | Price | Type |
|------------|----------------|-------|------|
| `com.lookupsilly.app.contribution.small` | Small Contribution | $4.99 | Non-Consumable |
| `com.lookupsilly.app.contribution.medium` | Medium Contribution | $9.99 | Non-Consumable |
| `com.lookupsilly.app.contribution.large` | Large Contribution | $14.99 | Non-Consumable |

### Localization (for each product)
- [ ] English (U.S.) added
- [ ] **Display Name:** Small/Medium/Large Contribution
- [ ] **Description:** "Support Look Up, Silly! development" (under 55 chars ✅)

### Review Information
- [ ] Screenshot uploaded (showing contribution screen)
- [ ] Review notes explain these are optional one-time contributions

### Products Attached to App Version
- [ ] **CRITICAL:** Go to app version → In-App Purchases → Add all 3 products
- [ ] Verify they appear in the list

---

## ✅ 2. RevenueCat Configuration

### Account Setup
- [ ] RevenueCat account created
- [ ] Project: "Look Up Silly"
- [ ] iOS app added with bundle ID: `com.lookupsilly.app`

### App Store Connect API
- [ ] API key generated in App Store Connect
- [ ] API key uploaded to RevenueCat
- [ ] Connection status: "Connected"

### Products & Entitlement
- [ ] Product created: `com.lookupsilly.app.contribution.small`
- [ ] Product created: `com.lookupsilly.app.contribution.medium`
- [ ] Product created: `com.lookupsilly.app.contribution.large`
- [ ] Entitlement created: `contributor`
- [ ] All 3 products linked to entitlement
- [ ] Offering created with all 3 packages
- [ ] Offering set as **Current**

### API Key in Code
- [ ] Public API key copied from RevenueCat
- [ ] Added to `RevenueCatManager.swift` (line 20)
- [ ] Format: `appl_xxxxxx...`

---

## ✅ 3. Product ID Verification

**Must match EXACTLY in all three places:**

- [ ] App Store Connect: `com.lookupsilly.app.contribution.small`
- [ ] RevenueCat Dashboard: `com.lookupsilly.app.contribution.small`
- [ ] Code (`RevenueCatManager.swift`): `com.lookupsilly.app.contribution.small`

(Repeat for medium and large)

---

## ✅ 4. Code Implementation

### RevenueCat Initialized
- [ ] `RevenueCatManager.swift` configured
- [ ] API key not placeholder
- [ ] `configure()` called in `LookUpSillyApp.swift`

### Purchase UI
- [ ] ContributionView in onboarding flow
- [ ] "Support Development" button in Settings
- [ ] Both use `RevenueCatManager.shared`

### Required Buttons
- [ ] "Restore Purchases" in Settings (implemented)
- [ ] "Maybe Later" skip button (implemented)
- [ ] Contribution status display in Settings

---

## ✅ 5. Testing

### Simulator (StoreKit Config)
- [ ] `Configuration.storekit` file created
- [ ] Selected in Xcode scheme (Run → Options → StoreKit Configuration)
- [ ] Purchase tested and works
- [ ] Contribution unlocks correctly

### TestFlight (Critical!)
- [ ] Build uploaded to TestFlight
- [ ] Installed on real device
- [ ] Sandbox test account created
- [ ] **Purchase completed successfully**
- [ ] **Contribution confirmed**
- [ ] Thank you badge shows in Settings
- [ ] "Restore Purchases" works
- [ ] Can skip contribution and use app fully

**If TestFlight purchase fails, DO NOT submit!**

---

## ✅ 6. Legal & Agreements

### App Store Connect
- [ ] Agreements, Tax, and Banking → All completed
- [ ] Paid Applications Agreement: Signed and Active
- [ ] Banking information: Added
- [ ] Tax information: Completed

### Privacy & Terms
- [ ] Privacy policy hosted and accessible
- [ ] Links in app: Settings (Privacy Policy)
- [ ] Clear messaging that contributions are optional

---

## ✅ 7. App Store Listing

### Metadata
- [ ] App description mentions optional contributions
- [ ] Clear that app is FREE with all features
- [ ] Contribution amounts listed
- [ ] "No ads" mentioned

### Screenshots
- [ ] Show core app functionality
- [ ] Show challenge examples
- [ ] Consider showing contribution screen (optional)

---

## ✅ 8. Final Verification

### Build Status
- [ ] Latest build uploaded
- [ ] Version number incremented
- [ ] Release notes mention features

### Pre-Submit Check
- [ ] All above items checked ✅
- [ ] Products attached to app version
- [ ] TestFlight purchase works
- [ ] Product IDs match everywhere
- [ ] All required buttons present
- [ ] App fully functional without payment

---

## 📋 Response Template for App Review

```
Hello,

Thank you for reviewing Look Up, Silly! The optional contribution system is fully configured and ready for testing.

TESTING INSTRUCTIONS:

Method 1 (Onboarding):
1. Launch app → Complete onboarding steps
2. Contribution screen appears after app selection
3. Tap any amount ($4.99, $9.99, or $14.99)
4. Complete purchase with sandbox test account
5. "Thank You" confirmation appears

Method 2 (Settings):
1. Tap "Settings" tab
2. Find "Support Development" section
3. Tap contribution button
4. Complete purchase

VERIFICATION:
After contributing:
- Settings shows "Thank You! ✓" with checkmark
- Contribution options show as completed
- Can restore purchases on new devices

IMPORTANT NOTES:
- These are OPTIONAL one-time contributions
- The app is completely FREE with all features
- No features are locked behind payment
- Users can skip the contribution screen

PRODUCT DETAILS:
- Type: Non-Consumable (one-time)
- Product IDs: com.lookupsilly.app.contribution.small/medium/large
- Prices: $4.99, $9.99, $14.99 USD
- Implementation: RevenueCat SDK

The contribution flow works correctly in our testing. Please let me know if you have any questions.

Best regards
```

---

## 🚨 Common Issues to Avoid

### ❌ Products Not Attached
**Problem:** Reviewer can't see products  
**Fix:** App Version → In-App Purchases → Add products

### ❌ Product ID Mismatch  
**Problem:** Purchase fails  
**Fix:** Ensure identical in App Store Connect, RevenueCat, and code

### ❌ Missing "Restore Purchases"
**Problem:** Violates guidelines  
**Fix:** Button in Settings (already implemented ✅)

### ❌ Unclear That App is Free
**Problem:** Reviewer confusion  
**Fix:** Make clear contributions are optional, app fully functional without payment

### ❌ API Key Not Configured
**Problem:** RevenueCat doesn't work  
**Fix:** Replace placeholder with actual key in RevenueCatManager.swift

---

## ✅ Ready to Submit When:

- [x] All checklist items checked
- [x] TestFlight purchase works perfectly
- [x] Products attached to app version
- [x] Product IDs match exactly
- [x] Response message prepared
- [x] App fully functional without payment

---

## 📞 Resources

- [App Store Connect](https://appstoreconnect.apple.com)
- [RevenueCat Dashboard](https://app.revenuecat.com)
- [RevenueCat iOS Docs](https://www.revenuecat.com/docs/ios-native-4x)
- [Testing Instructions](./app_review_testing_instructions.md)

---

Good luck! 🚀

