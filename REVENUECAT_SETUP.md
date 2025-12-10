# RevenueCat Setup Guide 💰

Complete guide for setting up RevenueCat integration for Look Up, Silly! one-time contributions.

## Overview

Look Up, Silly! uses RevenueCat for one-time contributions ($5, $10, $15) to help keep the app free. This guide covers:
1. App Store Connect setup
2. RevenueCat dashboard configuration
3. Connecting the two together
4. Testing locally and in TestFlight

---

## Part 1: App Store Connect Setup

### 1.1 Prerequisites

You need:
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] App already created in App Store Connect (Look Up, Silly!)
- [ ] Bundle ID: `com.lookupsilly.app`

### 1.2 Create In-App Purchase Products

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select **Look Up, Silly!** app
3. Go to **Monetization** → **In-App Purchases**
4. Click **+** to create new products

**Create 3 Non-Consumable products:**

| Field | Small | Medium | Large |
|-------|-------|--------|-------|
| **Type** | Non-Consumable | Non-Consumable | Non-Consumable |
| **Reference Name** | Small Contribution | Medium Contribution | Large Contribution |
| **Product ID** | `com.lookupsilly.app.contribution.small` | `com.lookupsilly.app.contribution.medium` | `com.lookupsilly.app.contribution.large` |
| **Price** | $4.99 (Tier 5) | $9.99 (Tier 10) | $14.99 (Tier 15) |

### 1.3 Add Localization for Each Product

For each product, add English (U.S.) localization:

**Small Contribution:**
- Display Name: `Small Contribution`
- Description: `Buy us a coffee to support development`

**Medium Contribution:**
- Display Name: `Medium Contribution`
- Description: `Support continued development and new features`

**Large Contribution:**
- Display Name: `Large Contribution`
- Description: `Become a super supporter and help keep the app free`

### 1.4 Add Review Information

For each product:
- Upload a screenshot of the contribution screen
- Review Notes: `This is a voluntary one-time contribution to support free app development. No features are unlocked or locked by this purchase.`

### 1.5 Generate App Store Connect API Key

RevenueCat needs this to validate purchases:

1. Go to **Users and Access** → **Integrations** → **App Store Connect API**
2. Click **+** to generate a new key
3. Name: `RevenueCat Integration`
4. Access: `Admin` or `App Manager`
5. **Download the .p8 file** (you can only download it once!)
6. Note down:
   - **Key ID** (e.g., `ABC123DEF4`)
   - **Issuer ID** (at the top of the page)
   - **Downloaded .p8 file**

### 1.6 Complete Agreements

1. Go to **Agreements, Tax, and Banking**
2. Ensure **Paid Applications** agreement is signed and active
3. Complete banking and tax information

---

## Part 2: RevenueCat Setup

### 2.1 Create RevenueCat Account

