import SwiftUI
import FamilyControls

struct FamilyActivityPickerView: View {
  @Binding var selection: FamilyActivitySelection
  @State private var isPresented = false
  let title: String
  let subtitle: String
  
  var body: some View {
    VStack(spacing: 20) {
      VStack(spacing: 8) {
        Text(title)
          .font(.title2.bold())
          .foregroundColor(.white)
        
        Text(subtitle)
          .font(.subheadline)
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
      
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
              Text("No apps selected")
                .font(.caption)
                .foregroundColor(.gray)
            } else {
              Text("\(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
                .font(.caption)
                .foregroundColor(.blue)
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
    }
    .padding(.horizontal, 20)
  }
}

#Preview {
  FamilyActivityPickerView(
    selection: .constant(FamilyActivitySelection()),
    title: "Choose Apps",
    subtitle: "Select which apps to manage"
  )
}

