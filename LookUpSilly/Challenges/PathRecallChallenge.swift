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
  let totalRounds = 5
  var isTestMode = false
  
  private var previewTask: Task<Void, Never>?
  
  init() {
    startRound(resetProgress: true)
  }
  
  var currentPathLength: Int {
    min(2 + (round - 1), 6)
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
    // Small delay before showing first tile to let user get ready
    try? await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds initial delay
    
    for index in currentPath {
      try? Task.checkCancellation()
      highlightedIndex = index
      try? await Task.sleep(nanoseconds: 900_000_000) // 0.9 seconds highlight
      highlightedIndex = nil
      try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds gap
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
  @State private var hasRecordedStart = false
  @State private var outcome: ChallengeOutcome = .pending
  @State private var tappedIndex: Int?
  
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
    GeometryReader { geometry in
      let isCompact = geometry.size.height < 700
      
      ScrollView {
        VStack(spacing: isCompact ? 12 : 20) {
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
          .padding(.top, isCompact ? 12 : 20)
          
          // Header
          VStack(spacing: isCompact ? 4 : 6) {
            Text(NSLocalizedString("challenge.path_recall.title", comment: ""))
              .font(.system(size: isCompact ? 22 : 28, weight: .bold))
              .foregroundColor(colors.textPrimary)
            
            Text(NSLocalizedString("challenge.path_recall.subtitle", comment: ""))
              .font(.system(size: isCompact ? 12 : 14))
              .foregroundColor(colors.textSecondary)
          }
          .padding(.top, isCompact ? 4 : 10)
        
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
          
          // Keep layout stable between phases to avoid grid jump.
          Text("placeholder")
            .font(.caption)
            .foregroundColor(colors.textSecondary)
            .hidden()
        }
        
        // Grid - no hints shown, only highlight during preview
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: challenge.gridSize), spacing: 12) {
          ForEach(0..<(challenge.gridSize * challenge.gridSize), id: \.self) { index in
            let isHighlighted = challenge.highlightedIndex == index
            let wasUsed = challenge.phase != .preview && challenge.currentPath.prefix(challenge.playerProgress).contains(index)
            let isActiveTap = challenge.phase == .input && tappedIndex == index
            
            RoundedRectangle(cornerRadius: 12)
              .fill(
                isHighlighted || isActiveTap
                ? colors.pathRecall.opacity(0.9)
                : (wasUsed ? colors.surfaceElevated : colors.surface)
              )
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
                tappedIndex = index
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                  if tappedIndex == index { tappedIndex = nil }
                }
                challenge.handleTap(index)
              }
              .animation(.easeInOut(duration: 0.18), value: isHighlighted || isActiveTap)
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
            .frame(height: isCompact ? 20 : 40)
        }
      }
    }
    .background(colors.background.ignoresSafeArea())
    .interactiveDismissDisabled(!canSkip)
    .presentationDetents([.large])
    .presentationDragIndicator(.hidden)
    .onReceive(timer) { _ in
      elapsedTime += 0.05
    }
    .onChange(of: challenge.isCompleted) { _, completed in
      if completed {
        outcome = .continued
        ChallengeStatsManager.shared.recordChallengeCompleted(type: .pathRecall, isTestMode: challenge.isTestMode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
          onComplete()
        }
      }
    }
    .onAppear {
      recordStartIfNeeded()
    }
    .onDisappear {
      challenge.cancelPreview()
      if outcome == .pending {
        ChallengeStatsManager.shared.recordChallengeCancelled(type: .pathRecall, isTestMode: challenge.isTestMode)
      }
    }
  }
}

private enum ChallengeOutcome {
  case pending
  case continued
  case cancelled
}

private extension PathRecallChallengeView {
  func recordStartIfNeeded() {
    guard !hasRecordedStart else { return }
    hasRecordedStart = true
    ChallengeStatsManager.shared.recordChallengeTriggered(type: .pathRecall, isTestMode: challenge.isTestMode)
  }
  
  func skipChallenge() {
    guard canSkip else { return }
    outcome = .continued
    ChallengeStatsManager.shared.recordChallengeContinued(type: .pathRecall, isTestMode: challenge.isTestMode)
    if let cancelAction = challengeCancelAction {
      cancelAction()
    }
    dismiss()
  }
  
  func cancelChallenge() {
    outcome = .cancelled
    ChallengeStatsManager.shared.recordChallengeCancelled(type: .pathRecall, isTestMode: challenge.isTestMode)
    dismiss()
  }
}

