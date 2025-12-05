# RevenueCat Setup Guide 💰

## Overview

Look Up, Silly! uses RevenueCat for one-time contributions ($5, $10, $15) to help keep the app free.

## Quick Start

### 1. Create RevenueCat Account

1. Go to [RevenueCat](https://www.revenuecat.com/)
2. Sign up for a free account
3. Create a new project

### 2. Get Your API Key

1. In RevenueCat dashboard, go to **Project Settings** → **API Keys**
2. Copy your **Public API Key** (starts with `appl_`)
3. Replace in `LookUpSilly/Services/RevenueCatManager.swift`:

```swift
private let apiKey = "YOUR_REVENUECAT_API_KEY_HERE"
// Replace with:
private let apiKey = "appl_YOUR_ACTUAL_KEY"
```

### 3. Create Products in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create 3 **Non-Consumable** products:

| Product ID | Display Name | Price | Type |
|------------|--------------|-------|------|
| `com.lookupsilly.app.contribution.small` | Small Contribution | $4.99 | Non-Consumable |
| `com.lookupsilly.app.contribution.medium` | Medium Contribution | $9.99 | Non-Consumable |
| `com.lookupsilly.app.contribution.large` | Large Contribution | $14.99 | Non-Consumable |

**Important:** Use "Non-Consumable" type so users only pay once!

### 4. Configure Products in RevenueCat

1. In RevenueCat dashboard, go to **Products**
2. Click **+ New Product** for each:
   - Product ID: `com.lookupsilly.app.contribution.small`
   - Store: App Store
   - Click **Save**
3. Repeat for medium and large contributions

### 5. Create Entitlement

1. Go to **Entitlements** in RevenueCat
2. Click **+ New Entitlement**
3. Name it: `contributor`
4. Click **Save**

### 6. Create Offering

1. Go to **Offerings** in RevenueCat
2. Click **+ New Offering**
3. Name it: `default`
4. Set as **Current**
5. Add all 3 contribution products to the offering
6. Click **Save**

### 7. Test in Simulator/Device

1. Build and run the app
2. Go through onboarding
3. Contribution screen should appear
4. In simulator, it will use StoreKit testing
5. On device with sandbox account, you can test real purchases

## Product Configuration Details

### Product IDs

```swift
enum ContributionProduct: String {
  case small = "com.lookupsilly.app.contribution.small"   // $5
  case medium = "com.lookupsilly.app.contribution.medium" // $10
  case large = "com.lookupsilly.app.contribution.large"   // $15
}
```

### App Store Connect Setup

For each product:

1. **Reference Name**: `Small Contribution` (or Medium/Large)
2. **Product ID**: `com.lookupsilly.app.contribution.small`
3. **Type**: Non-Consumable ⚠️ IMPORTANT!
4. **Price**: $4.99 (or $9.99/$14.99)
5. **Description**: "Support the development of Look Up, Silly!"
6. **Review Notes**: "This is a voluntary one-time contribution to support free app development"

### RevenueCat Dashboard Setup

1. **Project Name**: Look Up Silly
2. **App Bundle ID**: `com.lookupsilly.app`
3. **Products**: All 3 contribution products linked
4. **Entitlement**: `contributor` (granted on any contribution)
5. **Offering**: `default` (contains all 3 products)

## Testing

### StoreKit Testing (Local)

The `Configuration.storekit` file is included for local testing:

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** → **Options**
3. **StoreKit Configuration**: `Configuration.storekit`
4. Build and run
5. Contributions will work without real payment

### Sandbox Testing (Real Devices)

1. Create a Sandbox Tester in App Store Connect
2. Sign out of real App Store on device
3. Build and run app
4. Make test contribution
5. Sign in with sandbox account when prompted
6. Purchase completes without real payment

## How It Works in the App

### Onboarding Flow

```
Welcome → Contribution Screen → App Selection → Ready
```

Users see the contribution screen but can **skip** (there's a "Maybe Later" button).

### Contribution Screen

- 3 options: $5, $10, $15
- Clear descriptions
- One-time payment
- 100% optional
- Skip button prominent

### Settings

- Shows contribution status
- If contributed: "Thank You!" with checkmark
- If not contributed: Button to contribute
- Can restore purchases

### What Happens After Contributing

1. User selects contribution amount
2. RevenueCat processes payment
3. App shows "Thank You!" screen
4. Contribution status saved locally and in RevenueCat
5. Settings shows contribution badge
6. Can restore on other devices

## Revenue Tracking

RevenueCat dashboard shows:
- Total revenue
- Number of contributors
- Which contribution tiers are most popular
- Revenue over time
- Customer lifetime value

## Important Notes

### ⚠️ Use Non-Consumable Products

Make sure products are **Non-Consumable** not **Consumable**:
- **Non-Consumable**: User pays once, owns forever ✅
- **Consumable**: User can buy multiple times ❌

### No Subscription Required

This app uses one-time contributions, not subscriptions:
- Users pay once
- No recurring billing
- No expiration
- Can restore on other devices

### Privacy

- RevenueCat stores purchase info
- No personal data collected by our app
- Anonymous user IDs only
- GDPR/CCPA compliant

### Commission & Fees

- Apple takes 30% (or 15% for small businesses)
- RevenueCat is free for first $2,500/month revenue
- Your actual revenue: ~$3.50, $7, $10.50 per contribution

## Troubleshooting

### "API key not configured"

Update `RevenueCatManager.swift` with your actual API key.

### "No contribution packages available"

Check that:
1. Products exist in App Store Connect
2. Products are added to RevenueCat
3. Offering exists and is set as "Current"
4. Product IDs match exactly

### "Contribution failed"

Check:
1. Network connection
2. StoreKit configuration (for testing)
3. Sandbox account (for real device testing)
4. Product availability in your region

### "No previous contributions found"

This happens if:
1. User never contributed
2. Different Apple ID
3. Need to restore purchases

## Production Checklist

Before App Store submission:

- [ ] Replace API key with production key
- [ ] Create all 3 products in App Store Connect
- [ ] Configure products in RevenueCat
- [ ] Create `contributor` entitlement
- [ ] Create `default` offering
- [ ] Test with TestFlight
- [ ] Verify restore purchases works
- [ ] Add privacy policy mentioning RevenueCat
- [ ] Test on multiple devices
- [ ] Verify prices in different regions

## Support

- [RevenueCat Docs](https://www.revenuecat.com/docs)
- [RevenueCat Support](https://www.revenuecat.com/support)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)

## Summary

Look Up, Silly! is **free with no ads**. The contribution system:

✅ **Optional** - Users can skip
✅ **One-time** - Not a subscription
✅ **Transparent** - Clear pricing
✅ **Supportive** - Helps fund development
✅ **Fair** - Keeps app free for everyone

This creates a sustainable model where the app stays free while allowing users who find value in it to contribute back.

