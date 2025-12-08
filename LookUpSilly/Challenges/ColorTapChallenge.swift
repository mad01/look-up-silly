import SwiftUI

struct ColorTapOption: Identifiable, Equatable {
  let id = UUID()
  let nameKey: String
  let color: Color
  
  var name: String {
    NSLocalizedString(nameKey, comment: "")
  }
}

enum ColorTapState {
  case playing, failed, completed
}

// MARK: - Color Tap Challenge
// Challenge: Tap the named color before time runs out. Survive all rounds.
class ColorTapChallenge: Challenge, ObservableObject {
  let type = ChallengeType.colorTap
  @Published var isCompleted = false
  @Published var state: ColorTapState = .playing
  @Published var round = 1
  let totalRounds = 12
  @Published var options: [ColorTapOption] = []
  @Published var currentPrompt: ColorTapOption?
  @Published var timeRemaining: Double = 0
  var isTestMode = false
  
  private let palette: [ColorTapOption] = [
    ColorTapOption(nameKey: "challenge.color_tap.color.sunset", color: WarmCalmTheme.colorTap),
    ColorTapOption(nameKey: "challenge.color_tap.color.clay", color: WarmCalmTheme.stackBuilder),
    ColorTapOption(nameKey: "challenge.color_tap.color.sand", color: WarmCalmTheme.pathRecall),
    ColorTapOption(nameKey: "challenge.color_tap.color.sage", color: WarmCalmTheme.ticTacToe),
    ColorTapOption(nameKey: "challenge.color_tap.color.ember", color: WarmCalmTheme.micro2048)
  ]
  
  var timeLimit: Double {
    max(1.6, 4.0 - Double(round - 1) * 0.2)
  }
  
  init() {
    startRound(resetProgress: true)
  }
  
  func startRound(resetProgress: Bool) {
    if resetProgress {
      round = 1
      isCompleted = false
    }
    
    state = .playing
    options = Array(palette.shuffled().prefix(3))
    currentPrompt = options.randomElement()
    timeRemaining = timeLimit
  }
  
  func select(_ option: ColorTapOption) {
    guard state == .playing else { return }
    
    if option == currentPrompt {
      if round >= totalRounds {
        state = .completed
        isCompleted = true
      } else {
        round += 1
        options = Array(palette.shuffled().prefix(3))
        currentPrompt = options.randomElement()
        timeRemaining = timeLimit
      }
    } else {
      state = .failed
    }
  }
  
  func tick(delta: Double) {
    guard state == .playing else { return }
    timeRemaining = max(0, timeRemaining - delta)
    
    if timeRemaining <= 0 {
      state = .failed
    }
  }
  
  func restart() {
    startRound(resetProgress: true)
  }
  
  @MainActor
  func view(onComplete: @escaping () -> Void, appSettings: AppSettings) -> AnyView {
    AnyView(
      ColorTapChallengeView(
        challenge: self,
        onComplete: onComplete,
        appSettings: appSettings
      )
    )
  }
}

// MARK: - View

struct ColorTapChallengeView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Environment(\.challengeCancelAction) private var challengeCancelAction
  @ObservedObject var challenge: ColorTapChallenge
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
          Image(systemName: ChallengeType.colorTap.icon)
            .font(.system(size: 60))
            .foregroundStyle(colors.colorTap.gradient)
          
          Text(NSLocalizedString("challenge.color_tap.title", comment: ""))
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(colors.textPrimary)
          
          Text(NSLocalizedString("challenge.color_tap.subtitle", comment: ""))
            .font(.system(size: 14))
            .foregroundColor(colors.textSecondary)
        }
        .padding(.top, 10)
        
        // Progress + timer
        VStack(spacing: 12) {
          Text(String(format: NSLocalizedString("challenge.color_tap.progress", comment: ""), challenge.round, challenge.totalRounds))
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          
          TimeBarView(progress: max(0, min(1, challenge.timeRemaining / challenge.timeLimit)), color: colors.colorTap)
        }
        .padding(.horizontal, 24)
        
        // Prompt
        if let prompt = challenge.currentPrompt {
          VStack(spacing: 12) {
            Text(NSLocalizedString("challenge.color_tap.prompt", comment: ""))
              .font(.subheadline)
              .foregroundColor(colors.textSecondary)
            
            Text(prompt.name)
              .font(.system(size: 32, weight: .bold))
              .foregroundColor(colors.colorTap)
          }
        }
        
        // Options
        HStack(spacing: 12) {
          ForEach(challenge.options) { option in
            Button(action: {
              challenge.select(option)
            }) {
              VStack(spacing: 10) {
                Circle()
                  .fill(option.color)
                  .frame(width: 44, height: 44)
                  .overlay(
                    Circle()
                      .stroke(colors.border, lineWidth: 1)
                  )
                
                Text(option.name)
                  .font(.headline)
                  .foregroundColor(colors.textPrimary)
                  .lineLimit(1)
                  .minimumScaleFactor(0.8)
                  .multilineTextAlignment(.center)
              }
              .padding(.vertical, 14)
              .padding(.horizontal, 10)
              .frame(maxWidth: .infinity)
              .background(colors.surface)
              .cornerRadius(12)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(colors.border, lineWidth: 1)
              )
            }
          }
        }
        .padding(.horizontal, 20)
        
        // State messages
        if challenge.state == .failed {
          VStack(spacing: 8) {
            Text(NSLocalizedString("challenge.color_tap.failed", comment: ""))
              .foregroundColor(colors.error)
              .font(.headline)
            Button(action: {
              challenge.restart()
              elapsedTime = 0
            }) {
              Text(NSLocalizedString("challenge.color_tap.restart", comment: ""))
                .font(.headline)
                .foregroundColor(colors.textOnAccent)
                .frame(maxWidth: .infinity)
                .padding()
                .background(colors.colorTap)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
          }
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
    .onReceive(timer) { _ in
      elapsedTime += 0.05
      challenge.tick(delta: 0.05)
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

// MARK: - Time Bar

private struct TimeBarView: View {
  let progress: Double
  let color: Color
  
  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(color.opacity(0.2))
        Capsule()
          .fill(color.gradient)
          .frame(width: max(0, geo.size.width * progress))
          .animation(.easeInOut(duration: 0.1), value: progress)
      }
    }
    .frame(height: 16)
  }
}