1. Go to [RevenueCat](https://www.revenuecat.com/)
2. Sign up for a free account
3. Verify your email

### 2.2 Create a New Project

1. In RevenueCat dashboard, click **+ Create New Project**
2. Project Name: `Look Up Silly`
3. Click **Create Project**

### 2.3 Add iOS App

1. In your project, go to **Apps** → **+ New App**
2. Platform: **iOS**
3. App Name: `Look Up, Silly!`
4. Bundle ID: `com.lookupsilly.app`
5. Click **Save**

### 2.4 Connect App Store Connect API

1. In RevenueCat, go to your app → **App Store Connect API**
2. Enter:
   - **Issuer ID**: (from step 1.5)
   - **Key ID**: (from step 1.5)
   - **Upload .p8 file**: (from step 1.5)
3. Click **Save**
4. Verify **Connection Status** shows "Connected" ✅

### 2.5 Get Your Public API Key

1. Go to **Project Settings** → **API Keys**
2. Find the **Public app-specific API key** for iOS
3. Copy the key (starts with `appl_`)
4. **Save this key** - you'll need it for the code

### 2.6 Create Products in RevenueCat

1. Go to **Products** → **+ New Product**
2. Create 3 products:

| Store Product ID | Store |
|------------------|-------|
| `com.lookupsilly.app.contribution.small` | App Store |
| `com.lookupsilly.app.contribution.medium` | App Store |
| `com.lookupsilly.app.contribution.large` | App Store |

### 2.7 Create Entitlement

1. Go to **Entitlements** → **+ New Entitlement**
2. Identifier: `contributor`
3. Description: `User has made a one-time contribution`
4. Click **Save**
5. **Link all 3 products** to this entitlement

### 2.8 Create Offering

1. Go to **Offerings** → **+ New Offering**
2. Identifier: `default`
3. Description: `Default contribution offering`
4. Click **Save**
5. Click **+ Add Package** (3 times):
   - Package 1: Custom identifier `small`, Product: small contribution
   - Package 2: Custom identifier `medium`, Product: medium contribution
   - Package 3: Custom identifier `large`, Product: large contribution
6. **Set as Current Offering** ⚠️ Important!

---

## Part 3: Code Configuration

### 3.1 Update API Key

In `LookUpSilly/Services/RevenueCatManager.swift`, replace the placeholder:

```swift
// Line 20 - Replace this:
private let apiKey = "YOUR_REVENUECAT_API_KEY_HERE"

// With your actual key:
private let apiKey = "appl_YOUR_ACTUAL_API_KEY"
```

### 3.2 Verify Configuration

Ensure `LookUpSillyApp.swift` calls configure on launch:

```swift
init() {
  RevenueCatManager.shared.configure()
  // ... other init code
}
```

### 3.3 Product IDs (Already Configured)

The following are already set up in the code:

```swift
enum ContributionProduct: String, CaseIterable {
  case small = "com.lookupsilly.app.contribution.small"
  case medium = "com.lookupsilly.app.contribution.medium"
  case large = "com.lookupsilly.app.contribution.large"
}

private let contributorEntitlementID = "contributor"
```

---

## Part 4: Testing

### 4.1 Local Testing (StoreKit Configuration)

The `Configuration.storekit` file is already set up for local testing:

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Options**
3. **StoreKit Configuration**: Select `Configuration.storekit`
4. Build and run

Purchases will work without real payment in the simulator.

### 4.2 Manual Toggle Testing (DEBUG builds)

For quick UI testing without purchase flow:

1. Build in DEBUG mode
2. Go to Settings → Development section
3. Toggle **"Manual Contribution Toggle"** ON
4. Contribution status updates immediately
5. **Important:** Disable before testing actual purchase flow

### 4.3 Sandbox Testing (Real Devices)

1. **Create Sandbox Tester:**
   - App Store Connect → Users and Access → Sandbox → Testers
   - Create a new tester with a unique email

2. **On Device:**
   - Settings → App Store → Sign out of production account
   - Build and install app via Xcode
   - When purchasing, sign in with sandbox account
   - Complete purchase (no real charge)

### 4.4 TestFlight Testing

1. Upload build to TestFlight
2. Install on device
3. Use sandbox account for purchases
4. Verify:
   - [ ] Purchase completes successfully
   - [ ] "Thank You" screen appears
   - [ ] Settings shows contribution badge
   - [ ] Restore purchases works

---

## Part 5: Production Checklist

### Before App Store Submission

- [ ] Replace placeholder API key with production key
- [ ] All 3 products created in App Store Connect
- [ ] All 3 products in RevenueCat
- [ ] Products linked to `contributor` entitlement
- [ ] Offering set as "Current"
- [ ] Tested in TestFlight with sandbox account
- [ ] Verify restore purchases works
- [ ] Products attached to app version in App Store Connect

### App Store Connect Final Steps

1. Go to your app version
2. **In-App Purchases** → Add all 3 products
3. Verify products appear in the list
4. Submit for review

---

## Troubleshooting

### "API key not configured"

**Fix:** Update `RevenueCatManager.swift` line 20 with your actual API key.

### "No contribution packages available"

**Check:**
1. Products exist in App Store Connect
2. Products added to RevenueCat
3. Products linked to entitlement
4. Offering exists and set as "Current"
5. Product IDs match exactly (case-sensitive!)

### "Contribution failed"

**Check:**
1. Network connection
2. StoreKit configuration selected (for simulator)
3. Sandbox account signed in (for real device)
4. Products are in "Ready to Submit" state in App Store Connect

### "No previous contributions found"

**This means:**
1. User hasn't contributed, OR
2. Different Apple ID, OR
3. Need to call restore purchases

### RevenueCat shows "Not Connected"

**Fix:**
1. Regenerate App Store Connect API key
2. Re-upload to RevenueCat
3. Wait a few minutes for connection

---

## How It Works in the App

### User Flow

```
Onboarding → Contribution Screen (optional) → App Selection → Home
                     ↓
              Can skip with "Maybe Later"
```

### Contribution Screen

- 3 options: $5, $10, $15
- Clear descriptions
- One-time payment (non-consumable)
- 100% optional
- Skip button prominent

### After Contributing

1. User selects amount
2. RevenueCat processes payment
3. "Thank You" screen appears
4. Contribution status saved locally and in RevenueCat
5. Settings shows "Thank You!" badge
6. Can restore on other devices

---

## Revenue & Fees

| Amount | Apple (30%) | You Receive |
|--------|-------------|-------------|
| $4.99 | $1.50 | $3.49 |
| $9.99 | $3.00 | $6.99 |
| $14.99 | $4.50 | $10.49 |

*Note: Small Business Program (15% commission) may apply if eligible.*

RevenueCat is free for first $2,500/month revenue.

---

## Privacy Notes

- RevenueCat stores purchase info with anonymous user IDs
- No personal data collected by our app
- GDPR/CCPA compliant
- See RevenueCat's privacy policy for details

---

## Support Resources

- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [RevenueCat iOS Guide](https://www.revenuecat.com/docs/ios-native-4x)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)

---

## Summary

Look Up, Silly! is **free with no ads**. The contribution system:

✅ **Optional** - Users can skip  
✅ **One-time** - Not a subscription  
✅ **Transparent** - Clear pricing  
✅ **Supportive** - Helps fund development  
✅ **Fair** - Keeps app free for everyone

This creates a sustainable model where the app stays free while allowing users who find value in it to contribute back.

