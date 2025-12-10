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
    .safeAreaInset(edge: .top) {
      HStack {
        Spacer()
        Button(action: {
          onComplete()
        }) {
          Image(systemName: "xmark")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(colors.textPrimary)
            .padding(10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(NSLocalizedString("contribution.close", comment: "")))
        .disabled(isProcessing)
      }
      .padding(.top, 8)
      .padding(.trailing, 16)
    }
  }
  
  var contributionFormView: some View {
    ViewThatFits(in: .vertical) {
      contributionFormContent(useSpacers: true)
        .padding(.horizontal, 20)
      
      ScrollView {
        contributionFormContent(useSpacers: false)
          .padding(.horizontal, 20)
          .padding(.vertical, 24)
      }
    }
  }
  
  var thankYouView: some View {
    ViewThatFits(in: .vertical) {
      thankYouContent(useSpacers: true)
        .padding(.horizontal, 20)
      
      ScrollView {
        thankYouContent(useSpacers: false)
          .padding(.horizontal, 20)
          .padding(.vertical, 24)
      }
    }
  }
  
  @ViewBuilder
  private func contributionFormContent(useSpacers: Bool) -> some View {
    VStack(spacing: 30) {
      if useSpacers { Spacer() }
      
      contributionHeader
      
      if revenueCat.hasContributed {
        contributionBadge
      }
      
      contributionMessage
      
      contributionNote
      
      contributionOptions
      
      contributionError
      
      if useSpacers { Spacer() }
      
      contributionSkip
      
      contributionFooter
    }
  }
  
  private var contributionHeader: some View {
    VStack(spacing: 12) {
      Image(systemName: "heart.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 80, height: 80)
        .foregroundStyle(colors.premium.gradient)
      
      Text(NSLocalizedString("contribution.title", comment: ""))
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
      
      Text(NSLocalizedString("contribution.subtitle", comment: ""))
        .font(.system(size: 16))
        .foregroundColor(colors.textSecondary)
        .multilineTextAlignment(.center)
    }
  }
  
  private var contributionBadge: some View {
    HStack(spacing: 10) {
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(colors.success)
      Text(String(format: NSLocalizedString("contribution.thank_you_badge", comment: ""), revenueCat.contributionAmount ?? ""))
        .foregroundColor(colors.success)
        .font(.subheadline.weight(.semibold))
    }
    .padding(.horizontal, 20)
  }
  
  private var contributionMessage: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(NSLocalizedString("contribution.body_primary", comment: ""))
        .font(.subheadline)
        .foregroundColor(colors.textPrimary)
        .multilineTextAlignment(.center)
      
      Text(NSLocalizedString("contribution.body_secondary", comment: ""))
        .font(.subheadline.bold())
        .foregroundColor(colors.textPrimary)
      
      ContributionBenefitRow(icon: "hammer", text: NSLocalizedString("contribution.benefit.development", comment: ""))
      ContributionBenefitRow(icon: "sparkles", text: NSLocalizedString("contribution.benefit.features", comment: ""))
      ContributionBenefitRow(icon: "heart.fill", text: NSLocalizedString("contribution.benefit.free", comment: ""))
    }
    .padding(.horizontal, 40)
  }
  
  private var contributionNote: some View {
    Text(NSLocalizedString("contribution.note_optional", comment: ""))
      .font(.caption)
      .foregroundColor(colors.textSecondary)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 32)
  }
  
  private var contributionOptions: some View {
    VStack(spacing: 12) {
      ForEach(RevenueCatManager.ContributionProduct.allCases, id: \.self) { product in
        ContributionOptionButton(
          product: product,
          isSelected: selectedProduct == product,
          isProcessing: isProcessing || revenueCat.isLoading,
          isDisabled: revenueCat.hasContributed
        ) {
          guard !revenueCat.hasContributed else { return }
          selectedProduct = product
          Task { await handleContribution(product) }
        }
      }
    }
    .padding(.horizontal, 40)
    .opacity(revenueCat.hasContributed ? 0.6 : 1.0)
  }
  
  @ViewBuilder
  private var contributionError: some View {
    if let error = revenueCat.errorMessage {
      Text(error)
        .font(.caption)
        .foregroundColor(colors.error)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
  }
  
  private var contributionSkip: some View {
    Button(action: {
      onComplete()
    }) {
      Text(NSLocalizedString("contribution.maybe_later", comment: ""))
        .font(.subheadline)
        .foregroundColor(colors.textSecondary)
    }
    .disabled(isProcessing || revenueCat.isLoading)
    .padding(.bottom, 20)
  }
  
  private var contributionFooter: some View {
    Text(NSLocalizedString("contribution.footer", comment: ""))
      .font(.caption)
      .foregroundColor(colors.textSecondary)
      .padding(.bottom, 40)
  }
  
  @ViewBuilder
  private func thankYouContent(useSpacers: Bool) -> some View {
    VStack(spacing: 30) {
      if useSpacers { Spacer() }
      
      thankYouHeader
      
      thankYouBody
      
      if useSpacers { Spacer() }
      
      thankYouButton
    }
  }
  
  private var thankYouHeader: some View {
    VStack(spacing: 30) {
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .foregroundStyle(.green.gradient)
      
      Text(NSLocalizedString("contribution.thank_you_title", comment: ""))
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
    }
  }
  
  private var thankYouBody: some View {
    Text(NSLocalizedString("contribution.thank_you_body", comment: ""))
      .font(.system(size: 16))
      .foregroundColor(colors.textSecondary)
      .multilineTextAlignment(.center)
      .padding(.horizontal, 40)
  }
  
  private var thankYouButton: some View {
    Button(action: {
      onComplete()
    }) {
      Text(NSLocalizedString("contribution.continue", comment: ""))
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
  let isDisabled: Bool
  let action: () -> Void
  
  var body: some View {
    let buttonDisabled = isProcessing || isDisabled
    
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
        
        if isDisabled {
          Image(systemName: "checkmark.circle.fill")
            .font(.title2)
            .foregroundColor(colors.success)
        } else if isProcessing && isSelected {
          ProgressView()
            .tint(colors.primary)
        } else {
          Image(systemName: "arrow.right.circle.fill")
            .font(.title2)
            .foregroundColor(colors.primary)
        }
      }
      .padding()
      .background(
        isDisabled
        ? colors.success.opacity(0.18)
        : (isSelected && isProcessing ? colors.primary.opacity(0.3) : colors.primary.opacity(0.15))
      )
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isDisabled ? colors.success : colors.primary, lineWidth: 2)
      )
    }
    .disabled(buttonDisabled)
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

