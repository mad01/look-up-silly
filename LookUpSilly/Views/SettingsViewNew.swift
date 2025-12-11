import SwiftUI
import FamilyControls

struct SettingsViewNew: View {
  @Environment(\.themeColors) private var colors
  @EnvironmentObject var appSettings: AppSettings
  @StateObject private var screenTimeManager = ScreenTimeManager.shared
  @StateObject private var revenueCat = RevenueCatManager.shared
  @StateObject private var statsManager = ChallengeStatsManager.shared
  @State private var showingResetAlert = false
  @State private var showingResetStatsAlert = false
  @State private var showingOnboardingAlert = false
  @State private var showingContributionSheet = false
  @State private var showingTestChallenges = false
  @State private var showingPauseDurationSheet = false
  @State private var showingBlockingScheduleSheet = false
  @State private var showingChallengeTypesSheet = false
  @State private var showingUnlockDurationSheet = false
  
  // Unlock duration stored in shared UserDefaults for extensions
  @State private var unlockDurationMinutes: Int = {
    let stored = UserDefaults.shared.integer(forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
    return stored > 0 ? stored : SharedConstants.defaultPauseDurationMinutes
  }()
  
  var body: some View {
    NavigationStack {
      ZStack {
        colors.background.ignoresSafeArea()
        
        List {
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.blockedApps,
              title: "Blocked Apps",
              subtitle: "Requires challenge to access"
            )
            .onChange(of: screenTimeManager.blockedApps) { _, newValue in
              screenTimeManager.setBlockedApps(newValue)
            }
          } header: {
            Text("App Management")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Tip: Use the search bar in the app picker to quickly find your installed apps. Empty categories can be ignored.")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            FamilyActivityPickerView(
              selection: $screenTimeManager.allowedApps,
              title: "Always Allowed",
              subtitle: "No challenge required"
            )
            .onChange(of: screenTimeManager.allowedApps) { _, newValue in
              screenTimeManager.setAllowedApps(newValue)
            }
          } header: {
            Text("Exceptions")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("These apps will bypass the challenge requirement")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Button(action: {
              showingPauseDurationSheet = true
            }) {
              HStack {
                Image(systemName: appSettings.challengesPaused ? "clock.fill" : "pause.circle.fill")
                  .foregroundColor(appSettings.challengesPaused ? colors.warning : colors.primary)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(appSettings.challengesPaused ? "Manage Pause" : "Pause Challenges")
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  if appSettings.challengesPaused {
                    if let endTime = UserDefaults.standard.object(forKey: "pauseEndTime") as? Date {
                      Text("Auto-resumes \(endTime, style: .relative)")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                    } else {
                      Text("Paused indefinitely")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)
                    }
                  } else {
                    Text("Challenges are active")
                      .font(.caption)
                      .foregroundColor(colors.textSecondary)
                  }
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ChallengesPausedStateChanged"))) { _ in
              // Update shields when state changes from quick action
              let isPaused = UserDefaults.standard.bool(forKey: "challengesPaused")
              handlePauseStateChange(isPaused)
            }
          } header: {
            Text("Challenge Status")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Temporarily pause all challenges without removing your blocked apps list")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Button {
              showingBlockingScheduleSheet = true
            } label: {
              HStack {
                Image(systemName: "calendar.badge.clock")
                  .foregroundColor(colors.secondary)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(NSLocalizedString("settings.schedule.row_title", comment: ""))
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text(NSLocalizedString("settings.schedule.row_subtitle", comment: ""))
                    .foregroundColor(colors.textSecondary)
                    .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            .buttonStyle(.plain)
          } header: {
            Text(NSLocalizedString("settings.schedule.section_title", comment: ""))
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text(NSLocalizedString("settings.schedule.section_footer", comment: ""))
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            Button {
              showingChallengeTypesSheet = true
            } label: {
              HStack {
                Image(systemName: "gamecontroller")
                  .foregroundColor(colors.secondary)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(NSLocalizedString("settings.challenge_types.row_title", comment: ""))
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text(NSLocalizedString("settings.challenge_types.row_subtitle", comment: ""))
                    .foregroundColor(colors.textSecondary)
                    .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            .buttonStyle(.plain)
          } header: {
            Text(NSLocalizedString("settings.challenge_types.section_title", comment: ""))
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text(NSLocalizedString("settings.challenge_types.section_footer", comment: ""))
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "xmark.circle")
                  .foregroundColor(colors.info)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(NSLocalizedString("settings.skip_button_delay", comment: ""))
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text(String(format: NSLocalizedString("settings.skip_button_delay_description", comment: ""), appSettings.challengeCancelDelaySeconds))
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
              }
              
              Picker("", selection: $appSettings.challengeCancelDelaySeconds) {
                Text("30").tag(30)
                Text("60").tag(60)
                Text("90").tag(90)
                Text("120").tag(120)
                Text("180").tag(180)
              }
              .pickerStyle(.segmented)
            }
            
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "timer")
                  .foregroundColor(colors.success)
                  .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 4) {
                  Text(NSLocalizedString("settings.unlock_duration.row_title", comment: ""))
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text(String(format: NSLocalizedString("settings.unlock_duration.minutes", comment: ""), unlockDurationMinutes))
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
              }
              
              Picker("", selection: $unlockDurationMinutes) {
                Text("3").tag(3)
                Text("5").tag(5)
                Text("10").tag(10)
                Text("15").tag(15)
                Text("30").tag(30)
              }
              .pickerStyle(.segmented)
              .onChange(of: unlockDurationMinutes) { _, newValue in
                UserDefaults.shared.set(newValue, forKey: SharedConstants.UserDefaultsKeys.pauseDurationMinutes)
              }
            }
          } header: {
            Text(NSLocalizedString("settings.challenge_settings.section_title", comment: ""))
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text(NSLocalizedString("settings.unlock_duration.description", comment: ""))
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            if revenueCat.hasContributed {
              HStack {
                Image(systemName: "heart.circle.fill")
                  .foregroundColor(colors.premium)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Thank You!")
                    .foregroundColor(colors.textPrimary)
                    .font(.headline)
                  Text("You've contributed \(revenueCat.contributionAmount ?? "to development")")
                    .foregroundColor(colors.textSecondary)
                    .font(.caption)
                }
                Spacer()
                Text(NSLocalizedString("contribution.badge", comment: ""))
                  .foregroundColor(colors.success)
                  .font(.caption.bold())
                  .padding(.horizontal, 10)
                  .padding(.vertical, 6)
                  .background(colors.success.opacity(0.15))
                  .clipShape(Capsule())
              }
            } else {
              Button(action: {
                showingContributionSheet = true
              }) {
                HStack {
                  Image(systemName: "heart.circle")
                    .foregroundColor(colors.premium)
                  VStack(alignment: .leading, spacing: 4) {
                    Text("Support Development")
                      .foregroundColor(colors.textPrimary)
                    Text("Help keep this app free")
                      .foregroundColor(colors.textSecondary)
                      .font(.caption)
                  }
                  Spacer()
                  Image(systemName: "chevron.right")
                    .foregroundColor(colors.textSecondary)
                }
              }
            }
          } header: {
            Text("Contribution")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Look Up, Silly! is free with no ads. Your contribution helps us continue development.")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "info.circle")
                  .foregroundColor(colors.info)
                Text("How It Works")
                  .foregroundColor(colors.textPrimary)
                  .font(.headline)
              }
              
              VStack(alignment: .leading, spacing: 12) {
                InfoRow(
                  number: "1",
                  text: "Blocked apps show a shield with \"Open Challenge\" button"
                )
                InfoRow(
                  number: "2",
                  text: "Tap the button to open Look Up, Silly! and complete a challenge"
                )
                InfoRow(
                  number: "3",
                  text: "All blocked apps unlock for \(unlockDurationMinutes) minutes"
                )
                InfoRow(
                  number: "4",
                  text: "After \(unlockDurationMinutes) minutes, protection reactivates"
                )
              }
              .foregroundColor(colors.textSecondary)
              .font(.caption)
            }
          }
          .listRowBackground(colors.surface)
          
          Section {
            // Stats Display
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Image(systemName: "chart.bar.fill")
                  .foregroundColor(colors.success)
                Text("Total Challenges Completed")
                  .foregroundColor(colors.textPrimary)
                Spacer()
                Text("\(statsManager.totalChallengesCompleted)")
                  .font(.title2.bold())
                  .foregroundColor(colors.success)
              }
              
              Divider()
                .background(colors.divider)
              
              HStack {
                Image(systemName: "function")
                  .foregroundColor(colors.mathChallenge)
                Text(ChallengeType.math.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.mathChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: "square.grid.3x3.fill")
                  .foregroundColor(colors.ticTacToe)
                Text(ChallengeType.ticTacToe.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.ticTacToeChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: "square.grid.4x3.fill")
                  .foregroundColor(colors.micro2048)
                Text(ChallengeType.micro2048.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.micro2048ChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: ChallengeType.colorTap.icon)
                  .foregroundColor(colors.colorTap)
                Text(ChallengeType.colorTap.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.colorTapChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              HStack {
                Image(systemName: ChallengeType.pathRecall.icon)
                  .foregroundColor(colors.pathRecall)
                Text(ChallengeType.pathRecall.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.pathRecallChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }

              HStack {
                Image(systemName: ChallengeType.gravityDrop.icon)
                  .foregroundColor(colors.gravityDrop)
                Text(ChallengeType.gravityDrop.title)
                  .foregroundColor(colors.textSecondary)
                Spacer()
                Text("\(statsManager.gravityDropChallengesCompleted)")
                  .foregroundColor(colors.textPrimary)
              }
              
              if let lastSync = statsManager.lastSyncDate {
                Divider()
                  .background(colors.divider)
                
                HStack {
                  Image(systemName: "icloud.fill")
                    .foregroundColor(colors.info)
                  Text("Last iCloud Sync")
                    .foregroundColor(colors.textSecondary)
                  Spacer()
                  Text(lastSync, style: .relative)
                    .foregroundColor(colors.textPrimary)
                    .font(.caption)
                }
              }
            }
          } header: {
            Text("Statistics")
              .foregroundColor(colors.textPrimary)
          } footer: {
            Text("Your challenge completion stats sync across all your devices via iCloud")
              .foregroundColor(colors.textSecondary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            HStack {
              Text(NSLocalizedString("settings.version", comment: ""))
                .foregroundColor(colors.textPrimary)
              Spacer()
              Text("1.0.0")
                .foregroundColor(colors.textSecondary)
            }
            
            Link(destination: URL(string: "https://dropbrain.io/lookupsilly/privacy_policy.html")!) {
              HStack {
                Text(NSLocalizedString("settings.privacy_policy", comment: ""))
                  .foregroundColor(colors.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
              HStack {
                Text(NSLocalizedString("settings.terms_of_service", comment: ""))
                  .foregroundColor(colors.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.right")
                  .font(.caption)
                  .foregroundColor(colors.textSecondary)
              }
            }
          } header: {
            Text(NSLocalizedString("settings.about", comment: ""))
              .foregroundColor(colors.textPrimary)
          }
          .listRowBackground(colors.surface)
          
          Section {
            #if DEBUG
            Button(action: {
              showingTestChallenges = true
            }) {
              HStack {
                Image(systemName: "hammer.circle")
                  .foregroundColor(colors.secondary)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Test Challenges")
                    .foregroundColor(colors.textPrimary)
                  Text("Development")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Button(action: {
              showingResetStatsAlert = true
            }) {
              HStack {
                Image(systemName: "chart.bar.xaxis")
                  .foregroundColor(colors.warning)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Reset Statistics")
                    .foregroundColor(colors.textPrimary)
                  Text("Development")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Toggle(isOn: Binding(
              get: { revenueCat.hasContributed },
              set: { newValue in
                UserDefaults.standard.set(newValue, forKey: "hasContributed")
                if newValue {
                  UserDefaults.standard.set("$0 (Test)", forKey: "contributionAmount")
                } else {
                  UserDefaults.standard.removeObject(forKey: "contributionAmount")
                }
                Task { await revenueCat.refreshContributionStatus() }
              }
            )) {
              HStack {
                Image(systemName: "creditcard.circle")
                  .foregroundColor(colors.success)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Manual Contribution Toggle")
                    .foregroundColor(colors.textPrimary)
                  Text("Testing Only")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
              }
            }
            .tint(colors.success)
            #endif
            
            Button(action: {
              showingOnboardingAlert = true
            }) {
              HStack {
                Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                  .foregroundColor(colors.info)
                VStack(alignment: .leading, spacing: 4) {
                  Text(NSLocalizedString("settings.rerun_onboarding.title", comment: ""))
                    .foregroundColor(colors.textPrimary)
                  Text(NSLocalizedString("settings.rerun_onboarding.subtitle", comment: ""))
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
            
            Button(action: {
              showingResetAlert = true
            }) {
              HStack {
                Image(systemName: "arrow.counterclockwise")
                  .foregroundColor(colors.danger)
                VStack(alignment: .leading, spacing: 4) {
                  Text("Reset App & Start Over")
                    .foregroundColor(colors.textPrimary)
                  Text("Clear all settings and blocks")
                    .font(.caption)
                    .foregroundColor(colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .foregroundColor(colors.textSecondary)
              }
            }
          } header: {
            #if DEBUG
            Text("Development & Actions")
              .foregroundColor(colors.textPrimary)
            #else
            Text("Actions")
              .foregroundColor(colors.textPrimary)
            #endif
          }
          .listRowBackground(colors.surface)
        }
        .scrollContentBackground(.hidden)
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
      .sheet(isPresented: $showingContributionSheet) {
        ContributionView(onComplete: {
          showingContributionSheet = false
        })
      }
      .sheet(isPresented: $showingTestChallenges) {
        ChallengeTestView(isDevelopment: true)
          .environmentObject(appSettings)
      }
      .overlay {
        if showingPauseDurationSheet {
          PauseDurationSheet(isPresented: $showingPauseDurationSheet)
            .environmentObject(appSettings)
            .transition(.opacity)
        }
      }
      .alert("Reset App?", isPresented: $showingResetAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Reset", role: .destructive) {
          screenTimeManager.removeAllShields()
          appSettings.hasCompletedOnboarding = false
          appSettings.allowedApps.removeAll()
          appSettings.saveAllowedApps()
        }
      } message: {
        Text("This will remove all app blocks and reset the app. You'll need to go through onboarding again.")
      }
      .alert("Reset Statistics?", isPresented: $showingResetStatsAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Reset", role: .destructive) {
          statsManager.resetStats()
        }
      } message: {
        Text("This will reset all your challenge completion statistics and remove them from iCloud.")
      }
      .alert(NSLocalizedString("settings.rerun_onboarding.alert.title", comment: ""), isPresented: $showingOnboardingAlert) {
        Button("Cancel", role: .cancel) {}
        Button(NSLocalizedString("settings.rerun_onboarding.alert.confirm", comment: ""), role: .none) {
          // Just reset onboarding flag - keep all other settings
          appSettings.hasCompletedOnboarding = false
        }
      } message: {
        Text(NSLocalizedString("settings.rerun_onboarding.alert.message", comment: ""))
      }
    }
    .sheet(isPresented: $showingBlockingScheduleSheet) {
      NavigationStack {
        BlockingScheduleView()
          .environmentObject(appSettings)
      }
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
    .sheet(isPresented: $showingChallengeTypesSheet) {
      NavigationStack {
        ChallengeTypeSettingsView(
          enabledTypes: Binding(
            get: { appSettings.enabledChallengeTypes },
            set: { appSettings.setEnabledChallengeTypes($0) }
          )
        )
      }
      .presentationDetents([.large])
      .presentationDragIndicator(.visible)
    }
  }
  
  private func handlePauseStateChange(_ isPaused: Bool) {
    if isPaused {
      screenTimeManager.removeAllShields()
    } else {
      screenTimeManager.updateShielding()
    }
    
    // Update home screen quick actions
    NotificationCenter.default.post(name: NSNotification.Name("UpdateQuickActions"), object: nil)
  }
}

struct InfoRow: View {
  @Environment(\.themeColors) private var colors
  let number: String
  let text: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Text(number)
        .font(.caption.bold())
        .foregroundColor(colors.textOnAccent)
        .frame(width: 20, height: 20)
        .background(colors.primary)
        .clipShape(Circle())
      
      Text(text)
        .foregroundColor(colors.textSecondary)
    }
  }
}

struct ChallengeTypeSettingsView: View {
  @Environment(\.themeColors) private var colors
  @Environment(\.dismiss) private var dismiss
  @Binding var enabledTypes: Set<ChallengeType>
  
  var body: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 8) {
          Text(NSLocalizedString("settings.challenge_types.description", comment: ""))
            .foregroundColor(colors.textPrimary)
          Text(NSLocalizedString("settings.challenge_types.note", comment: ""))
            .foregroundColor(colors.textSecondary)
            .font(.caption)
        }
      }
      .listRowBackground(colors.surface)
      
      Section {
        ForEach(ChallengeType.allCases, id: \.self) { type in
          Toggle(isOn: binding(for: type)) {
            VStack(alignment: .leading, spacing: 2) {
              Text(type.title)
                .foregroundColor(colors.textPrimary)
              Text(type.description)
                .font(.caption)
                .foregroundColor(colors.textSecondary)
            }
          }
        }
      } footer: {
        Text(NSLocalizedString("settings.challenge_types.fallback", comment: ""))
          .foregroundColor(colors.textSecondary)
      }
      .listRowBackground(colors.surface)
    }
    .scrollContentBackground(.hidden)
    .background(colors.background.ignoresSafeArea())
    .navigationTitle(NSLocalizedString("settings.challenge_types.title", comment: ""))
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
  }
  
  private func binding(for type: ChallengeType) -> Binding<Bool> {
    Binding(
      get: { enabledTypes.contains(type) },
      set: { isOn in
        var updated = enabledTypes
        if isOn {
          updated.insert(type)
        } else {
          updated.remove(type)
        }
        enabledTypes = updated
      }
    )
  }
}

#Preview {
  SettingsViewNew()
    .environmentObject(AppSettings())
}

