import SwiftUI
import FamilyControls

struct ScreenTimeAuthView: View {
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @State private var isRequesting = false
  @State private var errorMessage: String?
  let onAuthorized: () -> Void
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      VStack(spacing: 30) {
        Spacer()
        
        Image(systemName: "hourglass.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100, height: 100)
          .foregroundStyle(.blue.gradient)
        
        VStack(spacing: 12) {
          Text("Screen Time Access")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.white)
          
          Text("Look Up, Silly! needs Screen Time access to manage app blocking")
            .font(.system(size: 16))
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
        
        VStack(alignment: .leading, spacing: 16) {
          PermissionFeatureRow(
            icon: "shield.checkered",
            text: "Block distracting apps"
          )
          PermissionFeatureRow(
            icon: "puzzlepiece.fill",
            text: "Unlock with challenges"
          )
          PermissionFeatureRow(
            icon: "brain.head.profile",
            text: "Build better habits"
          )
        }
        .padding(.horizontal, 40)
        
        if let error = errorMessage {
          Text(error)
            .font(.caption)
            .foregroundColor(.red)
            .padding(.horizontal, 40)
        }
        
        Spacer()
        
        Button(action: {
          requestAuthorization()
        }) {
          HStack {
            if isRequesting {
              ProgressView()
                .tint(.white)
            }
            Text(isRequesting ? "Requesting..." : "Grant Access")
              .font(.headline)
          }
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(isRequesting ? Color.gray : Color.blue)
          .cornerRadius(12)
        }
        .disabled(isRequesting)
        .padding(.horizontal, 40)
        .padding(.bottom, 50)
      }
    }
  }
  
  private func requestAuthorization() {
    isRequesting = true
    errorMessage = nil
    
    Task {
      do {
        try await screenTimeManager.requestAuthorization()
        if screenTimeManager.isAuthorized {
          onAuthorized()
        } else {
          errorMessage = "Screen Time access was not granted"
        }
      } catch {
        errorMessage = "Failed to request authorization: \(error.localizedDescription)"
      }
      isRequesting = false
    }
  }
}

struct PermissionFeatureRow: View {
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundColor(.blue)
        .frame(width: 30)
      
      Text(text)
        .font(.system(size: 16))
        .foregroundColor(.white)
    }
  }
}

#Preview {
  ScreenTimeAuthView(onAuthorized: {})
}

