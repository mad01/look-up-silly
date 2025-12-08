import SwiftUI

enum ChallengeType: String, CaseIterable {
  case math = "Math Challenge"
  case ticTacToe = "Tic-Tac-Toe"
  case micro2048 = "Micro 2048"
  case colorTap = "Color Tap"
  case pathRecall = "Path Recall"
  
  var icon: String {
    switch self {
    case .math:
      return "function"
    case .ticTacToe:
      return "square.grid.3x3.fill"
    case .micro2048:
      return "square.grid.4x3.fill"
    case .colorTap:
      return "paintpalette.fill"
    case .pathRecall:
      return "brain.head.profile"
    }
  }
  
  private var titleKey: String {
    switch self {
    case .math:
      return "challenge.type.math.title"
    case .ticTacToe:
      return "challenge.type.tictactoe.title"
    case .micro2048:
      return "challenge.type.micro2048.title"
    case .colorTap:
      return "challenge.type.colortap.title"
    case .pathRecall:
      return "challenge.type.pathrecall.title"
    }
  }
  
  private var descriptionKey: String {
    switch self {
    case .math:
      return "challenge.type.math.description"
    case .ticTacToe:
      return "challenge.type.tictactoe.description"
    case .micro2048:
      return "challenge.type.micro2048.description"
    case .colorTap:
      return "challenge.type.colortap.description"
    case .pathRecall:
      return "challenge.type.pathrecall.description"
    }
  }
  
  var title: String {
    NSLocalizedString(titleKey, comment: "")
  }
  
  var description: String {
    NSLocalizedString(descriptionKey, comment: "")
  }
}

@MainActor
protocol Challenge {
  var type: ChallengeType { get }
  var isCompleted: Bool { get }
  @MainActor func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView
}

// Shared cancel action type for challenge views
typealias ChallengeCancelAction = @Sendable @MainActor () -> Void

// Environment key to allow host views to override cancel behavior
struct ChallengeCancelActionKey: EnvironmentKey {
  static let defaultValue: ChallengeCancelAction? = nil
}

extension EnvironmentValues {
  var challengeCancelAction: ChallengeCancelAction? {
    get { self[ChallengeCancelActionKey.self] }
    set { self[ChallengeCancelActionKey.self] = newValue }
  }
}

