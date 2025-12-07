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
  @ObservedObject var challenge: MathChallenge
  let onComplete: () -> Void
  @FocusState private var isInputFocused: Bool
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        colors.background.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 40) {
            // Header
            VStack(spacing: 12) {
              Image(systemName: "function")
                .font(.system(size: 60))
                .foregroundStyle(colors.mathChallenge.gradient)
              
              Text("Math Challenge")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(colors.textPrimary)
              
              Text("Solve 5 problems to continue")
                .font(.subheadline)
                .foregroundColor(colors.textSecondary)
            }
            .padding(.top, 60)
            
            // Progress
            HStack(spacing: 8) {
              ForEach(0..<5) { index in
                Circle()
                  .fill(index < challenge.currentProblemIndex ? colors.success : 
                        index == challenge.currentProblemIndex ? colors.mathChallenge : colors.textDisabled)
                  .frame(width: 12, height: 12)
              }
            }
            
            // Current Problem
            if challenge.currentProblemIndex < challenge.problems.count {
              VStack(spacing: 30) {
                Text("Problem \(challenge.currentProblemIndex + 1) of 5")
                  .font(.headline)
                  .foregroundColor(colors.textSecondary)
                
                Text(challenge.problems[challenge.currentProblemIndex].question)
                  .font(.system(size: 48, weight: .bold, design: .rounded))
                  .foregroundColor(colors.textPrimary)
                
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
              .padding(.top, 40)
            }
            
            Spacer(minLength: 40)
          }
          .frame(minHeight: geometry.size.height - 100)
        }
        .scrollDismissesKeyboard(.interactively)
      }
    }
    .onAppear {
      isInputFocused = true
    }
    .onChange(of: challenge.isCompleted) { _, completed in
      if completed {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          onComplete()
        }
      }
    }
  }
}

// MARK: - Preview

#Preview {
  MathChallengeView(challenge: MathChallenge(), onComplete: {})
}

