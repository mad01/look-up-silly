import SwiftUI

/// View for testing/playing challenges
/// Can be accessed from Settings (development) or Home (for fun)
struct ChallengeTestView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var appSettings: AppSettings
  @State private var selectedChallengeType: ChallengeType = .math
  @State private var currentChallenge: (any Challenge)?
  @State private var showingChallenge = false
  let isDevelopment: Bool
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
              Image(systemName: isDevelopment ? "hammer.circle.fill" : "gamecontroller.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(colors.primary.gradient)
              
              Text(isDevelopment ? "Test Challenges" : "Play for Fun")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(colors.textPrimary)
              
              Text(isDevelopment ? "Test challenge mechanics" : "Practice challenges anytime")
                .font(.system(size: 16))
                .foregroundColor(colors.textSecondary)
            }
            .padding(.top, 40)
            
            // Challenge Type Selector
            VStack(alignment: .leading, spacing: 16) {
              Text("Select Challenge Type")
                .font(.headline)
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              VStack(spacing: 12) {
                ForEach(ChallengeType.allCases, id: \.self) { challengeType in
                  ChallengeTypeCard(
                    challengeType: challengeType,
                    isSelected: selectedChallengeType == challengeType
                  ) {
                    selectedChallengeType = challengeType
                  }
                }
              }
              .padding(.horizontal, 20)
            }
            
            // Start Button
            Button(action: {
              startChallenge()
            }) {
              HStack {
                Image(systemName: "play.circle.fill")
                  .font(.title2)
                Text("Start Challenge")
                  .font(.headline)
              }
              .foregroundColor(colors.textOnAccent)
              .frame(maxWidth: .infinity)
              .padding()
              .background(colors.primary)
              .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            if isDevelopment {
              // Development info
              VStack(alignment: .leading, spacing: 12) {
                Text("Development Mode")
                  .font(.headline)
                  .foregroundColor(colors.textPrimary)
                
                Text("• Challenges complete without unlocking apps")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
                Text("• Returns to app after completion")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
                Text("• Useful for testing challenge logic")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
              }
              .padding()
              .background(colors.warning.opacity(0.15))
              .cornerRadius(12)
              .padding(.horizontal, 20)
            }
          }
          .padding(.bottom, 30)
        }
      }
      .navigationTitle(isDevelopment ? "Test Challenges" : "Play for Fun")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
          .foregroundColor(colors.primary)
        }
      }
      .fullScreenCover(isPresented: $showingChallenge) {
        if let challenge = currentChallenge {
          ChallengeSheetView(
            challenge: challenge,
            onComplete: {
              showingChallenge = false
              // In test mode, we don't unlock apps
              if !isDevelopment {
                // For fun mode, show a message
                print("✅ Challenge completed! (Test mode - no app unlock)")
              }
            },
            appSettings: appSettings
          )
        }
      }
    }
  }
  
  private func startChallenge() {
    switch selectedChallengeType {
    case .math:
      let challenge = MathChallenge()
      challenge.isTestMode = true
      currentChallenge = challenge
    case .ticTacToe:
      let challenge = TicTacToeChallenge()
      challenge.isTestMode = true
      currentChallenge = challenge
    case .micro2048:
      let challenge = Micro2048Challenge()
      challenge.isTestMode = true
      currentChallenge = challenge
    }
    showingChallenge = true
  }
}

struct ChallengeTypeCard: View {
  @Environment(\.themeColors) private var colors
  let challengeType: ChallengeType
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: challengeType.icon)
          .font(.system(size: 32))
          .foregroundColor(colors.primary)
          .frame(width: 50)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(challengeType.rawValue)
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          
          Text(challengeType.description)
            .font(.caption)
            .foregroundColor(colors.textSecondary)
        }
        
        Spacer()
        
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? colors.success : colors.textDisabled)
          .font(.system(size: 24))
      }
      .padding()
      .background(isSelected ? colors.primary.opacity(0.2) : colors.surface)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? colors.primary : Color.clear, lineWidth: 2)
      )
    }
  }
}

#Preview {
  ChallengeTestView(isDevelopment: true)
    .environmentObject(AppSettings())
}

