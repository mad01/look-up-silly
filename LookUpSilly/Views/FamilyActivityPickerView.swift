import SwiftUI
import FamilyControls

// IMPORTANT: FamilyActivityPicker does NOT work properly in the iOS Simulator
// - Categories will appear empty even if you search
// - No installed apps will be shown
// - This is a known limitation of the Screen Time API in the simulator
// ⚠️  MUST TEST ON A REAL DEVICE to see installed apps and verify functionality

struct FamilyActivityPickerView: View {
  @Environment(\.themeColors) private var colors
  @Binding var selection: FamilyActivitySelection
  @State private var isPresented = false
  let title: String
  let subtitle: String
  
  var body: some View {
    VStack(spacing: 16) {
      #if targetEnvironment(simulator)
      // Warning for developers: Simulator limitation
      HStack(alignment: .top, spacing: 8) {
        Image(systemName: "exclamationmark.triangle.fill")
          .foregroundColor(colors.warning)
          .font(.system(size: 14))
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Simulator Mode")
            .font(.caption.bold())
            .foregroundColor(colors.warning)
          Text("App picker won't show apps in simulator. Test on real device.")
            .font(.caption2)
            .foregroundColor(colors.textSecondary)
        }
      }
      .padding(8)
      .background(colors.warning.opacity(0.15))
      .cornerRadius(6)
      #endif
      
      VStack(spacing: 8) {
        Text(title)
          .font(.title2.bold())
          .foregroundColor(colors.textPrimary)
        
        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(colors.textSecondary)
          .multilineTextAlignment(.center)
      }
      
      // Instructional hint box
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lightbulb.fill")
          .foregroundColor(colors.cautionYellow)
          .font(.system(size: 16))
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Tip: Use the search bar")
            .font(.caption.bold())
            .foregroundColor(colors.textPrimary)
          Text("Find your apps quickly by searching. Only categories with installed apps will show content.")
            .font(.caption2)
            .foregroundColor(colors.textSecondary)
        }
      }
      .padding(12)
      .background(colors.cautionYellow.opacity(0.15))
      .cornerRadius(8)
      
      Button(action: {
        isPresented = true
      }) {
        HStack {
          Image(systemName: "app.badge.checkmark")
            .font(.title2)
          
          VStack(alignment: .leading, spacing: 4) {
            Text("Select Apps")
              .font(.headline)
            
            if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
              Text("Tap to choose apps")
                .font(.caption)
                .foregroundColor(colors.textSecondary)
            } else {
              let appCount = selection.applicationTokens.count
              let categoryCount = selection.categoryTokens.count
              
              if appCount > 0 && categoryCount > 0 {
                Text("\(appCount) app\(appCount == 1 ? "" : "s") + \(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")")
                  .font(.caption)
                  .foregroundColor(colors.appSelection)
              } else if appCount > 0 {
                Text("\(appCount) app\(appCount == 1 ? "" : "s") selected")
                  .font(.caption)
                  .foregroundColor(colors.appSelection)
              } else {
                Text("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies") selected")
                  .font(.caption)
                  .foregroundColor(colors.appSelection)
              }
            }
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .foregroundColor(colors.textSecondary)
        }
        .foregroundColor(colors.textPrimary)
        .padding()
        .background(colors.surface)
        .cornerRadius(12)
      }
      .familyActivityPicker(isPresented: $isPresented, selection: $selection)
      
      // Additional help text
      if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
        Text("Select individual apps or entire categories based on what you have installed")
          .font(.caption2)
          .foregroundColor(colors.textDisabled)
          .multilineTextAlignment(.center)
      }
    }
  }
}

#Preview {
  FamilyActivityPickerView(
    selection: .constant(FamilyActivitySelection()),
    title: "Choose Apps",
    subtitle: "Select which apps to manage"
  )
}

