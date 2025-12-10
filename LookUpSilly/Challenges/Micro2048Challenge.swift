import SwiftUI

// MARK: - Micro 2048 Challenge
// Challenge: Reach 64 in a 3x3 grid to unlock app access
// Player can continue playing after reaching 64 and finish when they want

class Micro2048Challenge: Challenge, ObservableObject {
  let type = ChallengeType.micro2048
  @Published var isCompleted = false
  var isTestMode = false
  
  @MainActor
  func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView {
    AnyView(Micro2048View(challenge: self, onComplete: onComplete, appSettings: appSettings))
  }
}

// MARK: - Direction

enum SwipeDirection {
  case up, down, left, right
}

// MARK: - Tile Model

struct GameTile: Identifiable, Equatable {
  let id: UUID
  var value: Int
  var position: (row: Int, col: Int)
  var isNew: Bool = true
  var isMerged: Bool = false
  
  static func == (lhs: GameTile, rhs: GameTile) -> Bool {
    lhs.id == rhs.id && lhs.value == rhs.value &&
    lhs.position.row == rhs.position.row && lhs.position.col == rhs.position.col
  }
}

// MARK: - Game Logic

@MainActor
class Micro2048Game: ObservableObject {
  @Published private(set) var tiles: [GameTile] = []
  @Published private(set) var score: Int = 0
  @Published private(set) var highestTile: Int = 0
  @Published private(set) var hasReachedTarget: Bool = false
  @Published private(set) var isGameOver: Bool = false
  @Published var canContinue: Bool = false
  
  let gridSize = 4
  let targetValue = 64
  
  private var grid: [[GameTile?]]
  
  init() {
    grid = Array(repeating: Array(repeating: nil, count: 4), count: 4)
    reset()
  }
  
  func reset() {
    tiles = []
    grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)
    score = 0
    highestTile = 0
    hasReachedTarget = false
    isGameOver = false
    canContinue = false
    
