import SwiftUI

struct ContributionView: View {
  @Environment(\.themeColors) private var colors
  @StateObject private var revenueCat = RevenueCatManager.shared
  @State private var selectedProduct: RevenueCatManager.ContributionProduct?
  @State private var isProcessing = false
  @State private var showThankYou = false
  let onComplete: () -> Void
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      if showThankYou {
        thankYouView
      } else {
        contributionFormView
      }
    }
  }
  
  var contributionFormView: some View {
    VStack(spacing: 30) {
      Spacer()
      
      // Header
      VStack(spacing: 12) {
        Image(systemName: "heart.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 80, height: 80)
          .foregroundStyle(colors.premium.gradient)
        
        Text("Support Look Up, Silly!")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundColor(colors.textPrimary)
        
        Text("Help us keep this app free forever")
          .font(.system(size: 16))
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
      }
      
      // Message
      VStack(alignment: .leading, spacing: 12) {
        Text("To keep this app free and ad-free, we rely on generous contributions from users like you.")
          .font(.subheadline)
          .foregroundColor(colors.textPrimary)
          .multilineTextAlignment(.center)
        
        Text("Your contribution helps us:")
          .font(.subheadline.bold())
          .foregroundColor(colors.textPrimary)
        
        ContributionBenefitRow(icon: "hammer", text: "Continue development")
        ContributionBenefitRow(icon: "sparkles", text: "Add new features")
        ContributionBenefitRow(icon: "heart.fill", text: "Keep it free for everyone")
      }
      .padding(.horizontal, 40)
      
      // Contribution Options
      VStack(spacing: 12) {
        ForEach(RevenueCatManager.ContributionProduct.allCases, id: \.self) { product in
          ContributionOptionButton(
            product: product,
            isSelected: selectedProduct == product,
            isProcessing: isProcessing
          ) {
            selectedProduct = product
            Task {
              await handleContribution(product)
            }
          }
        }
      }
      .padding(.horizontal, 40)
      
      if let error = revenueCat.errorMessage {
        Text(error)
          .font(.caption)
          .foregroundColor(colors.error)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
      }
      
      Spacer()
      
      // Skip button
      Button(action: {
        onComplete()
      }) {
        Text("Maybe Later")
          .font(.subheadline)
          .foregroundColor(colors.textSecondary)
      }
      .disabled(isProcessing)
      .padding(.bottom, 20)
      
      Text("100% optional • One-time payment")
        .font(.caption)
        .foregroundColor(colors.textSecondary)
        .padding(.bottom, 40)
    }
  }
  
  var thankYouView: some View {
    VStack(spacing: 30) {
      Spacer()
      
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .foregroundStyle(.green.gradient)
      
      Text("Thank You! 🎉")
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
      
      Text("Your contribution helps keep\nLook Up, Silly! free for everyone")
        .font(.system(size: 16))
        .foregroundColor(colors.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: {
        onComplete()
      }) {
        Text("Continue")
          .font(.headline)
          .foregroundColor(colors.textOnAccent)
          .frame(maxWidth: .infinity)
          .padding()
          .background(colors.primary)
          .cornerRadius(12)
      }
      .padding(.horizontal, 40)
      .padding(.bottom, 50)
    }
  }
  
  private func handleContribution(_ product: RevenueCatManager.ContributionProduct) async {
    isProcessing = true
    let success = await revenueCat.contribute(product: product)
    isProcessing = false
    
    if success {
      withAnimation {
        showThankYou = true
      }
    }
  }
}

struct ContributionOptionButton: View {
  @Environment(\.themeColors) private var colors
  let product: RevenueCatManager.ContributionProduct
  let isSelected: Bool
  let isProcessing: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(product.displayAmount)
            .font(.title2.bold())
            .foregroundColor(colors.textPrimary)
          
          Text(product.description)
            .font(.caption)
            .foregroundColor(colors.textSecondary)
        }
        
        Spacer()
        
        if isProcessing && isSelected {
          ProgressView()
            .tint(colors.primary)
        } else {
          Image(systemName: "arrow.right.circle.fill")
            .font(.title2)
            .foregroundColor(colors.primary)
        }
      }
      .padding()
      .background(isSelected && isProcessing ? colors.primary.opacity(0.3) : colors.primary.opacity(0.15))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(colors.primary, lineWidth: 2)
      )
    }
    .disabled(isProcessing)
  }
}

struct ContributionBenefitRow: View {
  @Environment(\.themeColors) private var colors
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundColor(colors.primary)
        .frame(width: 24)
      
      Text(text)
        .font(.subheadline)
        .foregroundColor(colors.textPrimary)
    }
  }
}

#Preview {
  ContributionView(onComplete: {})
}

