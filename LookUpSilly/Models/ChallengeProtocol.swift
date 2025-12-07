import SwiftUI

enum ChallengeType: String, CaseIterable {
  case math = "Math Challenge"
  case ticTacToe = "Tic-Tac-Toe"
  case micro2048 = "Micro 2048"
  
  var icon: String {
    switch self {
    case .math:
      return "function"
    case .ticTacToe:
      return "square.grid.3x3.fill"
    case .micro2048:
      return "square.grid.4x3.fill"
    }
  }
  
  var description: String {
    switch self {
    case .math:
      return "Solve 5 math problems"
    case .ticTacToe:
      return "Win 1 game against computer"
    case .micro2048:
      return "Reach 64 in the puzzle"
    }
  }
}

protocol Challenge {
  var type: ChallengeType { get }
  var isCompleted: Bool { get }
  @MainActor func view(onComplete: @escaping () -> Void) -> AnyView
}

