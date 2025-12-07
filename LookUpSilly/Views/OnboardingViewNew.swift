import SwiftUI
import FamilyControls

struct OnboardingViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @State private var currentPage = 0
  @State private var hasScreenTimeAuth = false
  
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
          
          // Contribution page (commented out - enable when RevenueCat is configured)
          // contributionPage
          //   .tag(1)
          
          // App selection page
          appSelectionPage
            .tag(1)
          
          // Ready page
          readyPage
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
      }
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
  
  var contributionPage: some View {
    ContributionView(onComplete: {
      withAnimation { currentPage = 2 }
    })
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