    addRandomTile(isInitial: true)
    addRandomTile(isInitial: true)
  }
  
  private func addRandomTile(isInitial: Bool = false) {
    var emptyPositions: [(Int, Int)] = []
    
    for row in 0..<gridSize {
      for col in 0..<gridSize {
        if grid[row][col] == nil {
          emptyPositions.append((row, col))
        }
      }
    }
    
    guard let position = emptyPositions.randomElement() else { return }
    
    // 90% chance for 2, 10% chance for 4
    let value = Int.random(in: 1...10) == 1 ? 4 : 2
    let newTile = GameTile(id: UUID(), value: value, position: position, isNew: !isInitial)
    
    grid[position.0][position.1] = newTile
    tiles.append(newTile)
    
    updateHighestTile()
  }
  
  private func updateHighestTile() {
    highestTile = tiles.map { $0.value }.max() ?? 0
    
    if highestTile >= targetValue && !hasReachedTarget {
      hasReachedTarget = true
    }
  }
  
  func move(_ direction: SwipeDirection) {
    guard !isGameOver else { return }
    
    var moved = false
    
    // Reset merge status
    for i in 0..<tiles.count {
      tiles[i].isMerged = false
      tiles[i].isNew = false
    }
    
    switch direction {
    case .up:
      moved = moveUp()
    case .down:
      moved = moveDown()
    case .left:
      moved = moveLeft()
    case .right:
      moved = moveRight()
    }
    
    if moved {
      syncTilesFromGrid()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
        self?.addRandomTile()
        self?.checkGameOver()
      }
    }
  }
  
  private func moveLeft() -> Bool {
    var moved = false
    
    for row in 0..<gridSize {
      var newRow: [GameTile?] = []
      var lastMerged = false
      
      for col in 0..<gridSize {
        if let tile = grid[row][col] {
          if let lastTile = newRow.last, let last = lastTile, last.value == tile.value && !lastMerged {
            // Merge: create new tile with new UUID
            let mergedTile = GameTile(
              id: UUID(),
              value: last.value * 2,
              position: (row, newRow.count - 1),
              isNew: false,
              isMerged: true
            )
            newRow[newRow.count - 1] = mergedTile
            score += mergedTile.value
            lastMerged = true
            moved = true
          } else {
            var movedTile = tile
            movedTile.position = (row, newRow.count)
            movedTile.isMerged = false
            newRow.append(movedTile)
            lastMerged = false
          }
        }
      }
      
      while newRow.count < gridSize {
        newRow.append(nil)
      }
      
      for col in 0..<gridSize {
        if grid[row][col]?.value != newRow[col]?.value ||
           (grid[row][col] != nil && newRow[col] != nil && grid[row][col]!.position.col != col) {
          moved = true
        }
        grid[row][col] = newRow[col]
        grid[row][col]?.position = (row, col)
      }
    }
    
    return moved
  }
  
  private func moveRight() -> Bool {
    var moved = false
    
    for row in 0..<gridSize {
      var newRow: [GameTile?] = []
      var lastMerged = false
      
      for col in stride(from: gridSize - 1, through: 0, by: -1) {
        if let tile = grid[row][col] {
          if let lastTile = newRow.last, let last = lastTile, last.value == tile.value && !lastMerged {
            let mergedTile = GameTile(
              id: UUID(),
              value: last.value * 2,
              position: (row, gridSize - newRow.count),
              isNew: false,
              isMerged: true
            )
            newRow[newRow.count - 1] = mergedTile
            score += mergedTile.value
            lastMerged = true
            moved = true
          } else {
            var movedTile = tile
            movedTile.position = (row, gridSize - 1 - newRow.count)
            movedTile.isMerged = false
            newRow.append(movedTile)
            lastMerged = false
          }
        }
      }
      
      while newRow.count < gridSize {
        newRow.append(nil)
      }
      
      newRow.reverse()
      
      for col in 0..<gridSize {
        if grid[row][col]?.value != newRow[col]?.value {
          moved = true
        }
        grid[row][col] = newRow[col]
        grid[row][col]?.position = (row, col)
      }
    }
    
    return moved
  }
  
  private func moveUp() -> Bool {
    var moved = false
    
    for col in 0..<gridSize {
      var newCol: [GameTile?] = []
      var lastMerged = false
      
      for row in 0..<gridSize {
        if let tile = grid[row][col] {
          if let lastTile = newCol.last, let last = lastTile, last.value == tile.value && !lastMerged {
            let mergedTile = GameTile(
              id: UUID(),
              value: last.value * 2,
              position: (newCol.count - 1, col),
              isNew: false,
              isMerged: true
            )
            newCol[newCol.count - 1] = mergedTile
            score += mergedTile.value
            lastMerged = true
            moved = true
          } else {
            var movedTile = tile
            movedTile.position = (newCol.count, col)
            movedTile.isMerged = false
            newCol.append(movedTile)
            lastMerged = false
          }
        }
      }
      
      while newCol.count < gridSize {
        newCol.append(nil)
      }
      
      for row in 0..<gridSize {
        if grid[row][col]?.value != newCol[row]?.value {
          moved = true
        }
        grid[row][col] = newCol[row]
        grid[row][col]?.position = (row, col)
      }
    }
    
    return moved
  }
  
  private func moveDown() -> Bool {
    var moved = false
    
    for col in 0..<gridSize {
      var newCol: [GameTile?] = []
      var lastMerged = false
      
      for row in stride(from: gridSize - 1, through: 0, by: -1) {
        if let tile = grid[row][col] {
          if let lastTile = newCol.last, let last = lastTile, last.value == tile.value && !lastMerged {
            let mergedTile = GameTile(
              id: UUID(),
              value: last.value * 2,
              position: (gridSize - newCol.count, col),
              isNew: false,
              isMerged: true
            )
            newCol[newCol.count - 1] = mergedTile
            score += mergedTile.value
            lastMerged = true
            moved = true
          } else {
            var movedTile = tile
            movedTile.position = (gridSize - 1 - newCol.count, col)
            movedTile.isMerged = false
            newCol.append(movedTile)
            lastMerged = false
          }
        }
      }
      
      while newCol.count < gridSize {
        newCol.append(nil)
      }
      
      newCol.reverse()
      
      for row in 0..<gridSize {
        if grid[row][col]?.value != newCol[row]?.value {
          moved = true
        }
        grid[row][col] = newCol[row]
        grid[row][col]?.position = (row, col)
      }
    }
    
    return moved
  }
  
  private func syncTilesFromGrid() {
    tiles = []
    for row in 0..<gridSize {
      for col in 0..<gridSize {
        if let tile = grid[row][col] {
          var updatedTile = tile
          updatedTile.position = (row, col)
          tiles.append(updatedTile)
        }
      }
    }
    updateHighestTile()
  }
  
  private func checkGameOver() {
    // Check if any moves are possible
    for row in 0..<gridSize {
      for col in 0..<gridSize {
        // Empty cell exists
        if grid[row][col] == nil {
          return
        }
        
        let current = grid[row][col]!.value
        
        // Check right neighbor
        if col < gridSize - 1, let right = grid[row][col + 1], right.value == current {
          return
        }
        
        // Check bottom neighbor
        if row < gridSize - 1, let bottom = grid[row + 1][col], bottom.value == current {
          return
        }
      }
    }
    
    isGameOver = true
  }
}

