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
    VStack(spacing: 12) {
      #if targetEnvironment(simulator)
      // Subtle warning for developers: Simulator limitation
      HStack(spacing: 8) {
        Image(systemName: "exclamationmark.triangle")
          .foregroundColor(colors.warning)
          .font(.caption)
        
        Text("App picker won't show apps in simulator. Test on real device.")
          .font(.caption2)
          .foregroundColor(colors.textSecondary)
      }
      .padding(.bottom, 4)
      #endif
      
      Button(action: {
        isPresented = true
      }) {
        HStack {
          Image(systemName: "app.badge.checkmark")
            .foregroundColor(colors.primary)
            .font(.system(size: 24))
          
          VStack(alignment: .leading, spacing: 4) {
            Text(title)
              .font(.headline)
              .foregroundColor(colors.textPrimary)
            
            if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
              Text(subtitle)
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
      }
      .familyActivityPicker(isPresented: $isPresented, selection: $selection)
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

