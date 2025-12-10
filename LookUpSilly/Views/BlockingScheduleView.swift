import SwiftUI

struct BlockingScheduleView: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @Environment(\.dismiss) private var dismiss
  @State private var currentHour = Calendar.current.component(.hour, from: Date())
  
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
  
  var body: some View {
    List {
      Section {
        Text(NSLocalizedString("settings.schedule.description", comment: ""))
          .foregroundColor(colors.textPrimary)
      } footer: {
        Text(NSLocalizedString("settings.schedule.footer", comment: ""))
          .foregroundColor(colors.textSecondary)
      }
      .listRowBackground(colors.surface)
      
      Section {
        Picker("", selection: $appSettings.use24HourClock) {
          Text(NSLocalizedString("settings.schedule.format.24h", comment: "")).tag(true)
          Text(NSLocalizedString("settings.schedule.format.ampm", comment: "")).tag(false)
        }
        .pickerStyle(.segmented)
      } header: {
        Text(NSLocalizedString("settings.schedule.format_title", comment: ""))
          .foregroundColor(colors.textPrimary)
      }
      .listRowBackground(colors.surface)
      
      Section {
        LazyVGrid(columns: columns, spacing: 12) {
          ForEach(0..<24, id: \.self) { hour in
            hourButton(hour)
          }
        }
        .padding(.vertical, 4)
      } header: {
        Text(NSLocalizedString("settings.schedule.grid_title", comment: ""))
          .foregroundColor(colors.textPrimary)
      } footer: {
        Text(NSLocalizedString("settings.schedule.grid_footer", comment: ""))
          .foregroundColor(colors.textSecondary)
      }
      .listRowBackground(colors.surface)
    }
    .scrollContentBackground(.hidden)
    .background(colors.background.ignoresSafeArea())
    .navigationTitle(NSLocalizedString("settings.schedule.title", comment: ""))
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark")
            .font(.system(size: 16, weight: .bold))
        }
        .accessibilityLabel(Text(NSLocalizedString("common.close", comment: "")))
      }
    }
    .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
      currentHour = Calendar.current.component(.hour, from: Date())
    }
  }
  
  private func hourButton(_ hour: Int) -> some View {
    let isActive = appSettings.activeBlockingHours.contains(hour)
    let isCurrentHour = hour == currentHour
    
    return Button {
      toggleHour(hour)
    } label: {
      VStack(spacing: 6) {
        Text(hourLabel(for: hour))
          .foregroundColor(colors.textPrimary)
          .font(.headline)
          .frame(maxWidth: .infinity)
        Text(isActive
             ? NSLocalizedString("settings.schedule.active", comment: "")
             : NSLocalizedString("settings.schedule.inactive", comment: ""))
        .font(.caption)
        .foregroundColor(colors.textSecondary)
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 8)
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(isActive ? colors.primary.opacity(0.18) : colors.surface)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isCurrentHour ? colors.primary : colors.divider, lineWidth: isCurrentHour ? 2 : 1)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(hourLabel(for: hour)), \(isActive ? NSLocalizedString("settings.schedule.active", comment: "") : NSLocalizedString("settings.schedule.inactive", comment: ""))")
  }
  
  private func toggleHour(_ hour: Int) {
    let newState = !appSettings.activeBlockingHours.contains(hour)
    appSettings.setBlockingHour(hour, isActive: newState)
    ScreenTimeManager.shared.updateShielding()
  }
  
  private func hourLabel(for hour: Int) -> String {
    if appSettings.use24HourClock {
      return String(format: "%02d:00", hour)
    }
    
    let dateComponents = DateComponents(calendar: Calendar.current, hour: hour)
    if let date = dateComponents.date {
      let formatter = DateFormatter()
      formatter.dateFormat = "h a"
      return formatter.string(from: date)
    }
    
    return "\(hour)"
  }
}
