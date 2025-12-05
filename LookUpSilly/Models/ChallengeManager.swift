import SwiftUI

class ChallengeManager: ObservableObject {
  @Published var currentChallenge: (any Challenge)?
  @Published var showingChallenge = false
  @Published var targetApp: InstalledApp?
  
  func requestAppAccess(app: InstalledApp, completion: @escaping (Bool) -> Void) {
    targetApp = app
    
    // Randomly select a challenge
    let challengeType = ChallengeType.allCases.randomElement() ?? .math
    
    switch challengeType {
    case .math:
      currentChallenge = MathChallenge()
    case .ticTacToe:
      currentChallenge = TicTacToeChallenge()
    }
    
    showingChallenge = true
  }
  
  func completeChallenge(success: Bool) {
    showingChallenge = false
    currentChallenge = nil
    targetApp = nil
  }
}

