import SwiftUI

// MARK: - Tic-Tac-Toe Challenge
// Challenge: Win 1 game of tic-tac-toe against the computer to unlock app access

class TicTacToeChallenge: Challenge, ObservableObject {
  let type = ChallengeType.ticTacToe
  @Published var isCompleted = false
  @Published var gamesWon = 0
  let requiredWins = 1
  var isTestMode = false
  
  @MainActor
  func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView {
    AnyView(TicTacToeView(challenge: self, onComplete: onComplete, appSettings: appSettings))
  }
}

// MARK: - Game State

enum Player {
  case human, computer, none
  
  var symbol: String {
    switch self {
    case .human: return "X"
    case .computer: return "O"
    case .none: return ""
    }
  }
}

enum GameState {
  case playing, humanWon, computerWon, draw
  
  var message: String {
    switch self {
    case .playing: return "Your turn"
    case .humanWon: return "You won! 🎉"
    case .computerWon: return "Computer won. Try again!"
    case .draw: return "It's a draw. Try again!"
    }
  }
}

// MARK: - Tic-Tac-Toe Game Logic

@MainActor
class TicTacToeGame: ObservableObject {
  @Published var board: [Player] = Array(repeating: .none, count: 9)
  @Published var gameState: GameState = .playing
  @Published var isComputerThinking = false
  @Published var selectedPieceIndex: Int? = nil
  
  let winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6]             // Diagonals
  ]
  
  let maxPieces = 3
  
  private func countPieces(for player: Player) -> Int {
    return board.filter { $0 == player }.count
  }
  
  func makeMove(at index: Int) {
    guard gameState == .playing else { return }
    
    let humanPieceCount = countPieces(for: .human)
    
    // If we have 3 pieces, we need to move one
    if humanPieceCount >= maxPieces {
      if let selectedIndex = selectedPieceIndex {
        // Moving selected piece to new position
        guard board[index] == .none else { return }
        board[selectedIndex] = .none
        board[index] = .human
        selectedPieceIndex = nil
      } else {
        // Selecting a piece to move
        guard board[index] == .human else { return }
        selectedPieceIndex = index
        return // Don't trigger computer move yet
      }
    } else {
      // Placing a new piece
      guard board[index] == .none else { return }
      board[index] = .human
    }
    
    if checkWin(for: .human) {
      gameState = .humanWon
      return
    }
    
    if isBoardFull() {
      gameState = .draw
      return
    }
    
    // Computer's turn
    isComputerThinking = true
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
      self.computerMove()
      self.isComputerThinking = false
    }
  }
  
  private func computerMove() {
    let computerPieceCount = countPieces(for: .computer)
    
    if computerPieceCount >= maxPieces {
      // Must move an existing piece
      if let move = findBestMove(mustMove: true) {
        board[move.from] = .none
        board[move.to] = .computer
      }
    } else {
      // Can place a new piece
      if let move = findBestMove(mustMove: false) {
        board[move.to] = .computer
      }
    }
    
    if checkWin(for: .computer) {
      gameState = .computerWon
    } else if isBoardFull() {
      gameState = .draw
    }
  }
  
  private func findBestMove(mustMove: Bool) -> (from: Int, to: Int)? {
    if mustMove {
      // Try to win by moving a piece
      if let winningMove = findWinningMoveByMoving(for: .computer) {
        // Find a computer piece to move to the winning position
        let computerPieces = board.enumerated().filter { $0.element == .computer }.map { $0.offset }
        if let pieceToMove = computerPieces.randomElement() {
          return (from: pieceToMove, to: winningMove)
        }
      }
      
      // Try to block human from winning
      if let blockMove = findWinningMoveByMoving(for: .human) {
        // Find a computer piece to move to block
        let computerPieces = board.enumerated().filter { $0.element == .computer }.map { $0.offset }
        if let pieceToMove = computerPieces.randomElement() {
          return (from: pieceToMove, to: blockMove)
        }
      }
      
      // Random move
      let computerPieces = board.enumerated().filter { $0.element == .computer }.map { $0.offset }
      let availableSpots = board.enumerated().filter { $0.element == .none }.map { $0.offset }
      
      if let from = computerPieces.randomElement(), let to = availableSpots.randomElement() {
        return (from: from, to: to)
      }
      
      return nil
    } else {
      // Placing a new piece (original logic)
      let to: Int?
      if let winMove = findWinningMove(for: .computer) {
        to = winMove
      } else if let blockMove = findWinningMove(for: .human) {
        to = blockMove
      } else if board[4] == .none {
        to = 4 // Take center
      } else {
        let availableSpots = board.enumerated().filter { $0.element == .none }.map { $0.offset }
        to = availableSpots.randomElement()
      }
      
      if let targetSpot = to {
        return (from: -1, to: targetSpot)
      }
      return nil
    }
  }
  
  private func findWinningMoveByMoving(for player: Player) -> Int? {
    // Find if there's a winning position available
    for pattern in winPatterns {
      let values = pattern.map { board[$0] }
      let playerCount = values.filter { $0 == player }.count
      let emptyCount = values.filter { $0 == .none }.count
      
      if playerCount == 2 && emptyCount == 1 {
        return pattern.first { board[$0] == .none }
      }
    }
    return nil
  }
  
  private func findWinningMove(for player: Player) -> Int? {
    for pattern in winPatterns {
      let values = pattern.map { board[$0] }
      let playerCount = values.filter { $0 == player }.count
      let emptyCount = values.filter { $0 == .none }.count
      
      if playerCount == 2 && emptyCount == 1 {
        return pattern.first { board[$0] == .none }
      }
    }
    return nil
  }
  
  private func checkWin(for player: Player) -> Bool {
    for pattern in winPatterns {
      if pattern.allSatisfy({ board[$0] == player }) {
        return true
      }
    }
    return false
  }
  
  private func isBoardFull() -> Bool {
    return !board.contains(.none)
  }
  
  func reset() {
    board = Array(repeating: .none, count: 9)
    gameState = .playing
    isComputerThinking = false
    selectedPieceIndex = nil
  }
}

