import SwiftUI

// MARK: - Micro 2048 Challenge
// Challenge: Reach 128 in a 4x4 grid to unlock app access
// Estimated completion time: 40-90 seconds

class Micro2048Challenge: Challenge, ObservableObject {
  let type = ChallengeType.micro2048
  @Published var isCompleted = false
  var isTestMode = false
  
  @MainActor
  func view(onComplete: @escaping () -> Void) -> AnyView {
    AnyView(Micro2048View(challenge: self, onComplete: onComplete))
  }
}

// MARK: - Game Direction

enum SwipeDirection {
  case up, down, left, right
}

// MARK: - Tile Model

struct Tile: Identifiable, Equatable {
  let id = UUID()
  var value: Int
  var position: Position
  var isNew: Bool = false
  var isMerged: Bool = false
  
  struct Position: Equatable {
    var row: Int
    var col: Int
  }
}

// MARK: - Game Logic

@MainActor
class Micro2048Game: ObservableObject {
  @Published var tiles: [Tile] = []
  @Published var score: Int = 0
  @Published var hasWon: Bool = false
  @Published var isGameOver: Bool = false
  @Published var highestTile: Int = 0
  
  let gridSize = 4
  let winningTile = 128
  
  init() {
    startNewGame()
  }
  
  func startNewGame() {
    tiles = []
    score = 0
    hasWon = false
    isGameOver = false
    highestTile = 0
    
    // Add two initial tiles
    addRandomTile()
    addRandomTile()
  }
  
  private func addRandomTile() {
    let emptyPositions = getEmptyPositions()
    guard !emptyPositions.isEmpty else { return }
    
    let position = emptyPositions.randomElement()!
    let value = Double.random(in: 0...1) < 0.9 ? 2 : 4 // 90% chance for 2, 10% for 4
    let tile = Tile(value: value, position: position, isNew: true)
    tiles.append(tile)
  }
  
  private func getEmptyPositions() -> [Tile.Position] {
    var positions: [Tile.Position] = []
    for row in 0..<gridSize {
      for col in 0..<gridSize {
        let position = Tile.Position(row: row, col: col)
        if !tiles.contains(where: { $0.position == position }) {
          positions.append(position)
        }
      }
    }
    return positions
  }
  
  func move(direction: SwipeDirection) {
    guard !isGameOver && !hasWon else { return }
    
    // Clear merge flags
    for index in tiles.indices {
      tiles[index].isMerged = false
      tiles[index].isNew = false
    }
    
    let moved = performMove(direction: direction)
    
    if moved {
      addRandomTile()
      updateHighestTile()
      
      if highestTile >= winningTile {
        hasWon = true
      }
      
      if !canMove() {
        isGameOver = true
      }
    }
  }
  
  private func performMove(direction: SwipeDirection) -> Bool {
    var moved = false
    var mergedInMove: Set<UUID> = []
    
    let orderedIndices = getOrderedIndices(for: direction)
    
    for (row, col) in orderedIndices {
      guard let tileIndex = tiles.firstIndex(where: { $0.position.row == row && $0.position.col == col }) else {
        continue
      }
      
      let currentTile = tiles[tileIndex]
      var newPosition = currentTile.position
      
      // Try to move as far as possible in the direction
      while true {
        let nextPosition = getNextPosition(from: newPosition, direction: direction)
        
        // Check if next position is valid
        guard isValidPosition(nextPosition) else { break }
        
        // Check if next position is empty
        if let targetIndex = tiles.firstIndex(where: { $0.position == nextPosition }) {
          let targetTile = tiles[targetIndex]
          
          // Check if we can merge
          if targetTile.value == currentTile.value && 
             !mergedInMove.contains(targetTile.id) &&
             !mergedInMove.contains(currentTile.id) {
            // Merge tiles
            tiles[targetIndex].value *= 2
            tiles[targetIndex].isMerged = true
            score += tiles[targetIndex].value
            mergedInMove.insert(tiles[targetIndex].id)
            tiles.remove(at: tileIndex)
            moved = true
          }
          break
        } else {
          newPosition = nextPosition
        }
      }
      
      // Update position if it changed
      if newPosition != currentTile.position {
        if let index = tiles.firstIndex(where: { $0.id == currentTile.id }) {
          tiles[index].position = newPosition
          moved = true
        }
      }
    }
    
    return moved
  }
  
  private func getOrderedIndices(for direction: SwipeDirection) -> [(Int, Int)] {
    var indices: [(Int, Int)] = []
    
    switch direction {
    case .up:
      for row in 0..<gridSize {
        for col in 0..<gridSize {
          indices.append((row, col))
        }
      }
    case .down:
      for row in (0..<gridSize).reversed() {
        for col in 0..<gridSize {
          indices.append((row, col))
        }
      }
    case .left:
      for col in 0..<gridSize {
        for row in 0..<gridSize {
          indices.append((row, col))
        }
      }
    case .right:
      for col in (0..<gridSize).reversed() {
        for row in 0..<gridSize {
          indices.append((row, col))
        }
      }
    }
    
    return indices
  }
  
