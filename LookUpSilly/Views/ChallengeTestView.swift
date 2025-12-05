import SwiftUI

/// View for testing/playing challenges
/// Can be accessed from Settings (development) or Home (for fun)
struct ChallengeTestView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedChallengeType: ChallengeType = .math
  @State private var currentChallenge: (any Challenge)?
  @State private var showingChallenge = false
  let isDevelopment: Bool
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.black.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
              Image(systemName: isDevelopment ? "hammer.circle.fill" : "gamecontroller.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue.gradient)
              
              Text(isDevelopment ? "Test Challenges" : "Play for Fun")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
              
              Text(isDevelopment ? "Test challenge mechanics" : "Practice challenges anytime")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            }
            .padding(.top, 40)
            
            // Challenge Type Selector
            VStack(alignment: .leading, spacing: 16) {
              Text("Select Challenge Type")
                .font(.headline)
                .foregroundColor(.white)
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
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            if isDevelopment {
              // Development info
              VStack(alignment: .leading, spacing: 12) {
                Text("Development Mode")
                  .font(.headline)
                  .foregroundColor(.white)
                
                Text("• Challenges complete without unlocking apps")
                  .font(.caption)
                  .foregroundColor(.gray)
                Text("• Returns to app after completion")
                  .font(.caption)
                  .foregroundColor(.gray)
                Text("• Useful for testing challenge logic")
                  .font(.caption)
                  .foregroundColor(.gray)
              }
              .padding()
              .background(Color.orange.opacity(0.1))
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
          .foregroundColor(.blue)
        }
      }
      .sheet(isPresented: $showingChallenge) {
        if let challenge = currentChallenge {
          ChallengeSheetView(challenge: challenge) {
            showingChallenge = false
            // In test mode, we don't unlock apps
            if !isDevelopment {
              // For fun mode, show a message
              print("✅ Challenge completed! (Test mode - no app unlock)")
            }
          }
        }
      }
    }
  }
  
  private func startChallenge() {
    switch selectedChallengeType {
    case .math:
      currentChallenge = MathChallenge()
    case .ticTacToe:
      currentChallenge = TicTacToeChallenge()
    }
    showingChallenge = true
  }
}

struct ChallengeTypeCard: View {
  let challengeType: ChallengeType
  let isSelected: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Image(systemName: challengeType.icon)
          .font(.system(size: 32))
          .foregroundColor(.blue)
          .frame(width: 50)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(challengeType.rawValue)
            .font(.headline)
            .foregroundColor(.white)
          
          Text(challengeType.description)
            .font(.caption)
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundColor(isSelected ? .green : .gray)
          .font(.system(size: 24))
      }
      .padding()
      .background(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
      )
    }
  }
}

#Preview {
  ChallengeTestView(isDevelopment: true)
}

