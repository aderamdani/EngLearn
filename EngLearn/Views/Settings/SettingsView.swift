import SwiftUI
import os

struct SettingsView: View {
    @AppStorage("dailyGoalMinutes") private var dailyGoal = 10
    @AppStorage("nativeLanguage") private var nativeLanguage = "id"
    @AppStorage("ttsVoice") private var ttsVoice = "en-GB"
    @AppStorage("ttsRate") private var ttsRate = AppConstants.Limits.ttsNormalRate
    @AppStorage("soundEffectsEnabled") private var soundEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderHour") private var reminderHour = 9

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("Umum", systemImage: "gearshape") }

            audioTab
                .tabItem { Label("Audio", systemImage: "speaker.wave.2") }

            notificationTab
                .tabItem { Label("Notifikasi", systemImage: "bell") }

            aboutTab
                .tabItem { Label("Tentang", systemImage: "info.circle") }
        }
        .frame(width: 450, height: 350)
    }

    private var generalTab: some View {
        Form {
            Section(String(localized: "Target Harian", comment: "Settings section")) {
                Picker(String(localized: "Durasi belajar", comment: "Daily goal picker"), selection: $dailyGoal) {
                    Text("5 menit").tag(5)
                    Text("10 menit").tag(10)
                    Text("15 menit").tag(15)
                    Text("20 menit").tag(20)
                    Text("30 menit").tag(30)
                }
            }

            #if DEBUG
            debugSection
            #endif
        }
        .formStyle(.grouped)
    }

    private var audioTab: some View {
        Form {
            Section("Text-to-Speech") {
                Picker(String(localized: "Aksen", comment: "TTS voice picker"), selection: $ttsVoice) {
                    Text("British English").tag("en-GB")
                    Text("American English").tag("en-US")
                    Text("Australian English").tag("en-AU")
                }

                Picker(String(localized: "Kecepatan bicara", comment: "TTS rate picker"), selection: $ttsRate) {
                    Text(String(localized: "Lambat", comment: "TTS slow")).tag(AppConstants.Limits.ttsSlowRate)
                    Text(String(localized: "Normal", comment: "TTS normal")).tag(AppConstants.Limits.ttsNormalRate)
                    Text(String(localized: "Cepat", comment: "TTS fast")).tag(AppConstants.Limits.ttsFastRate)
                }
            }

            Section(String(localized: "Efek Suara", comment: "Sound effects section")) {
                Toggle(
                    String(localized: "Aktifkan efek suara", comment: "Sound toggle"),
                    isOn: $soundEnabled
                )
            }
        }
        .formStyle(.grouped)
    }

    private var notificationTab: some View {
        Form {
            Section(String(localized: "Pengingat", comment: "Reminders section")) {
                Toggle(
                    String(localized: "Pengingat harian", comment: "Daily reminder toggle"),
                    isOn: $notificationsEnabled
                )

                if notificationsEnabled {
                    Picker(String(localized: "Jam pengingat", comment: "Reminder hour"), selection: $reminderHour) {
                        ForEach(6..<22) { hour in
                            Text("\(hour):00").tag(hour)
                        }
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    private var aboutTab: some View {
        Form {
            Section {
                LabeledContent(AppConstants.appName) {
                    Text("v\(appVersion) (\(buildNumber))")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Platform") {
                    Text("macOS 26+ (Apple Silicon)")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Developer") {
                    Text("Ade Ramdani")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }

    #if DEBUG
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    private var debugSection: some View {
        Section("Debug") {
            Button("Reset Onboarding") {
                hasCompletedOnboarding = false
                Log.general.info("Debug: onboarding reset")
            }
            Button("Clear All Data") {
                Log.general.info("Debug: clear all data requested")
            }
            Button("Fill Sample Data") {
                Log.general.info("Debug: fill sample data requested")
            }
        }
    }
    #endif
}

#Preview {
    SettingsView()
}
