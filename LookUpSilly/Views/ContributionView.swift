import SwiftUI

struct ContributionView: View {
  @StateObject private var revenueCat = RevenueCatManager.shared
  @State private var selectedProduct: RevenueCatManager.ContributionProduct?
  @State private var isProcessing = false
  @State private var showThankYou = false
  let onComplete: () -> Void
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
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
          .foregroundStyle(.pink.gradient)
        
        Text("Support Look Up, Silly!")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundColor(.white)
        
        Text("Help us keep this app free forever")
          .font(.system(size: 16))
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
      
      // Message
      VStack(alignment: .leading, spacing: 12) {
        Text("To keep this app free and ad-free, we rely on generous contributions from users like you.")
          .font(.subheadline)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
        
        Text("Your contribution helps us:")
          .font(.subheadline.bold())
          .foregroundColor(.white)
        
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
          .foregroundColor(.red)
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
          .foregroundColor(.gray)
      }
      .disabled(isProcessing)
      .padding(.bottom, 20)
      
      Text("100% optional • One-time payment")
        .font(.caption)
        .foregroundColor(.gray)
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
        .foregroundColor(.white)
      
      Text("Your contribution helps keep\nLook Up, Silly! free for everyone")
        .font(.system(size: 16))
        .foregroundColor(.gray)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: {
        onComplete()
      }) {
        Text("Continue")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
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
            .foregroundColor(.white)
          
          Text(product.description)
            .font(.caption)
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        if isProcessing && isSelected {
          ProgressView()
            .tint(.white)
        } else {
          Image(systemName: "arrow.right.circle.fill")
            .font(.title2)
            .foregroundColor(.white)
        }
      }
      .padding()
      .background(isSelected && isProcessing ? Color.blue.opacity(0.5) : Color.blue.opacity(0.2))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.blue, lineWidth: 2)
      )
    }
    .disabled(isProcessing)
  }
}

struct ContributionBenefitRow: View {
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 16))
        .foregroundColor(.blue)
        .frame(width: 24)
      
      Text(text)
        .font(.subheadline)
        .foregroundColor(.white)
    }
  }
}

#Preview {
  ContributionView(onComplete: {})
}

