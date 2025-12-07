import SwiftUI

/// Warm and Calm Theme colors
/// Inspired by earth tones, warm woods, and calming nature
struct WarmCalmTheme {
  // Background Colors - Warm dark browns and deep earth tones
  static let background = Color(red: 28/255, green: 24/255, blue: 22/255)        // Deep warm brown
  static let surface = Color(red: 42/255, green: 36/255, blue: 33/255)          // Elevated warm brown
  static let surfaceElevated = Color(red: 52/255, green: 45/255, blue: 41/255)  // Medium elevation
  static let surfaceElevatedHigh = Color(red: 62/255, green: 54/255, blue: 49/255)  // High elevation
  
  // Primary Colors - Warm terracotta and clay tones
  static let primary = Color(red: 210/255, green: 145/255, blue: 110/255)       // Warm terracotta
  static let primaryVariant = Color(red: 190/255, green: 125/255, blue: 90/255) // Deeper terracotta
  
  // Accent Colors - Sage green for calm
  static let secondary = Color(red: 160/255, green: 175/255, blue: 140/255)     // Soft sage green
  static let secondaryVariant = Color(red: 140/255, green: 155/255, blue: 120/255) // Deeper sage
  
  // Status Colors - Warm and muted
  static let error = Color(red: 200/255, green: 120/255, blue: 110/255)         // Warm muted red
  static let success = Color(red: 160/255, green: 180/255, blue: 130/255)       // Warm sage green
  static let warning = Color(red: 220/255, green: 170/255, blue: 110/255)       // Warm amber
  
  // Text Colors (maintaining good contrast)
  static let textPrimary = Color(red: 245/255, green: 240/255, blue: 235/255).opacity(0.92)   // Warm off-white
  static let textSecondary = Color(red: 220/255, green: 210/255, blue: 200/255).opacity(0.70) // Muted warm
  static let textDisabled = Color(red: 180/255, green: 170/255, blue: 160/255).opacity(0.45)  // Very muted
  static let textOnAccent = Color(red: 30/255, green: 25/255, blue: 22/255).opacity(0.90)     // Dark on light accent
  
  // Dividers and borders - Warm subtle
  static let divider = Color(red: 200/255, green: 180/255, blue: 160/255).opacity(0.15)
  static let border = Color(red: 200/255, green: 180/255, blue: 160/255).opacity(0.20)
  
  // Challenge-related colors - Warm and inviting
  static let challengeEasy = Color(red: 160/255, green: 180/255, blue: 130/255)    // Sage green
  static let challengeMedium = Color(red: 220/255, green: 170/255, blue: 110/255)  // Warm amber
  static let challengeHard = Color(red: 210/255, green: 145/255, blue: 110/255)    // Terracotta
  
  // Action colors - Warm tones
  static let info = Color(red: 140/255, green: 165/255, blue: 180/255)          // Muted slate blue
  static let danger = Color(red: 200/255, green: 120/255, blue: 110/255)        // Warm coral
  static let cautionYellow = Color(red: 220/255, green: 185/255, blue: 120/255) // Warm golden
  
  // App-specific colors
  static let appSelection = Color(red: 140/255, green: 165/255, blue: 180/255)  // Calm blue-gray
  static let streak = Color(red: 220/255, green: 170/255, blue: 110/255)        // Warm amber
  static let premium = Color(red: 200/255, green: 160/255, blue: 110/255)       // Warm bronze
  
  // Highlight colors for interactive elements
  static let highlight = Color(red: 210/255, green: 145/255, blue: 110/255).opacity(0.20)
  static let highlightStrong = Color(red: 210/255, green: 145/255, blue: 110/255).opacity(0.35)
  
  // Game/Challenge specific
  static let mathChallenge = Color(red: 140/255, green: 165/255, blue: 180/255) // Calm blue
  static let ticTacToe = Color(red: 160/255, green: 175/255, blue: 140/255)     // Sage green
  
  // Chart/Statistics colors - Warm harmonious palette
  static let chartPrimary = Color(red: 210/255, green: 145/255, blue: 110/255)
  static let chartSecondary = Color(red: 160/255, green: 175/255, blue: 140/255)
  static let chartTertiary = Color(red: 220/255, green: 170/255, blue: 110/255)
  static let chartQuaternary = Color(red: 140/255, green: 165/255, blue: 180/255)
}

/// Theme colors environment key
struct ThemeColorsKey: EnvironmentKey {
  static let defaultValue = ThemeColors()
}

extension EnvironmentValues {
  var themeColors: ThemeColors {
    get { self[ThemeColorsKey.self] }
    set { self[ThemeColorsKey.self] = newValue }
  }
}

/// Theme colors container
struct ThemeColors {
  let background = WarmCalmTheme.background
  let surface = WarmCalmTheme.surface
  let surfaceElevated = WarmCalmTheme.surfaceElevated
  let surfaceElevatedHigh = WarmCalmTheme.surfaceElevatedHigh
  
  let primary = WarmCalmTheme.primary
  let primaryVariant = WarmCalmTheme.primaryVariant
  
  let secondary = WarmCalmTheme.secondary
  let secondaryVariant = WarmCalmTheme.secondaryVariant
  
  let error = WarmCalmTheme.error
  let success = WarmCalmTheme.success
  let warning = WarmCalmTheme.warning
  
  let textPrimary = WarmCalmTheme.textPrimary
  let textSecondary = WarmCalmTheme.textSecondary
  let textDisabled = WarmCalmTheme.textDisabled
  let textOnAccent = WarmCalmTheme.textOnAccent
  
  let divider = WarmCalmTheme.divider
  let border = WarmCalmTheme.border
  
  let challengeEasy = WarmCalmTheme.challengeEasy
  let challengeMedium = WarmCalmTheme.challengeMedium
  let challengeHard = WarmCalmTheme.challengeHard
  
  let info = WarmCalmTheme.info
  let danger = WarmCalmTheme.danger
  let cautionYellow = WarmCalmTheme.cautionYellow
  
  let appSelection = WarmCalmTheme.appSelection
  let streak = WarmCalmTheme.streak
  let premium = WarmCalmTheme.premium
  
  let highlight = WarmCalmTheme.highlight
  let highlightStrong = WarmCalmTheme.highlightStrong
  
  let mathChallenge = WarmCalmTheme.mathChallenge
  let ticTacToe = WarmCalmTheme.ticTacToe
  
  let chartPrimary = WarmCalmTheme.chartPrimary
  let chartSecondary = WarmCalmTheme.chartSecondary
  let chartTertiary = WarmCalmTheme.chartTertiary
  let chartQuaternary = WarmCalmTheme.chartQuaternary
}

/// View modifier to apply themed background
struct ThemedViewModifier: ViewModifier {
  @Environment(\.themeColors) private var colors
  
  func body(content: Content) -> some View {
    content
      .background(colors.background.ignoresSafeArea())
      .environment(\.themeColors, colors)
  }
}

extension View {
  func themedView() -> some View {
    modifier(ThemedViewModifier())
  }
}

