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
  
  private var chartData: [ChartDataPoint] {
    statsManager.getChartDataPoints(for: 7)
  }
  
  private var maxY: Int {
    max(chartData.map { $0.cumulativeCount }.max() ?? 0, 5)
  }
  
  var body: some View {
    VStack(spacing: 12) {
      // Header with total count
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 6) {
            Image(systemName: "checkmark.shield.fill")
              .font(.title3)
              .foregroundColor(colors.success)
            
            Text("\(statsManager.totalChallengesCompleted)")
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
      }
      
      // Line Chart
      Chart(chartData) { point in
        LineMark(
          x: .value("Date", point.date),
          y: .value("Times Saved", point.cumulativeCount)
        )
        .foregroundStyle(colors.success.gradient)
        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        .interpolationMethod(.monotone)
        
        AreaMark(
          x: .value("Date", point.date),
          y: .value("Times Saved", point.cumulativeCount)
        )
        .foregroundStyle(
          LinearGradient(
            colors: [colors.success.opacity(0.3), colors.success.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .interpolationMethod(.monotone)
        
        PointMark(
          x: .value("Date", point.date),
          y: .value("Times Saved", point.cumulativeCount)
        )
        .foregroundStyle(colors.success)
        .symbolSize(30)
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
      
      // Footer label
      Text(NSLocalizedString("home.last_7_days", comment: ""))
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

#Preview {
  HomeViewNew()
    .environmentObject(AppSettings())
}