// MARK: - Micro 2048 View

struct Micro2048View: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Environment(\.challengeCancelAction) private var challengeCancelAction
  @ObservedObject var challenge: Micro2048Challenge
  @StateObject private var game = Micro2048Game()
  let onComplete: () -> Void
  let appSettings: AppSettings
  
  @State private var elapsedTime: TimeInterval = 0
  @State private var hasRecordedStart = false
  @State private var outcome: ChallengeOutcome = .pending
  
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
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
      VStack(spacing: 12) {
        // Controls
        HStack(spacing: 10) {
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
          .padding(.trailing, 20)
          .padding(.top, 20)
          .disabled(!canSkip)
        }
        .frame(height: 40)
        
        // Header
        VStack(spacing: 6) {
          Image(systemName: "square.grid.4x3.fill")
            .font(.system(size: 50))
            .foregroundStyle(colors.micro2048.gradient)
          
          Text("Micro 2048")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
          
          Text("Reach 64 to continue")
            .font(.system(size: 14))
            .foregroundColor(colors.textSecondary)
        }
        .padding(.top, 8)
        
        // Score display
        HStack(spacing: 20) {
          ScoreBox(title: "SCORE", value: game.score)
          ScoreBox(title: "HIGHEST", value: game.highestTile)
        }
        .padding(.horizontal, 40)
        
        // Status message
        statusMessage
          .padding(.vertical, 8)
        
        // Game Board - fixed size, no GeometryReader
        GameBoardSimple(game: game)
          .padding(.horizontal, 20)
          .gesture(
            DragGesture(minimumDistance: 20)
              .onEnded { value in
                handleSwipe(value)
              }
          )
        
        // Action Buttons
        actionButtons
          .padding(.top, 20)
      }
      .padding(.bottom, 40)
    }
    .scrollDisabled(true)
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
        ChallengeStatsManager.shared.recordChallengeCancelled(type: .micro2048, isTestMode: challenge.isTestMode)
      }
    }
  }
  
  @ViewBuilder
  private var statusMessage: some View {
    if game.isGameOver {
      Text("Game Over!")
        .font(.system(size: 20, weight: .bold))
        .foregroundColor(colors.error)
    } else if game.hasReachedTarget {
      VStack(spacing: 4) {
        Text("🎉 You reached \(game.targetValue)!")
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(colors.success)
        Text("Keep playing or finish now")
          .font(.system(size: 14))
          .foregroundColor(colors.textSecondary)
      }
    } else {
      Text("Swipe to move tiles")
        .font(.system(size: 16))
        .foregroundColor(colors.textSecondary)
    }
  }
  
  @ViewBuilder
  private var actionButtons: some View {
    VStack(spacing: 12) {
      // Finish button - only shows when target reached
      if game.hasReachedTarget && !game.isGameOver {
        Button(action: {
          challenge.isCompleted = true
          outcome = .continued
          ChallengeStatsManager.shared.recordChallengeCompleted(type: .micro2048, isTestMode: challenge.isTestMode)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
          }
        }) {
          Text("Finish Challenge")
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.success)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
      }
      
      // Game Over - New Game button
      if game.isGameOver {
        Button(action: {
          game.reset()
        }) {
          Text("New Game")
            .font(.headline)
            .foregroundColor(colors.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding()
            .background(colors.micro2048)
            .cornerRadius(12)
        }
        .padding(.horizontal, 40)
      }
    }
  }
  
  private func handleSwipe(_ value: DragGesture.Value) {
    let horizontal = value.translation.width
    let vertical = value.translation.height
    
    if abs(horizontal) > abs(vertical) {
      if horizontal > 0 {
        game.move(.right)
      } else {
        game.move(.left)
      }
    } else {
      if vertical > 0 {
        game.move(.down)
      } else {
        game.move(.up)
      }
    }
  }
}

private enum ChallengeOutcome {
  case pending
  case continued
  case cancelled
}

private extension Micro2048View {
  func recordStartIfNeeded() {
    guard !hasRecordedStart else { return }
    hasRecordedStart = true
    ChallengeStatsManager.shared.recordChallengeTriggered(type: .micro2048, isTestMode: challenge.isTestMode)
  }
  
  func skipChallenge() {
    guard canSkip else { return }
    outcome = .continued
    ChallengeStatsManager.shared.recordChallengeContinued(type: .micro2048, isTestMode: challenge.isTestMode)
    if let cancelAction = challengeCancelAction {
      cancelAction()
    }
    dismiss()
  }
  