  private func getNextPosition(from position: Tile.Position, direction: SwipeDirection) -> Tile.Position {
    switch direction {
    case .up:
      return Tile.Position(row: position.row - 1, col: position.col)
    case .down:
      return Tile.Position(row: position.row + 1, col: position.col)
    case .left:
      return Tile.Position(row: position.row, col: position.col - 1)
    case .right:
      return Tile.Position(row: position.row, col: position.col + 1)
    }
  }
  
  private func isValidPosition(_ position: Tile.Position) -> Bool {
    return position.row >= 0 && position.row < gridSize &&
           position.col >= 0 && position.col < gridSize
  }
  
  private func canMove() -> Bool {
    // Check if there are any empty positions
    if !getEmptyPositions().isEmpty {
      return true
    }
    
    // Check if any adjacent tiles can merge
    for row in 0..<gridSize {
      for col in 0..<gridSize {
        let position = Tile.Position(row: row, col: col)
        guard let tile = tiles.first(where: { $0.position == position }) else { continue }
        
        // Check adjacent tiles
        let adjacentPositions = [
          Tile.Position(row: row - 1, col: col),
          Tile.Position(row: row + 1, col: col),
          Tile.Position(row: row, col: col - 1),
          Tile.Position(row: row, col: col + 1)
        ]
        
        for adjPos in adjacentPositions {
          if let adjTile = tiles.first(where: { $0.position == adjPos }),
             adjTile.value == tile.value {
            return true
          }
        }
      }
    }
    
    return false
  }
  
  private func updateHighestTile() {
    highestTile = tiles.map { $0.value }.max() ?? 0
  }
}

// MARK: - 2048 View

struct Micro2048View: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var appSettings: AppSettings
  @ObservedObject var challenge: Micro2048Challenge
  @StateObject private var game = Micro2048Game()
  let onComplete: () -> Void
  
  @State private var dragOffset: CGSize = .zero
  @State private var elapsedTime: TimeInterval = 0
  @State private var timer: Timer?
  
  var showCancelButton: Bool {
    // Always show in test mode, or after the configured delay in challenge mode
    challenge.isTestMode || elapsedTime >= TimeInterval(appSettings.challengeCancelDelaySeconds)
  }
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      VStack(spacing: 16) {
        // Cancel button
        HStack {
          Spacer()
          if showCancelButton {
            Button(action: {
              dismiss()
            }) {
              Image(systemName: "xmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(colors.textSecondary)
            }
            .padding(.trailing, 20)
            .padding(.top, 20)
            .transition(.opacity)
          }
        }
        .frame(height: showCancelButton ? nil : 0)
        .opacity(showCancelButton ? 1 : 0)
        // Header
        VStack(spacing: 12) {
          Image(systemName: "square.grid.4x4.fill")
            .font(.system(size: 60))
            .foregroundStyle(colors.micro2048.gradient)
          
          Text("Micro 2048")
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(colors.textPrimary)
          
          Text("Reach 128 to continue")
            .font(.subheadline)
            .foregroundColor(colors.textSecondary)
        }
        .padding(.top, 20)
        
        // Score
        HStack(spacing: 20) {
          VStack(spacing: 4) {
            Text("SCORE")
              .font(.caption.bold())
              .foregroundColor(colors.textSecondary)
            Text("\(game.score)")
              .font(.title2.bold())
              .foregroundColor(colors.textPrimary)
          }
          .frame(width: 100)
          .padding(.vertical, 12)
          .background(colors.surface)
          .cornerRadius(8)
          
          VStack(spacing: 4) {
            Text("HIGHEST")
              .font(.caption.bold())
              .foregroundColor(colors.textSecondary)
            Text("\(game.highestTile)")
              .font(.title2.bold())
              .foregroundColor(colors.micro2048)
          }
          .frame(width: 100)
          .padding(.vertical, 12)
          .background(colors.surface)
          .cornerRadius(8)
        }
        
        // Game Status
        if game.hasWon {
          Text("You won! 🎉")
            .font(.title2.bold())
            .foregroundColor(colors.success)
            .padding(.vertical, 4)
        } else if game.isGameOver {
          Text("Game Over!")
            .font(.title2.bold())
            .foregroundColor(colors.error)
            .padding(.vertical, 4)
        } else {
          Text("Swipe to move tiles")
            .font(.subheadline)
            .foregroundColor(colors.textSecondary)
            .padding(.vertical, 4)
        }
        
        // Game Board
        GameBoardView(game: game)
          .gesture(
            DragGesture(minimumDistance: 20)
              .onChanged { value in
                dragOffset = value.translation
              }
              .onEnded { value in
                let direction = getSwipeDirection(from: value.translation)
                if let direction = direction {
                  withAnimation(.easeInOut(duration: 0.2)) {
                    game.move(direction: direction)
                  }
                }
                dragOffset = .zero
              }
          )
          .padding(.bottom, 8)
        
        // Action Buttons
        VStack(spacing: 12) {
          if game.hasWon {
            Button(action: {
              challenge.isCompleted = true
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
              }
            }) {
              Text("Complete!")
                .font(.headline)
                .foregroundColor(colors.textOnAccent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.success)
                .cornerRadius(12)
            }
          }
          
          if game.isGameOver || game.hasWon {
            Button(action: {
              withAnimation {
                game.startNewGame()
              }
            }) {
              Text("New Game")
                .font(.headline)
                .foregroundColor(colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.surface)
                .cornerRadius(12)
            }
          }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
      }
    }
    .interactiveDismissDisabled(!showCancelButton)
    .onAppear {
      startTimer()
    }
    .onDisappear {
      stopTimer()
    }
  }
  
  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Task { @MainActor [weak timer] in
        guard timer != nil else { return }
        elapsedTime += 1
      }
    }
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func getSwipeDirection(from translation: CGSize) -> SwipeDirection? {
    let threshold: CGFloat = 20
    
    if abs(translation.width) > abs(translation.height) {
      // Horizontal swipe
      if abs(translation.width) > threshold {
        return translation.width > 0 ? .right : .left
      }
    } else {
      // Vertical swipe
      if abs(translation.height) > threshold {
        return translation.height > 0 ? .down : .up
      }
    }
    
    return nil
  }
}