// MARK: - Tic-Tac-Toe View

struct TicTacToeView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Environment(\.challengeCancelAction) private var challengeCancelAction
  @ObservedObject var challenge: TicTacToeChallenge
  @StateObject private var game = TicTacToeGame()
  let onComplete: () -> Void
  let appSettings: AppSettings
  
  @State private var elapsedTime: TimeInterval = 0
  @State private var hasRecordedStart = false
  @State private var outcome: ChallengeOutcome = .pending
  
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  // Fixed cell size for the game board
  private let cellSize: CGFloat = 90
  private let cellSpacing: CGFloat = 10
  
  var skipDelayRemaining: Int {
    guard !challenge.isTestMode else { return 0 }
    let remaining = Int(ceil(max(0, TimeInterval(appSettings.challengeCancelDelaySeconds) - elapsedTime)))
    return max(0, remaining)
  }
  
  var canSkip: Bool {
    skipDelayRemaining == 0
  }
  
  var skipButtonTitle: String {
    if canSkip {
      return NSLocalizedString("challenge.skip.button_ready", comment: "")
    } else {
      return String(format: NSLocalizedString("challenge.skip.button_countdown", comment: ""), skipDelayRemaining)
    }
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        // Controls - Skip on left, X on right
        HStack(spacing: 10) {
          if !challenge.isTestMode {
            Button(action: {
              skipChallenge()
            }) {
              HStack(spacing: 6) {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 20, weight: .semibold))
                Text(skipButtonTitle)
                  .font(.footnote.weight(.semibold))
              }
              .foregroundColor(canSkip ? colors.textSecondary : colors.textDisabled)
              .padding(.horizontal, 12)
              .padding(.vertical, 8)
              .background(
                Capsule()
                  .fill(colors.surface.opacity(0.8))
                  .overlay(
                    Capsule()
                      .stroke(colors.divider, lineWidth: 1)
                  )
              )
            }
            .disabled(!canSkip)
          }
          
          Spacer()
          
          Button {
            cancelChallenge()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(colors.textSecondary)
              .padding(10)
              .background(colors.surface.opacity(0.7), in: Circle())
          }
          .accessibilityLabel(Text(NSLocalizedString("challenge.cancel", comment: "")))
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        
        // Header
        VStack(spacing: 8) {
          Image(systemName: "square.grid.3x3.fill")
            .font(.system(size: 60))
            .foregroundStyle(colors.ticTacToe.gradient)
          
          Text("Tic-Tac-Toe")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(colors.textPrimary)
          
          Text("Win 1 game to continue")
            .font(.system(size: 14))
            .foregroundColor(colors.textSecondary)
        }
        .padding(.top, 16)
        
        // Game Status
        VStack(spacing: 6) {
          Text(game.gameState.message)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(game.gameState == .humanWon ? colors.success : 
                           game.gameState == .computerWon ? colors.error : colors.textPrimary)
          
          if game.gameState == .playing {
            let humanPieces = game.board.filter { $0 == .human }.count
            if humanPieces >= game.maxPieces {
              if game.selectedPieceIndex != nil {
                Text("Now tap an empty space to move")
                  .font(.system(size: 14))
                  .foregroundColor(colors.ticTacToe)
              } else {
                Text("Select one of your pieces to move")
                  .font(.system(size: 14))
                  .foregroundColor(colors.warning)
              }
            } else {
              Text("Place your piece (\(humanPieces)/\(game.maxPieces))")
                .font(.system(size: 14))
                .foregroundColor(colors.textSecondary)
            }
          }
          
          // Reserve space for computer thinking message to prevent layout jump
          Text(game.isComputerThinking ? "Computer is thinking..." : " ")
            .font(.system(size: 14))
            .foregroundColor(colors.textSecondary)
            .opacity(game.isComputerThinking ? 1 : 0)
            .frame(height: 16)
        }
        
        // Game Board - fixed size
        VStack(spacing: cellSpacing) {
          ForEach(0..<3, id: \.self) { row in
            HStack(spacing: cellSpacing) {
              ForEach(0..<3, id: \.self) { col in
                let index = row * 3 + col
                CellView(
                  player: game.board[index],
                  isSelected: game.selectedPieceIndex == index,
                  size: cellSize
                )
                .onTapGesture {
                  game.makeMove(at: index)
                }
              }
            }
          }
        }
        .padding(.vertical, 20)
        
        // Reset Button
        if game.gameState != .playing {
          Button(action: {
            if game.gameState == .humanWon {
              challenge.gamesWon += 1
              if challenge.gamesWon >= challenge.requiredWins {
                challenge.isCompleted = true
                outcome = .continued
                ChallengeStatsManager.shared.recordChallengeCompleted(type: .ticTacToe, isTestMode: challenge.isTestMode)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  onComplete()
                }
                return
              }
            }
            game.reset()
          }) {
            Text(game.gameState == .humanWon && challenge.gamesWon >= challenge.requiredWins - 1 ? 
                 "Complete!" : "Play Again")
              .font(.headline)
              .foregroundColor(colors.textOnAccent)
              .frame(maxWidth: .infinity)
              .padding()
              .background(colors.ticTacToe)
              .cornerRadius(12)
          }
          .padding(.horizontal, 40)
        }
        
        Spacer()
          .frame(height: 40)
      }
    }
    .background(colors.background.ignoresSafeArea())
    .interactiveDismissDisabled(!canSkip)
    .presentationDetents([.large])
    .presentationDragIndicator(.hidden)
    .onReceive(timer) { _ in
      elapsedTime += 1
    }
    .onAppear {
      recordStartIfNeeded()
    }
    .onDisappear {
      if outcome == .pending {
        ChallengeStatsManager.shared.recordChallengeCancelled(type: .ticTacToe, isTestMode: challenge.isTestMode)
      }
    }
  }
}