  func cancelChallenge() {
    outcome = .cancelled
    ChallengeStatsManager.shared.recordChallengeCancelled(type: .micro2048, isTestMode: challenge.isTestMode)
    dismiss()
  }
}

// MARK: - Score Box

struct ScoreBox: View {
  @Environment(\.themeColors) private var colors
  let title: String
  let value: Int
  
  var body: some View {
    VStack(spacing: 4) {
      Text(title)
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(colors.textSecondary)
      
      Text("\(value)")
        .font(.system(size: 24, weight: .bold, design: .rounded))
        .foregroundColor(colors.textPrimary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(colors.surface)
    .cornerRadius(8)
  }
}

// MARK: - Simple Game Board (No GeometryReader)

struct GameBoardSimple: View {
  @Environment(\.themeColors) private var colors
  @ObservedObject var game: Micro2048Game
  
  // Fixed dimensions that work well on most devices
  private let cellSize: CGFloat = 70
  private let spacing: CGFloat = 8
  
  private var boardSize: CGFloat {
    cellSize * 4 + spacing * 5
  }
  
  var body: some View {
    ZStack {
      // Background
      RoundedRectangle(cornerRadius: 12)
        .fill(colors.surfaceElevated)
      
      // Grid of empty cells
      VStack(spacing: spacing) {
        ForEach(0..<4, id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(0..<4, id: \.self) { col in
              RoundedRectangle(cornerRadius: 8)
                .fill(colors.surface.opacity(0.5))
                .frame(width: cellSize, height: cellSize)
            }
          }
        }
      }
      .padding(spacing)
      
      // Tiles overlay
      ForEach(game.tiles) { tile in
        TileView2048(
          value: tile.value,
          size: cellSize,
          isMerged: tile.isMerged,
          isNew: tile.isNew
        )
        .position(positionFor(tile))
      }
    }
    .frame(width: boardSize, height: boardSize)
  }
  
  private func positionFor(_ tile: GameTile) -> CGPoint {
    let x = spacing + CGFloat(tile.position.col) * (cellSize + spacing) + cellSize / 2
    let y = spacing + CGFloat(tile.position.row) * (cellSize + spacing) + cellSize / 2
    return CGPoint(x: x, y: y)
  }
}

// MARK: - Tile View

struct TileView2048: View {
  @Environment(\.themeColors) private var colors
  let value: Int
  let size: CGFloat
  let isMerged: Bool
  let isNew: Bool
  
  @State private var scale: CGFloat = 1.0
  
  private var safeSize: CGFloat {
    max(20, size)
  }
  
  private var backgroundColor: Color {
    switch value {
    case 2:
      return Color(red: 238/255, green: 228/255, blue: 218/255)
    case 4:
      return Color(red: 237/255, green: 224/255, blue: 200/255)
    case 8:
      return Color(red: 242/255, green: 177/255, blue: 121/255)
    case 16:
      return Color(red: 245/255, green: 149/255, blue: 99/255)
    case 32:
      return Color(red: 246/255, green: 124/255, blue: 95/255)
    case 64:
      return Color(red: 246/255, green: 94/255, blue: 59/255)
    case 128:
      return Color(red: 237/255, green: 207/255, blue: 114/255)
    case 256:
      return Color(red: 237/255, green: 204/255, blue: 97/255)
    case 512:
      return Color(red: 237/255, green: 200/255, blue: 80/255)
    case 1024:
      return Color(red: 237/255, green: 197/255, blue: 63/255)
    case 2048:
      return Color(red: 237/255, green: 194/255, blue: 46/255)
    default:
      return Color(red: 60/255, green: 58/255, blue: 50/255)
    }
  }
  
  private var textColor: Color {
    value <= 4 ? Color(red: 119/255, green: 110/255, blue: 101/255) : .white
  }
  
  private var fontSize: CGFloat {
    let base = safeSize
    if value >= 1000 {
      return base * 0.28
    } else if value >= 100 {
      return base * 0.35
    } else {
      return base * 0.42
    }
  }
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .fill(backgroundColor)
        .frame(width: safeSize, height: safeSize)
      
      Text("\(value)")
        .font(.system(size: max(10, fontSize), weight: .bold, design: .rounded))
        .foregroundColor(textColor)
    }
    .scaleEffect(scale)
    .onAppear {
      if isNew {
        scale = 0.1
        withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
          scale = 1.0
        }
      } else {
        scale = 1.0
      }
    }
    .onChange(of: value) { _, _ in
      // Always ensure scale returns to 1.0 when value changes
      withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
        scale = 1.0
      }
    }
  }
}

// MARK: - Preview

#Preview {
  Micro2048View(challenge: Micro2048Challenge(), onComplete: {}, appSettings: AppSettings())
}