// MARK: - Game Board View

struct GameBoardView: View {
  @Environment(\.themeColors) private var colors
  @ObservedObject var game: Micro2048Game
  
  var body: some View {
    GeometryReader { geometry in
      let spacing: CGFloat = 8
      let totalSpacing = spacing * CGFloat(game.gridSize + 1)
      let availableSize = min(geometry.size.width, geometry.size.height) - totalSpacing
      let tileSize = availableSize / CGFloat(game.gridSize)
      
      ZStack {
        // Background grid
        VStack(spacing: spacing) {
          ForEach(0..<game.gridSize, id: \.self) { row in
            HStack(spacing: spacing) {
              ForEach(0..<game.gridSize, id: \.self) { col in
                RoundedRectangle(cornerRadius: 8)
                  .fill(colors.surface.opacity(0.5))
                  .frame(width: tileSize, height: tileSize)
              }
            }
          }
        }
        .padding(spacing)
        
        // Tiles
        ForEach(game.tiles) { tile in
          TileView(tile: tile, size: tileSize)
            .position(
              x: spacing + CGFloat(tile.position.col) * (tileSize + spacing) + tileSize / 2,
              y: spacing + CGFloat(tile.position.row) * (tileSize + spacing) + tileSize / 2
            )
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: tile.position)
            .scaleEffect(tile.isNew ? 1.0 : (tile.isMerged ? 1.1 : 1.0))
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: tile.isNew)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: tile.isMerged)
        }
      }
      .background(colors.surface.opacity(0.3))
      .cornerRadius(12)
    }
    .aspectRatio(1, contentMode: .fit)
    .padding(.horizontal, 20)
  }
}

// MARK: - Tile View

struct TileView: View {
  @Environment(\.themeColors) private var colors
  let tile: Tile
  let size: CGFloat
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(tileColor(for: tile.value))
      
      Text("\(tile.value)")
        .font(.system(size: fontSize(for: tile.value), weight: .bold, design: .rounded))
        .foregroundColor(textColor(for: tile.value))
    }
    .frame(width: size, height: size)
  }
  
  private func textColor(for value: Int) -> Color {
    // Use dark color for light tiles (2, 4), white for darker tiles
    switch value {
    case 2, 4:
      return Color(red: 30/255, green: 25/255, blue: 22/255) // Dark brown
    default:
      return .white
    }
  }
  
  private func tileColor(for value: Int) -> Color {
    switch value {
    case 2: return Color(red: 0.93, green: 0.89, blue: 0.85)
    case 4: return Color(red: 0.93, green: 0.88, blue: 0.78)
    case 8: return Color(red: 0.95, green: 0.69, blue: 0.47)
    case 16: return Color(red: 0.96, green: 0.58, blue: 0.39)
    case 32: return Color(red: 0.97, green: 0.49, blue: 0.37)
    case 64: return Color(red: 0.97, green: 0.37, blue: 0.23)
    case 128: return Color(red: 0.93, green: 0.81, blue: 0.45)
    default: return colors.micro2048
    }
  }
  
  private func fontSize(for value: Int) -> CGFloat {
    let baseSize = size * 0.4
    if value >= 100 {
      return baseSize * 0.8
    } else if value >= 1000 {
      return baseSize * 0.6
    }
    return baseSize
  }
}

// MARK: - Preview

#Preview {
  Micro2048View(challenge: Micro2048Challenge(), onComplete: {})
}

