import SwiftUI

@MainActor
class ChallengeManager: ObservableObject {
  @Published var currentChallenge: (any Challenge)?
  @Published var showingChallenge = false
  @Published var targetApp: InstalledApp?
  
  func requestAppAccess(
    app: InstalledApp,
    enabledChallenges: Set<ChallengeType> = Set(ChallengeType.allCases),
    completion: @escaping (Bool) -> Void
  ) {
    targetApp = app
    
    // Randomly select a challenge from enabled types (fallback to all if empty)
    let availableTypes = enabledChallenges.isEmpty ? Set(ChallengeType.allCases) : enabledChallenges
    let challengeType = availableTypes.randomElement() ?? .math
    
    switch challengeType {
    case .math:
      currentChallenge = MathChallenge()
    case .ticTacToe:
      currentChallenge = TicTacToeChallenge()
    case .micro2048:
      currentChallenge = Micro2048Challenge()
    case .colorTap:
      currentChallenge = ColorTapChallenge()
    case .pathRecall:
      currentChallenge = PathRecallChallenge()
    case .gravityDrop:
      currentChallenge = GravityGameChallenge()
    }
    
    showingChallenge = true
  }
  
  func completeChallenge(success: Bool) {
    showingChallenge = false
    currentChallenge = nil
    targetApp = nil
  }
}

