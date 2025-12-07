import SwiftUI

struct StartupView: View {
  @Environment(\.themeColors) private var colors
  @State private var scale: CGFloat = 0.8
  @State private var opacity: Double = 0
  
  var body: some View {
    ZStack {
      colors.background.ignoresSafeArea()
      
      VStack(spacing: 20) {
        // App Logo
        Image("AppLogo")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 120, height: 120)
          .scaleEffect(scale)
          .opacity(opacity)
        
        Text("Look Up, Silly!")
          .font(.system(size: 32, weight: .bold, design: .rounded))
          .foregroundColor(colors.textPrimary)
          .opacity(opacity)
        
        Text("Break free from doomscrolling")
          .font(.system(size: 16, weight: .regular))
          .foregroundColor(colors.textSecondary)
          .opacity(opacity)
          .multilineTextAlignment(.center)
      }
      .padding()
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.6)) {
        scale = 1.0
        opacity = 1.0
      }
    }
  }
}

#Preview {
  StartupView()
}