private enum ChallengeOutcome {
  case pending
  case continued
  case cancelled
}

private extension TicTacToeView {
  func recordStartIfNeeded() {
    guard !hasRecordedStart else { return }
    hasRecordedStart = true
    ChallengeStatsManager.shared.recordChallengeTriggered(type: .ticTacToe, isTestMode: challenge.isTestMode)
  }
  
  func skipChallenge() {
    guard canSkip else { return }
    outcome = .continued
    ChallengeStatsManager.shared.recordChallengeContinued(type: .ticTacToe, isTestMode: challenge.isTestMode)
    if let cancelAction = challengeCancelAction {
      cancelAction()
    }
    dismiss()
  }
  
  func cancelChallenge() {
    outcome = .cancelled
    ChallengeStatsManager.shared.recordChallengeCancelled(type: .ticTacToe, isTestMode: challenge.isTestMode)
    dismiss()
  }
}

// MARK: - Cell View

struct CellView: View {
  @Environment(\.themeColors) private var colors
  let player: Player
  let isSelected: Bool
  let size: CGFloat
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(colors.surface)
        .frame(width: size, height: size)
      
      if isSelected {
        RoundedRectangle(cornerRadius: 12)
          .stroke(colors.cautionYellow, lineWidth: 3)
          .frame(width: size, height: size)
      }
      
      Text(player.symbol)
        .font(.system(size: size * 0.48, weight: .bold))
        .foregroundColor(player == .human ? colors.ticTacToe : colors.error)
    }
  }
}

// MARK: - Preview

#Preview {
  TicTacToeView(challenge: TicTacToeChallenge(), onComplete: {}, appSettings: AppSettings())
}

