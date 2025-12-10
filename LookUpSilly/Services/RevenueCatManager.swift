import Foundation
import StoreKit
import RevenueCat

/// Manager for handling one-time contributions via RevenueCat
@MainActor
public class RevenueCatManager: NSObject, ObservableObject {
  public static let shared = RevenueCatManager()
  
  // MARK: - Published Properties
  
  @Published public var hasContributed: Bool = false
  @Published public var contributionAmount: String?
  @Published public var isLoading: Bool = false
  @Published public var errorMessage: String?
  
  // MARK: - Configuration
  
  // TODO: Replace with your actual RevenueCat Public API key
  private let apiKey = "YOUR_REVENUECAT_API_KEY_HERE"
  
  // Product identifiers for one-time contributions
  public enum ContributionProduct: String, CaseIterable {
    case small = "com.lookupsilly.app.contribution.small"
    case medium = "com.lookupsilly.app.contribution.medium"
    case large = "com.lookupsilly.app.contribution.large"
    
    var displayAmount: String {
      switch self {
      case .small: return "$5"
      case .medium: return "$10"
      case .large: return "$15"
      }
    }
    
    var description: String {
      switch self {
      case .small: return "Buy us a coffee"
      case .medium: return "Support development"
      case .large: return "Super supporter"
      }
    }
  }
  
  // Entitlement identifier for contributors
  private let contributorEntitlementID = "contributor"
  
  // MARK: - Initialization
  
  private override init() {
    super.init()
  }
  
  /// Configure RevenueCat SDK
  public func configure() {
    guard apiKey != "YOUR_REVENUECAT_API_KEY_HERE" else {
      print("⚠️ RevenueCat: API key not configured. Contribution features disabled.")
      return
    }
    
    Purchases.logLevel = .debug
    Purchases.configure(withAPIKey: apiKey)
    Purchases.shared.delegate = self
    
    print("✅ RevenueCat configured successfully")
    
    // Check initial contribution status
    Task {
      await refreshContributionStatus()
    }
  }
  
  // MARK: - Contribution Status
  
  /// Check if user has contributed
  public func refreshContributionStatus() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let customerInfo = try await Purchases.shared.customerInfo()
      
      // Check if user has contributor entitlement (one-time purchase)
      let hasEntitlement = customerInfo.entitlements[contributorEntitlementID]?.isActive == true
      
      await MainActor.run {
        self.hasContributed = hasEntitlement
        self.isLoading = false
        
        // Store contribution status
        UserDefaults.standard.set(hasEntitlement, forKey: "hasContributed")
        
        if hasEntitlement {
          // Get the contribution amount if available
          if let productId = customerInfo.nonSubscriptions.first?.productIdentifier,
             let product = ContributionProduct(rawValue: productId) {
            self.contributionAmount = product.displayAmount
            UserDefaults.standard.set(product.displayAmount, forKey: "contributionAmount")
          }
        }
        
        print("✅ RevenueCat: Contribution status - \(hasEntitlement ? "Contributed" : "Not contributed")")
      }
    } catch {
      await MainActor.run {
        // Load from cache if available
        self.hasContributed = UserDefaults.standard.bool(forKey: "hasContributed")
        self.contributionAmount = UserDefaults.standard.string(forKey: "contributionAmount")
        
        self.errorMessage = "Failed to check contribution status: \(error.localizedDescription)"
        self.isLoading = false
        print("❌ RevenueCat error: \(error)")
      }
    }
  }
  
  // MARK: - Purchase Flow
  
  /// Purchase a contribution package
  public func contribute(product: ContributionProduct) async -> Bool {
    // Prevent multiple contributions; RevenueCat entitlements are single-use for this context
    if hasContributed {
      errorMessage = NSLocalizedString("contribution.already_contributed_message", comment: "")
      return false
    }
    
    isLoading = true
    errorMessage = nil
    
    do {
      // Fetch available offerings
      let offerings = try await Purchases.shared.offerings()
      
      guard let offering = offerings.current else {
        await MainActor.run {
          self.errorMessage = "No contribution packages available"
          self.isLoading = false
        }
        return false
      }
      
      // Find the package that matches the product identifier
      guard let package = offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == product.rawValue }) else {
        await MainActor.run {
          self.errorMessage = "Contribution package not found"
          self.isLoading = false
        }
        return false
      }
      
      // Purchase the package
      let result = try await Purchases.shared.purchase(package: package)
      
      // Check if purchase was successful
      let hasEntitlement = result.customerInfo.entitlements[contributorEntitlementID]?.isActive == true
      
      await MainActor.run {
        self.hasContributed = hasEntitlement
        self.contributionAmount = product.displayAmount
        self.isLoading = false
        
        // Store contribution status
        UserDefaults.standard.set(hasEntitlement, forKey: "hasContributed")
        UserDefaults.standard.set(product.displayAmount, forKey: "contributionAmount")
        
        if hasEntitlement {
          print("🎉 RevenueCat: Contribution successful! Thank you!")
        }
      }
      
      return hasEntitlement
      
    } catch {
      await MainActor.run {
        let errorCode = (error as NSError).code
        if errorCode == 1 { // User cancelled
          print("ℹ️ RevenueCat: User cancelled contribution")
          self.errorMessage = nil
        } else {
          self.errorMessage = "Contribution failed: \(error.localizedDescription)"
          print("❌ RevenueCat contribution error: \(error)")
        }
        self.isLoading = false
      }
      return false
    }
  }
  
  // MARK: - Restore Purchases
  
  /// Restore previous contributions
  public func restorePurchases() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let customerInfo = try await Purchases.shared.restorePurchases()
      
      let hasEntitlement = customerInfo.entitlements[contributorEntitlementID]?.isActive == true
      
      await MainActor.run {
        self.hasContributed = hasEntitlement
        self.isLoading = false
        
        UserDefaults.standard.set(hasEntitlement, forKey: "hasContributed")
        
        if hasEntitlement {
          print("✅ RevenueCat: Purchases restored!")
        } else {
          self.errorMessage = "No previous contributions found"
          print("ℹ️ RevenueCat: No contributions to restore")
        }
      }
    } catch {
      await MainActor.run {
        self.errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        self.isLoading = false
        print("❌ RevenueCat restore error: \(error)")
      }
    }
  }
}

// MARK: - PurchasesDelegate
extension RevenueCatManager: PurchasesDelegate {
  nonisolated public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
    let hasEntitlement = customerInfo.entitlements[contributorEntitlementID]?.isActive == true
    
    Task { @MainActor in
      self.hasContributed = hasEntitlement
      UserDefaults.standard.set(hasEntitlement, forKey: "hasContributed")
      
      print("📢 RevenueCat: Contribution status updated - \(hasEntitlement ? "Contributed" : "Not contributed")")
    }
  }
}

