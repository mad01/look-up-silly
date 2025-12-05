import SwiftUI

// MARK: - Tic-Tac-Toe Challenge
// Challenge: Win 1 game of tic-tac-toe against the computer to unlock app access

class TicTacToeChallenge: Challenge, ObservableObject {
  let type = ChallengeType.ticTacToe
  @Published var isCompleted = false
  @Published var gamesWon = 0
  let requiredWins = 1
  
  @MainActor
  func view(onComplete: @escaping () -> Void) -> AnyView {
    AnyView(TicTacToeView(challenge: self, onComplete: onComplete))
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
  
  let winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6]             // Diagonals
  ]
  
  func makeMove(at index: Int) {
    guard gameState == .playing, board[index] == .none else { return }
    
    board[index] = .human
    
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
    // Simple AI: Try to win, then block, then take center, then random
    if let winMove = findWinningMove(for: .computer) {
      board[winMove] = .computer
    } else if let blockMove = findWinningMove(for: .human) {
      board[blockMove] = .computer
    } else if board[4] == .none {
      board[4] = .computer // Take center
    } else {
      // Take random available spot
      let availableSpots = board.enumerated().filter { $0.element == .none }.map { $0.offset }
      if let randomSpot = availableSpots.randomElement() {
        board[randomSpot] = .computer
      }
    }
    
    if checkWin(for: .computer) {
      gameState = .computerWon
    } else if isBoardFull() {
      gameState = .draw
    }
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
  }
}

// MARK: - Tic-Tac-Toe View

struct TicTacToeView: View {
  @ObservedObject var challenge: TicTacToeChallenge
  @StateObject private var game = TicTacToeGame()
  let onComplete: () -> Void
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      VStack(spacing: 40) {
        // Header
        VStack(spacing: 12) {
          Image(systemName: "square.grid.3x3.fill")
            .font(.system(size: 60))
            .foregroundStyle(.blue.gradient)
          
          Text("Tic-Tac-Toe")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.white)
          
          Text("Win 1 game to continue")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding(.top, 60)
        
        // Game Status
        VStack(spacing: 8) {
          Text(game.gameState.message)
            .font(.title2.bold())
            .foregroundColor(game.gameState == .humanWon ? .green : 
                           game.gameState == .computerWon ? .red : .white)
          
          if game.isComputerThinking {
            Text("Computer is thinking...")
              .font(.subheadline)
              .foregroundColor(.gray)
          }
        }
        
        // Game Board
        VStack(spacing: 12) {
          ForEach(0..<3) { row in
            HStack(spacing: 12) {
              ForEach(0..<3) { col in
                let index = row * 3 + col
                CellView(player: game.board[index])
                  .onTapGesture {
                    game.makeMove(at: index)
                  }
              }
            }
          }
        }
        .padding(.horizontal, 40)
        
        Spacer()
        
        // Reset Button
        if game.gameState != .playing {
          Button(action: {
            if game.gameState == .humanWon {
              challenge.gamesWon += 1
              if challenge.gamesWon >= challenge.requiredWins {
                challenge.isCompleted = true
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
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(12)
          }
          .padding(.horizontal, 40)
          .padding(.bottom, 40)
        }
      }
    }
  }
}

// MARK: - Cell View

struct CellView: View {
  let player: Player
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white.opacity(0.1))
        .frame(width: 100, height: 100)
      
      Text(player.symbol)
        .font(.system(size: 48, weight: .bold))
        .foregroundColor(player == .human ? .blue : .red)
    }
  }
}

// MARK: - Preview

#Preview {
  TicTacToeView(challenge: TicTacToeChallenge(), onComplete: {})
}

