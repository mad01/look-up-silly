import SwiftUI

struct PauseDurationSheet: View {
  @Binding var isPresented: Bool
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @State private var timeRemaining: TimeInterval = 0
  @State private var timer: Timer?
  
  var isPaused: Bool {
    appSettings.challengesPaused
  }
  
  var pauseEndTime: Date? {
    UserDefaults.standard.object(forKey: "pauseEndTime") as? Date
  }
  
  var body: some View {
    ZStack {
      // Dismiss area - tapping outside resumes challenges
      dismissArea
      
      // Floating picker card
      pickerCard
    }
  }
  
  // MARK: - Subviews
  
  private var dismissArea: some View {
    Color.black.opacity(0.3)
      .ignoresSafeArea()
      .contentShape(Rectangle())
      .onTapGesture {
        // Tapping outside = resume challenges
        handleDismissWithResume()
      }
  }
  
  private var pickerCard: some View {
    VStack(spacing: 30) {
        // Header
        VStack(spacing: 12) {
          Image(systemName: isPaused ? "clock.fill" : "pause.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(isPaused ? colors.success.gradient : colors.warning.gradient)
          
          Text(isPaused ? "Pause Active" : "Pause Challenges")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundColor(colors.textPrimary)
          
          if isPaused {
            // Show countdown
            if pauseEndTime != nil {
              VStack(spacing: 8) {
                Text(timeString(from: timeRemaining))
                  .font(.system(size: 48, weight: .bold, design: .rounded))
                  .foregroundColor(colors.success)
                  .monospacedDigit()
                
                Text("remaining")
                  .font(.subheadline)
                  .foregroundColor(colors.textSecondary)
              }
            } else {
              Text("Paused indefinitely")
                .font(.subheadline)
                .foregroundColor(colors.textSecondary)
            }
          } else {
            Text("How long do you need a break?")
              .font(.subheadline)
              .foregroundColor(colors.textSecondary)
              .multilineTextAlignment(.center)
          }
        }
        .padding(.top, 40)
        
        // Duration buttons section
        VStack(spacing: 12) {
          // Description text
          Text(isPaused ? "Extend your break" : "Choose duration")
            .font(.subheadline)
            .foregroundColor(colors.textSecondary)
          
          // Compact horizontal button row
          HStack(spacing: 12) {
            if isPaused {
              // Extend options when paused
              CompactDurationButton(
                minutes: 5,
                icon: "plus.circle"
              ) {
                extendPause(minutes: 5)
              }
              
              CompactDurationButton(
                minutes: 10,
                icon: "plus.circle"
              ) {
                extendPause(minutes: 10)
              }
              
              CompactDurationButton(
                minutes: 15,
                icon: "plus.circle"
              ) {
                extendPause(minutes: 15)
              }
            } else {
              // Initial duration options
              CompactDurationButton(
                minutes: 5,
                icon: "timer"
              ) {
                pauseFor(minutes: 5)
              }
              
              CompactDurationButton(
                minutes: 10,
                icon: "clock"
              ) {
                pauseFor(minutes: 10)
              }
              
              CompactDurationButton(
                minutes: 15,
                icon: "hourglass"
              ) {
                pauseFor(minutes: 15)
              }
            }
          }
        }
        .padding(.horizontal, 20)
        
        Spacer()
        
        // Bottom button - only show resume when paused
        if isPaused {
          Button(action: {
            resumeChallenges()
          }) {
            Text("Resume Challenges Now")
              .font(.headline)
              .foregroundColor(colors.textOnAccent)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(colors.danger)
              .cornerRadius(12)
          }
          .padding(.horizontal, 20)
          .padding(.bottom, 20)
        }
      }
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(colors.surface)
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(colors.primary.opacity(0.15), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.3), radius: 40, x: 0, y: 20)
      )
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .frame(maxWidth: 400)
      .padding(.horizontal, 20)
      .padding(.vertical, 50)
  }
  
  // MARK: - Actions
  
  private func handleDismissWithResume() {
    // If paused, resume challenges
    if isPaused {
      resumeChallenges()
    }
    
    // Close the overlay
    withAnimation(.easeOut(duration: 0.15)) {
      isPresented = false
    }
  }
  
  private func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
      Task { @MainActor [self] in
        self.updateTimeRemaining()
        
        // Auto-dismiss if time expired
        if self.timeRemaining <= 0 {
          self.stopTimer()
          withAnimation(.easeOut(duration: 0.15)) {
            self.isPresented = false
          }
        }
      }
    }
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func updateTimeRemaining() {
    if let endTime = pauseEndTime {
      timeRemaining = max(0, endTime.timeIntervalSince(Date()))
    } else {
      timeRemaining = 0
    }
  }
  
  private func timeString(from timeInterval: TimeInterval) -> String {
    let minutes = Int(timeInterval) / 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
  
  private func resumeChallenges() {
    appSettings.challengesPaused = false
    UserDefaults.standard.removeObject(forKey: "pauseEndTime")
    screenTimeManager.updateShielding()
    NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
    
    withAnimation(.easeOut(duration: 0.15)) {
      isPresented = false
    }
  }
  
  private func pauseFor(minutes: Int) {
    let duration = TimeInterval(minutes * 60)
    
    // Set pause state
    appSettings.challengesPaused = true
    
    // Set end time
    let endTime = Date().addingTimeInterval(duration)
    UserDefaults.standard.set(endTime, forKey: "pauseEndTime")
    
    // Remove shields
    screenTimeManager.removeAllShields()
    
    // Schedule auto-resume
    Task {
      try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      
      await MainActor.run {
        // Check if pause end time hasn't been changed
        if let storedEndTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date,
           abs(storedEndTime.timeIntervalSince(endTime)) < 1 {
          appSettings.challengesPaused = false
          UserDefaults.standard.removeObject(forKey: "pauseEndTime")
          screenTimeManager.updateShielding()
          NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
        }
      }
    }
    
    // Notify to update quick actions
    NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
    
    // Update the timer display immediately
    updateTimeRemaining()
    
    // Start the countdown timer
    startTimer()
    
    // Keep the overlay open to show the countdown
  }
  
  private func extendPause(minutes: Int) {
    let additionalDuration = TimeInterval(minutes * 60)
    
    // Get current end time or use now if none
    let currentEndTime = pauseEndTime ?? Date()
    
    // Add additional time
    let newEndTime = currentEndTime.addingTimeInterval(additionalDuration)
    UserDefaults.standard.set(newEndTime, forKey: "pauseEndTime")
    
    // Update timer display
    updateTimeRemaining()
    
    // Notify to update quick actions
    NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
    
    // Stay on sheet to show updated countdown
    // Don't dismiss
  }
}

// Compact horizontal duration button
struct CompactDurationButton: View {
  @Environment(\.themeColors) private var colors
  let minutes: Int
  let icon: String
  let action: () -> Void
  @State private var isPressed = false
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.1)) {
        isPressed = true
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isPressed = false
        action()
      }
    }) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.system(size: 28))
          .foregroundColor(colors.primary)
        
        Text("\(minutes)")
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundColor(colors.textPrimary)
        
        Text("min")
          .font(.caption)
          .foregroundColor(colors.textSecondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 20)
      .background(colors.surface)
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(colors.primary.opacity(0.3), lineWidth: 1)
      )
      .scaleEffect(isPressed ? 0.95 : 1.0)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  PauseDurationSheet(isPresented: .constant(true))
    .environmentObject(AppSettings())
}

