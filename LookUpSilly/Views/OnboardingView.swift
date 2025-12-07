import SwiftUI

struct OnboardingView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @State private var selectedApps: Set<String> = []
  @State private var currentPage = 0
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      TabView(selection: $currentPage) {
        // Welcome page
        welcomePage
          .tag(0)
        
        // App selection page
        appSelectionPage
          .tag(1)
        
        // Ready page
        readyPage
          .tag(2)
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .indexViewStyle(.page(backgroundDisplayMode: .always))
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
    VStack(spacing: 20) {
      Text("Choose Allowed Apps")
        .font(.system(size: 28, weight: .bold))
        .foregroundColor(colors.textPrimary)
        .padding(.top, 60)
      
      Text("Select apps you can open freely.\nAll others will require a challenge.")
        .font(.system(size: 16))
        .multilineTextAlignment(.center)
        .foregroundColor(colors.textSecondary)
        .padding(.horizontal, 40)
      
      ScrollView {
        VStack(spacing: 12) {
          ForEach(InstalledApp.commonApps) { app in
            AppSelectionRow(
              app: app,
              isSelected: selectedApps.contains(app.bundleId)
            ) {
              if selectedApps.contains(app.bundleId) {
                selectedApps.remove(app.bundleId)
              } else {
                selectedApps.insert(app.bundleId)
              }
            }
          }
        }
        .padding(.horizontal, 20)
      }
      
      Button(action: {
        withAnimation { currentPage = 2 }
      }) {
        Text("Continue")
          .font(.headline)
          .foregroundColor(colors.textOnAccent)
          .frame(maxWidth: .infinity)
          .padding()
          .background(selectedApps.isEmpty ? colors.textDisabled : colors.primary)
          .cornerRadius(12)
      }
      .disabled(selectedApps.isEmpty)
      .padding(.horizontal, 40)
      .padding(.bottom, 30)
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
        FeatureRow(icon: "checkmark.shield", text: "Allowed apps open instantly")
        FeatureRow(icon: "puzzlepiece", text: "Other apps require a challenge")
        FeatureRow(icon: "brain", text: "Break the doomscroll habit")
      }
      .padding(.horizontal, 40)
      
      Spacer()
      
      Button(action: {
        appSettings.allowedApps = selectedApps
        appSettings.saveAllowedApps()
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

struct AppSelectionRow: View {
  @Environment(\.themeColors) private var colors
  let app: InstalledApp
  let isSelected: Bool
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack {
        Image(systemName: app.icon)
          .font(.system(size: 24))
          .foregroundColor(colors.primary)
          .frame(width: 40)
        
        Text(app.name)
          .font(.system(size: 18))
          .foregroundColor(colors.textPrimary)
        
        Spacer()
        
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? colors.success : colors.textDisabled)
          .font(.system(size: 24))
      }
      .padding()
      .background(colors.surface)
      .cornerRadius(12)
    }
  }
}

struct FeatureRow: View {
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
  OnboardingView()
    .environmentObject(AppSettings())
}

