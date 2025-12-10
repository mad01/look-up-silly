import SwiftUI
import FamilyControls

struct OnboardingViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var revenueCat = RevenueCatManager.shared
  @State private var currentPage = 0
  @State private var hasScreenTimeAuth = false
  @State private var cancelDelaySelection: Int = 60
  
  // Allow continuing in simulator even without app selection (for testing)
  private var canContinue: Bool {
    #if targetEnvironment(simulator)
    return true
    #else
    return !screenTimeManager.blockedApps.applicationTokens.isEmpty
    #endif
  }
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      if !hasScreenTimeAuth {
        ScreenTimeAuthView(onAuthorized: {
          hasScreenTimeAuth = true
        })
      } else {
        TabView(selection: $currentPage) {
          // Welcome page
          welcomePage
            .tag(0)
          
          // App selection page
          appSelectionPage
            .tag(1)
          
          // Cancel button delay page
          cancelDelayPage
            .tag(2)
          
          // How it works confirmation
          howItWorksConfirmPage
            .tag(3)
          
          // Contribution page
          contributionPage
            .tag(4)
          
          // Ready page
          readyPage
            .tag(5)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
      }
    }
    .onAppear {
      cancelDelaySelection = appSettings.challengeCancelDelaySeconds
    }
    .onChange(of: cancelDelaySelection) { _, newValue in
      appSettings.challengeCancelDelaySeconds = newValue
    }
  }
  
  var welcomePage: some View {
    VStack(spacing: 30) {
      Spacer()
      
      Image("AppLogo")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
      
      Text("Welcome to\nLook Up, Silly!")
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .multilineTextAlignment(.center)
        .foregroundColor(colors.textPrimary)
      
      Text("Take control of your screen time and break the doomscrolling habit")
        .font(.system(size: 18))
        .multilineTextAlignment(.center)
        .foregroundColor(colors.textSecondary)
        .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: { withAnimation { currentPage = 1 } }) {
        Text("Get Started")
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
  
  var appSelectionPage: some View {
    ScrollView {
      VStack(spacing: 30) {
        VStack(spacing: 12) {
          Text("Choose Apps to Block")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
            .padding(.top, 60)
          
          Text("Select apps that distract you.\nYou'll need to complete a challenge to open them.")
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, 40)
        }
        
        FamilyActivityPickerView(
          selection: $screenTimeManager.blockedApps,
          title: "Blocked Apps",
          subtitle: "These apps will require a challenge"
        )
        .padding(.horizontal, 20)
        
        Divider()
          .background(colors.divider)
          .padding(.horizontal, 40)
          .padding(.vertical, 20)
        
        FamilyActivityPickerView(
          selection: $screenTimeManager.allowedApps,
          title: "Always Allowed (Optional)",
          subtitle: "These apps will always be accessible"
        )
        .padding(.horizontal, 20)
        
        Button(action: {
          screenTimeManager.setBlockedApps(screenTimeManager.blockedApps)
          withAnimation { currentPage = 2 }
        }) {
          Text("Continue")
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canContinue ? colors.primary : colors.textDisabled)
            .cornerRadius(12)
        }
        .disabled(!canContinue)
        .padding(.horizontal, 40)
        .padding(.vertical, 30)
      }
    }
  }
  
  var cancelDelayPage: some View {
    ScrollView {
      VStack(spacing: 28) {
        VStack(spacing: 12) {
          Text(NSLocalizedString("onboarding.skip_delay.title", comment: ""))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
            .padding(.top, 60)
          
          Text(NSLocalizedString("onboarding.skip_delay.subtitle", comment: ""))
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, 40)
        }
        
        VStack(spacing: 16) {
          Text(String(format: NSLocalizedString("settings.skip_button_delay_description", comment: ""), cancelDelaySelection))
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          
          Picker("", selection: $cancelDelaySelection) {
            Text("30").tag(30)
            Text("60").tag(60)
            Text("90").tag(90)
            Text("120").tag(120)
            Text("180").tag(180)
          }
          .pickerStyle(.segmented)
        }
        .padding()
        .background(colors.surface)
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(colors.divider, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        
        Text(NSLocalizedString("settings.skip_button_delay_footer", comment: ""))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
        
        Text(NSLocalizedString("onboarding.skip_delay.note", comment: ""))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
        
        Button(action: {
          appSettings.challengeCancelDelaySeconds = cancelDelaySelection
          withAnimation { currentPage = 3 }
        }) {
          Text(NSLocalizedString("onboarding.skip_delay.button", comment: ""))
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.primary)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
      }
    }
  }
  
  var howItWorksConfirmPage: some View {
    ScrollView {
      VStack(spacing: 20) {
        VStack(spacing: 12) {
          Text(NSLocalizedString("onboarding.howitworks.title", comment: ""))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
            .padding(.top, 60)
          
          Text(NSLocalizedString("onboarding.howitworks.subtitle", comment: ""))
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, 40)
        }
        
        VStack(alignment: .leading, spacing: 12) {
          InfoRow(number: "1", text: NSLocalizedString("onboarding.howitworks.step1", comment: ""))
          InfoRow(number: "2", text: NSLocalizedString("onboarding.howitworks.step2", comment: ""))
          InfoRow(number: "3", text: NSLocalizedString("onboarding.howitworks.step3", comment: ""))
          InfoRow(number: "4", text: NSLocalizedString("onboarding.howitworks.step4", comment: ""))
          InfoRow(number: "5", text: NSLocalizedString("onboarding.howitworks.step5", comment: ""))
        }
        .padding()
        .background(colors.surface)
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(colors.divider, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        
        Button(action: {
          withAnimation { currentPage = 4 }
        }) {
          Text(NSLocalizedString("onboarding.howitworks.confirm", comment: ""))
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.primary)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
      }
    }
  }
  
  var contributionPage: some View {
    ScrollView {
      VStack(spacing: 24) {
        VStack(spacing: 12) {
          Text(NSLocalizedString("contribution.title", comment: ""))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
            .padding(.top, 60)
          
          Text(NSLocalizedString("contribution.subtitle", comment: ""))
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(colors.textSecondary)
            .padding(.horizontal, 40)
        }
        
        if revenueCat.hasContributed {
          HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(colors.success)
            Text(String(format: NSLocalizedString("contribution.thank_you_badge", comment: ""), revenueCat.contributionAmount ?? ""))
              .foregroundColor(colors.success)
              .font(.subheadline.weight(.semibold))
          }
          .padding(.horizontal, 20)
        }
        
        VStack(alignment: .leading, spacing: 12) {
          Text(NSLocalizedString("contribution.body_primary", comment: ""))
            .foregroundColor(colors.textPrimary)
            .multilineTextAlignment(.leading)
          
          Text(NSLocalizedString("contribution.body_secondary", comment: ""))
            .foregroundColor(colors.textPrimary)
            .bold()
          
          ContributionBenefitRow(icon: "hammer", text: NSLocalizedString("contribution.benefit.development", comment: ""))
          ContributionBenefitRow(icon: "sparkles", text: NSLocalizedString("contribution.benefit.features", comment: ""))
          ContributionBenefitRow(icon: "heart.fill", text: NSLocalizedString("contribution.benefit.free", comment: ""))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(colors.surface)
        .cornerRadius(16)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .stroke(colors.divider, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        
        Text(NSLocalizedString("contribution.note_optional", comment: ""))
          .font(.caption)
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
        
        VStack(spacing: 12) {
          ForEach(RevenueCatManager.ContributionProduct.allCases, id: \.self) { product in
            ContributionOptionButton(
              product: product,
              isSelected: false,
              isProcessing: revenueCat.isLoading,
              isDisabled: revenueCat.hasContributed
            ) {
              guard !revenueCat.hasContributed else { return }
              Task { @MainActor in
                _ = await revenueCat.contribute(product: product)
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .opacity(revenueCat.hasContributed ? 0.6 : 1.0)
        
        if let error = revenueCat.errorMessage {
          Text(error)
            .font(.caption)
            .foregroundColor(colors.error)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
        }
        
        Button(action: {
          withAnimation { currentPage = 4 }
        }) {
          Text(revenueCat.hasContributed ? NSLocalizedString("contribution.continue_thanks", comment: "") : NSLocalizedString("contribution.skip_now", comment: ""))
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.primary)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
        .disabled(revenueCat.isLoading)
      }
    }
  }
  
  var readyPage: some View {
    VStack(spacing: 30) {
      Spacer()
      
      Image(systemName: "checkmark.circle.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
        .foregroundStyle(.green.gradient)
      
      Text("You're All Set!")
        .font(.system(size: 36, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
      
      VStack(alignment: .leading, spacing: 16) {
        FeatureRowNew(icon: "shield.fill", text: "Blocked apps are now protected")
        FeatureRowNew(icon: "puzzlepiece", text: "Complete challenges to access")
        FeatureRowNew(icon: "brain", text: "Break the doomscroll habit")
      }
      .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: {
        appSettings.hasCompletedOnboarding = true
      }) {
        Text("Start Using Look Up, Silly!")
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
}

struct FeatureRowNew: View {
  @Environment(\.themeColors) private var colors
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundColor(colors.primary)
        .frame(width: 30)
      
      Text(text)
        .font(.system(size: 16))
        .foregroundColor(colors.textPrimary)
    }
  }
}

#Preview {
  OnboardingViewNew()
    .environmentObject(AppSettings())
}

