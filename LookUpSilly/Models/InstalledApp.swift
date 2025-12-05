import Foundation

struct InstalledApp: Identifiable, Hashable {
  let id = UUID()
  let bundleId: String
  let name: String
  let icon: String // SF Symbol name
  
  // Common apps for demo purposes
  static let commonApps: [InstalledApp] = [
    InstalledApp(bundleId: "com.apple.mobilesafari", name: "Safari", icon: "safari"),
    InstalledApp(bundleId: "com.instagram.app", name: "Instagram", icon: "camera.circle.fill"),
    InstalledApp(bundleId: "com.twitter.app", name: "X (Twitter)", icon: "bird.circle.fill"),
    InstalledApp(bundleId: "com.facebook.app", name: "Facebook", icon: "f.circle.fill"),
    InstalledApp(bundleId: "com.reddit.app", name: "Reddit", icon: "message.circle.fill"),
    InstalledApp(bundleId: "com.tiktok.app", name: "TikTok", icon: "music.note.circle.fill"),
    InstalledApp(bundleId: "com.youtube.app", name: "YouTube", icon: "play.circle.fill"),
    InstalledApp(bundleId: "com.snapchat.app", name: "Snapchat", icon: "camera.filters"),
    InstalledApp(bundleId: "com.whatsapp.app", name: "WhatsApp", icon: "message.fill"),
    InstalledApp(bundleId: "com.telegram.app", name: "Telegram", icon: "paperplane.fill"),
  ]
}

