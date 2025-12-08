import SwiftUI

enum PathRecallPhase {
  case preview, input, failed, completed
}

// MARK: - Path Recall Challenge
// Challenge: Watch a glowing path, then tap the cells in order. Paths grow each round.
@MainActor
class PathRecallChallenge: Challenge, ObservableObject {
  let type = ChallengeType.pathRecall
  @Published var isCompleted = false
  @Published var phase: PathRecallPhase = .preview
  @Published var currentPath: [Int] = []
  @Published var highlightedIndex: Int?
  @Published var playerProgress: Int = 0
  @Published var round: Int = 1
  
  let gridSize = 4
  let totalRounds = 4
  var isTestMode = false
  
  private var previewTask: Task<Void, Never>?
  
  init() {
    startRound(resetProgress: true)
  }
  
  var currentPathLength: Int {
    min(2 + (round - 1), 5)
  }
  
  var nextIndex: Int? {
    guard phase == .input, playerProgress < currentPath.count else { return nil }
    return currentPath[playerProgress]
  }
  
  @MainActor
  func startRound(resetProgress: Bool) {
    if resetProgress {
      round = 1
      isCompleted = false
    }
    playerProgress = 0
    phase = .preview
    generatePath()
    runPreview()
  }
  
  func generatePath() {
    let cellCount = gridSize * gridSize
    currentPath = (0..<currentPathLength).map { _ in Int.random(in: 0..<cellCount) }
  }
  
  @MainActor
  func runPreview() {
    previewTask?.cancel()
    phase = .preview
    
    previewTask = Task { @MainActor in
      await playPreview()
    }
  }
  
  @MainActor
  private func playPreview() async {
    for index in currentPath {
      try? Task.checkCancellation()
      highlightedIndex = index
      try? await Task.sleep(nanoseconds: 450_000_000)
      highlightedIndex = nil
      try? await Task.sleep(nanoseconds: 160_000_000)
    }
    phase = .input
  }
  
  func handleTap(_ index: Int) {
    guard phase == .input else { return }
    
    if currentPath[playerProgress] == index {
      playerProgress += 1
      
      if playerProgress == currentPath.count {
        if round >= totalRounds {
          isCompleted = true
          phase = .completed
        } else {
          round += 1
          startRound(resetProgress: false)
        }
      }
    } else {
      phase = .failed
    }
  }
  
  @MainActor
  func replayPreview() {
    playerProgress = 0
    runPreview()
  }
  
  func restart() {
    startRound(resetProgress: true)
  }
  
  @MainActor
  func cancelPreview() {
    previewTask?.cancel()
    previewTask = nil
  }
  
  @MainActor
  deinit {
    cancelPreview()
  }
  
  @MainActor
  func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView {
    AnyView(
      PathRecallChallengeView(
        challenge: self,
        onComplete: onComplete,
        appSettings: appSettings
      )
    )
  }
}

// MARK: - View

