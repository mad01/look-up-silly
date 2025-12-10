import SwiftUI
import FamilyControls
import Charts

struct HomeViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
  @State private var showingPlayForFun = false
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 30) {
            // Header with Stats
            VStack(spacing: 16) {
              Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
              
              Text("Look Up, Silly!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colors.textPrimary)
              
              // Times Saved Chart
              TimesSavedChartView(statsManager: statsManager)
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)
            
            // Status Card
            StatusCard(
              blockedCount: screenTimeManager.blockedApps.applicationTokens.count,
              allowedCount: screenTimeManager.allowedApps.applicationTokens.count
            )
            
            // Play for Fun Section
            VStack(alignment: .leading, spacing: 16) {
              Text("Practice")
                .font(.title2.bold())
                .foregroundColor(colors.textPrimary)
                .padding(.horizontal, 20)
              
              Button(action: {
                showingPlayForFun = true
              }) {
                HStack {
                  Image(systemName: "gamecontroller.fill")
                    .font(.title2)
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text("Play Challenges for Fun")
                      .font(.headline)
                    Text("Practice anytime, no unlock needed")
                      .font(.caption)
                      .foregroundColor(colors.textSecondary)
                  }
                  
                  Spacer()
                  
                  Image(systemName: "chevron.right")
                    .foregroundColor(colors.textSecondary)
                }
                .foregroundColor(colors.textPrimary)
                .padding()
                .background(colors.secondary.opacity(0.2))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(colors.secondary, lineWidth: 2)
                )
              }
              .padding(.horizontal, 20)
            }
          }
          .padding(.bottom, 30)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(isPresented: $showingPlayForFun) {
        ChallengeTestView(isDevelopment: false)
          .environmentObject(appSettings)
      }
    }
  }
}

struct TimesSavedChartView: View {
  @Environment(\.themeColors) private var colors
  @ObservedObject var statsManager: ChallengeStatsManager
  @State private var selectedDays: Int = 7
  
  private let availableRanges = [7, 14, 30]
  
  private var triggeredData: [ChartDataPoint] {
    statsManager.getChartDataPoints(for: selectedDays, series: .triggered)
  }
  
  private var continuedData: [ChartDataPoint] {
    statsManager.getChartDataPoints(for: selectedDays, series: .continued)
  }
  
  private var maxY: Int {
    let maxTriggered = triggeredData.map { $0.cumulativeCount }.max() ?? 0
    let maxContinued = continuedData.map { $0.cumulativeCount }.max() ?? 0
    return max(max(maxTriggered, maxContinued), 5)
  }
  
  var body: some View {
    VStack(spacing: 12) {
      // Header with total count
      ViewThatFits(in: .horizontal) {
        HStack(alignment: .top, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
              Image(systemName: "checkmark.shield.fill")
                .font(.title3)
                .foregroundColor(colors.success)
              
              Text("\(statsManager.totalChallengesContinued)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(colors.success)
                .contentTransition(.numericText())
              
              Text(NSLocalizedString("home.times_saved", comment: ""))
                .font(.headline)
                .foregroundColor(colors.textPrimary)
            }
            
            Text(NSLocalizedString("home.times_saved_subtitle", comment: ""))
              .font(.caption)
              .foregroundColor(colors.textSecondary)
          }
          
          Spacer()
          
          Picker("Range", selection: $selectedDays) {
            ForEach(availableRanges, id: \.self) { days in
              Text(String(format: NSLocalizedString("home.days_range_option", comment: ""), days))
                .tag(days)
            }
          }
          .pickerStyle(.segmented)
          .frame(maxWidth: 220)
        }
        
        VStack(alignment: .leading, spacing: 12) {
          VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
              Image(systemName: "checkmark.shield.fill")
                .font(.title3)
                .foregroundColor(colors.success)
              
              Text("\(statsManager.totalChallengesContinued)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(colors.success)
                .contentTransition(.numericText())
            }
            
            Text(NSLocalizedString("home.times_saved", comment: ""))
              .font(.headline)
              .foregroundColor(colors.textPrimary)
            
            Text(NSLocalizedString("home.times_saved_subtitle", comment: ""))
              .font(.caption)
              .foregroundColor(colors.textSecondary)
          }
          
          Picker("Range", selection: $selectedDays) {
            ForEach(availableRanges, id: \.self) { days in
              Text(String(format: NSLocalizedString("home.days_range_option", comment: ""), days))
                .tag(days)
            }
          }
          .pickerStyle(.segmented)
        }
      }
      
      // Line Chart
      Chart {
        ForEach(triggeredData) { point in
          LineMark(
            x: .value("Date", point.date),
            y: .value("Triggered", point.cumulativeCount)
          )
          .foregroundStyle(colors.success)
          .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round, dash: [4]))
          .interpolationMethod(.monotone)
          
          PointMark(
            x: .value("Date", point.date),
            y: .value("Triggered", point.cumulativeCount)
          )
          .foregroundStyle(colors.success)
          .symbolSize(20)
        }
        
        ForEach(continuedData) { point in
          LineMark(
            x: .value("Date", point.date),
            y: .value("Continued", point.cumulativeCount)
          )
          .foregroundStyle(colors.error.gradient)
          .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
          .interpolationMethod(.monotone)
          
          PointMark(
            x: .value("Date", point.date),
            y: .value("Continued", point.cumulativeCount)
          )
          .foregroundStyle(colors.error)
          .symbolSize(24)
        }
      }
      .chartYScale(domain: 0...maxY)
      .chartXAxis {
        AxisMarks(values: .stride(by: .day, count: 2)) { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            .foregroundStyle(colors.textSecondary.opacity(0.2))
          AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            .foregroundStyle(colors.textSecondary)
        }
      }
      .chartYAxis {
        AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
          AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            .foregroundStyle(colors.textSecondary.opacity(0.2))
          AxisValueLabel()
            .foregroundStyle(colors.textSecondary)
        }
      }
      .frame(height: 140)
      
      HStack(spacing: 12) {
        LegendDot(color: colors.success, label: NSLocalizedString("home.times_saved_triggered", comment: ""))
        LegendDot(color: colors.error, label: NSLocalizedString("home.times_saved_continued", comment: ""))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      
      // Footer label
      Text(String(format: NSLocalizedString("home.last_x_days", comment: ""), selectedDays))
        .font(.caption2)
        .foregroundColor(colors.textSecondary)
    }
    .padding()
    .background(colors.success.opacity(0.15))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(colors.success.opacity(0.3), lineWidth: 1)
    )
  }
}

struct StatusCard: View {
  @Environment(\.themeColors) private var colors
  let blockedCount: Int
  let allowedCount: Int
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        VStack(alignment: .leading) {
          Text("Protection Active")
            .font(.headline)
            .foregroundColor(colors.textPrimary)
          Text("\(blockedCount) apps blocked")
            .font(.caption)
            .foregroundColor(colors.textSecondary)
        }
        
        Spacer()
        
        Image(systemName: "shield.checkered")
          .font(.system(size: 40))
          .foregroundStyle(colors.success.gradient)
      }
    }
    .padding()
    .background(colors.success.opacity(0.15))
    .cornerRadius(12)
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(colors.success.opacity(0.3), lineWidth: 1)
    )
    .padding(.horizontal, 20)
  }
}

private struct LegendDot: View {
  let color: Color
  let label: String
  
  var body: some View {
    HStack(spacing: 6) {
      Circle()
        .fill(color)
        .frame(width: 10, height: 10)
      Text(label)
        .font(.caption)
        .foregroundColor(.primary)
    }
  }
}

#Preview {
  HomeViewNew()
    .environmentObject(AppSettings())
}

