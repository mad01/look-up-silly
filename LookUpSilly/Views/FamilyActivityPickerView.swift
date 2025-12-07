import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
  @Binding var selection: FamilyActivitySelection
  @State private var isPresented = false
  let title: String
  let subtitle: String
  
  var body: some View {
    VStack(spacing: 16) {
      VStack(spacing: 8) {
        Text(title)
          .font(.title2.bold())
          .foregroundColor(.white)
        
        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
      
      // Instructional hint box
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lightbulb.fill")
          .foregroundColor(.yellow)
          .font(.system(size: 16))
        
        VStack(alignment: .leading, spacing: 4) {
          Text("Tip: Use the search bar")
            .font(.caption.bold())
            .foregroundColor(.white)
          Text("Find your apps quickly by searching. Only categories with installed apps will show content.")
            .font(.caption2)
            .foregroundColor(.gray)
        }
      }
      .padding(12)
      .background(Color.yellow.opacity(0.15))
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
                .foregroundColor(.gray)
            } else {
              let appCount = selection.applicationTokens.count
              let categoryCount = selection.categoryTokens.count
              
              if appCount > 0 && categoryCount > 0 {
                Text("\(appCount) app\(appCount == 1 ? "" : "s") + \(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")")
                  .font(.caption)
                  .foregroundColor(.blue)
              } else if appCount > 0 {
                Text("\(appCount) app\(appCount == 1 ? "" : "s") selected")
                  .font(.caption)
                  .foregroundColor(.blue)
              } else {
                Text("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies") selected")
                  .font(.caption)
                  .foregroundColor(.blue)
              }
            }
          }
          
          Spacer()
          
          Image(systemName: "chevron.right")
            .foregroundColor(.gray)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
      }
      .familyActivityPicker(isPresented: $isPresented, selection: $selection)
      
      // Additional help text
      if selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty {
        Text("Select individual apps or entire categories based on what you have installed")
          .font(.caption2)
          .foregroundColor(.gray.opacity(0.7))
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