struct PathRecallChallengeView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Environment(\.challengeCancelAction) private var challengeCancelAction
  @ObservedObject var challenge: PathRecallChallenge
  let onComplete: () -> Void
  let appSettings: AppSettings
  
  @State private var elapsedTime: TimeInterval = 0
  private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
  
  var showCancelButton: Bool {
    challenge.isTestMode || elapsedTime >= TimeInterval(appSettings.challengeCancelDelaySeconds)
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Cancel button
        HStack {
          Spacer()
          if showCancelButton {
            Button(action: {
              if let cancelAction = challengeCancelAction {
                cancelAction()
              }
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
        VStack(spacing: 8) {
          Image(systemName: ChallengeType.pathRecall.icon)
            .font(.system(size: 60))
            .foregroundStyle(colors.pathRecall.gradient)
          
          Text(NSLocalizedString("challenge.path_recall.title", comment: ""))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
          
          Text(NSLocalizedString("challenge.path_recall.subtitle", comment: ""))
            .font(.system(size: 14))
            .foregroundColor(colors.textSecondary)
        }
        .padding(.top, 10)
        
        // Progress
        Text(String(format: NSLocalizedString("challenge.path_recall.progress", comment: ""), challenge.round, challenge.totalRounds))
          .font(.headline)
          .foregroundColor(colors.textPrimary)
        
        // Phase info
        VStack(spacing: 6) {
          switch challenge.phase {
          case .preview:
            Text(NSLocalizedString("challenge.path_recall.previewing", comment: ""))
              .foregroundColor(colors.pathRecall)
              .font(.headline)
          case .input:
            Text(NSLocalizedString("challenge.path_recall.your_turn", comment: ""))
              .foregroundColor(colors.textPrimary)
              .font(.headline)
          case .failed:
            Text(NSLocalizedString("challenge.path_recall.failed", comment: ""))
              .foregroundColor(colors.error)
              .font(.headline)
          case .completed:
            Text(NSLocalizedString("challenge.path_recall.completed", comment: ""))
              .foregroundColor(colors.success)
              .font(.headline)
          }
          
          if let next = challenge.nextIndex, challenge.phase == .input {
            Text(String(format: NSLocalizedString("challenge.path_recall.next_hint", comment: ""), next + 1))
              .font(.caption)
              .foregroundColor(colors.textSecondary)
          } else {
            // Keep layout stable between phases to avoid grid jump.
            Text("placeholder")
              .font(.caption)
              .foregroundColor(colors.textSecondary)
              .hidden()
          }
        }
        
        // Grid
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: challenge.gridSize), spacing: 12) {
          ForEach(0..<(challenge.gridSize * challenge.gridSize), id: \.self) { index in
            let isHighlighted = challenge.highlightedIndex == index
            let isNext = challenge.nextIndex == index
            let wasUsed = challenge.phase != .preview && challenge.currentPath.prefix(challenge.playerProgress).contains(index)
            
            RoundedRectangle(cornerRadius: 12)
              .fill(isHighlighted ? colors.pathRecall.opacity(0.9) :
                    isNext ? colors.pathRecall.opacity(0.35) :
                    wasUsed ? colors.surfaceElevated : colors.surface)
              .frame(height: 70)
              .overlay(
                Text("\(index + 1)")
                  .font(.headline)
                  .foregroundColor(colors.textPrimary)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(isHighlighted ? colors.textOnAccent.opacity(0.6) : colors.divider, lineWidth: 2)
              )
              .onTapGesture {
                challenge.handleTap(index)
              }
              .animation(.easeInOut(duration: 0.18), value: isHighlighted)
          }
        }
        .padding(.horizontal, 20)
        
        if challenge.phase == .input || challenge.phase == .preview {
          Button(action: {
            challenge.replayPreview()
          }) {
            Text(NSLocalizedString("challenge.path_recall.replay", comment: ""))
              .font(.subheadline.weight(.semibold))
              .foregroundColor(colors.textOnAccent)
              .frame(maxWidth: .infinity)
              .padding()
              .background(colors.pathRecall)
              .cornerRadius(12)
          }
          .padding(.horizontal, 40)
        }
        
        if challenge.phase == .failed {
          Button(action: {
            challenge.restart()
            elapsedTime = 0
          }) {
            Text(NSLocalizedString("challenge.path_recall.restart", comment: ""))
              .font(.headline)
              .foregroundColor(colors.textOnAccent)
              .frame(maxWidth: .infinity)
              .padding()
              .background(colors.pathRecall)
              .cornerRadius(12)
          }
          .padding(.horizontal, 40)
        }
        
        Spacer()
          .frame(height: 40)
      }
    }
    .scrollDisabled(true)
    .background(colors.background.ignoresSafeArea())
    .interactiveDismissDisabled(!showCancelButton)
    .presentationDetents([.large])
    .presentationDragIndicator(.hidden)
    .onDisappear {
      challenge.cancelPreview()
    }
    .onReceive(timer) { _ in
      elapsedTime += 0.05
    }
    .onChange(of: challenge.isCompleted) { _, completed in
      if completed {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          onComplete()
        }
      }
    }
  }
}

