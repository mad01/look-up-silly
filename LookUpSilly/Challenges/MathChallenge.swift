import SwiftUI

// MARK: - Math Challenge
// Challenge: Solve 5 random simple math problems to unlock app access

class MathChallenge: Challenge, ObservableObject {
  let type = ChallengeType.math
  @Published var isCompleted = false
  @Published private(set) var problems: [MathProblem] = []
  @Published private(set) var currentProblemIndex = 0
  @Published var userAnswer = ""
  @Published var showError = false
  var isTestMode = false
  
  init() {
    generateProblems()
  }
  
  private func generateProblems() {
    problems = (0..<5).map { _ in MathProblem() }
  }
  
  func checkAnswer() {
    guard let answer = Int(userAnswer) else {
      showError = true
      return
    }
    
    if answer == problems[currentProblemIndex].correctAnswer {
      showError = false
      userAnswer = ""
      
      if currentProblemIndex < problems.count - 1 {
        currentProblemIndex += 1
      } else {
        isCompleted = true
      }
    } else {
      showError = true
    }
  }
  
  @MainActor
  func view(onComplete: @escaping () -> Void) -> AnyView {
    AnyView(MathChallengeView(challenge: self, onComplete: onComplete))
  }
}

// MARK: - Math Problem Model

struct MathProblem {
  enum Operation: String, CaseIterable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    
    func calculate(_ a: Int, _ b: Int) -> Int {
      switch self {
      case .add: return a + b
      case .subtract: return a - b
      case .multiply: return a * b
      }
    }
  }
  
  let num1: Int
  let num2: Int
  let operation: Operation
  let correctAnswer: Int
  
  init() {
    operation = Operation.allCases.randomElement()!
    
    switch operation {
    case .add:
      num1 = Int.random(in: 1...50)
      num2 = Int.random(in: 1...50)
    case .subtract:
      num1 = Int.random(in: 10...50)
      num2 = Int.random(in: 1...num1)
    case .multiply:
      num1 = Int.random(in: 2...12)
      num2 = Int.random(in: 2...12)
    }
    
    correctAnswer = operation.calculate(num1, num2)
  }
  
  var question: String {
    "\(num1) \(operation.rawValue) \(num2) = ?"
  }
}

// MARK: - Math Challenge View

struct MathChallengeView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var appSettings: AppSettings
  @ObservedObject var challenge: MathChallenge
  let onComplete: () -> Void
  @FocusState private var isInputFocused: Bool
  
  @State private var elapsedTime: TimeInterval = 0
  @State private var timer: Timer?
  
  var showCancelButton: Bool {
    // Always show in test mode, or after the configured delay in challenge mode
    challenge.isTestMode || elapsedTime >= TimeInterval(appSettings.challengeCancelDelaySeconds)
  }
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      ScrollView {
        VStack(spacing: 24) {
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
            Image(systemName: "function")
              .font(.system(size: 50))
              .foregroundStyle(colors.mathChallenge.gradient)
            
            Text("Math Challenge")
              .font(.system(size: 28, weight: .bold))
              .foregroundColor(colors.textPrimary)
            
            Text("Solve 5 problems to continue")
              .font(.subheadline)
              .foregroundColor(colors.textSecondary)
          }
          .padding(.top, 40)
          
          // Progress
          HStack(spacing: 8) {
            ForEach(0..<5) { index in
              Circle()
                .fill(index < challenge.currentProblemIndex ? colors.success : 
                      index == challenge.currentProblemIndex ? colors.mathChallenge : colors.textDisabled)
                .frame(width: 12, height: 12)
            }
          }
          .padding(.vertical, 8)
          
          // Current Problem
          if challenge.currentProblemIndex < challenge.problems.count {
            VStack(spacing: 24) {
              Text("Problem \(challenge.currentProblemIndex + 1) of 5")
                .font(.headline)
                .foregroundColor(colors.textSecondary)
              
              Text(challenge.problems[challenge.currentProblemIndex].question)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colors.textPrimary)
                .padding(.vertical, 8)
              
              TextField("Your answer", text: $challenge.userAnswer)
                .keyboardType(.numberPad)
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(colors.textPrimary)
                .padding()
                .background(colors.surface)
                .cornerRadius(12)
                .focused($isInputFocused)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(challenge.showError ? colors.error : Color.clear, lineWidth: 2)
                )
                .padding(.horizontal, 40)
              
              if challenge.showError {
                Text("Incorrect! Try again")
                  .foregroundColor(colors.error)
                  .font(.headline)
              }
              
              Button(action: {
                challenge.checkAnswer()
              }) {
                Text("Submit")
                  .font(.headline)
                  .foregroundColor(colors.textOnAccent)
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(challenge.userAnswer.isEmpty ? colors.textDisabled : colors.mathChallenge)
                  .cornerRadius(12)
              }
              .disabled(challenge.userAnswer.isEmpty)
              .padding(.horizontal, 40)
            }
          }
          
          // Bottom spacer to ensure content is scrollable above keyboard
          Spacer()
            .frame(height: 100)
        }
        .frame(maxWidth: .infinity)
      }
      .scrollDismissesKeyboard(.interactively)
    }
    .interactiveDismissDisabled(!showCancelButton)
    .onAppear {
      isInputFocused = true
      startTimer()
    }
    .onDisappear {
      stopTimer()
    }
    .onChange(of: challenge.isCompleted) { _, completed in
      if completed {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          onComplete()
        }
      }
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
}

// MARK: - Preview

#Preview {
  MathChallengeView(challenge: MathChallenge(), onComplete: {})
}

