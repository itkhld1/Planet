//
//  SettingsView.swift
//  Planet
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.weightUnit) private var weightUnitRaw = WeightUnit.kilograms.rawValue
    @AppStorage(SettingsKey.hapticsEnabled) private var hapticsEnabled = true
    @AppStorage(SettingsKey.hasSeenInstruction) private var hasSeenInstruction = false
    @AppStorage(SettingsKey.highScore) private var highScore = 0
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system.rawValue

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var showResetScoreAlert = false

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        // Built as a String, so `Text(appVersion)` would render it verbatim —
        // the lookup has to happen here.
        return String(format: String(localized: "Version %@", bundle: Bundle.appLanguage), version)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                StarFieldView(count: 40)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        languageCard
                        unitsCard
                        feedbackCard
                        quizCard
                        aboutCard

                        Text(appVersion)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 6)
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .alert("Reset High Score?", isPresented: $showResetScoreAlert) {
            Button("Reset", role: .destructive) {
                highScore = 0
                playNotificationHaptic(.success)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your best quiz score of \(highScore) will be cleared. This can't be undone.")
        }
    }

    // MARK: - Cards

    private var unitsCard: some View {
        card(title: "Units", icon: "scalemass.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Weight")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white.opacity(0.7))

                Picker("Weight unit", selection: $weightUnitRaw) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.displayName).tag(unit.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Text("Used by the weight calculator.")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    private var feedbackCard: some View {
        card(title: "Feedback", icon: "hand.tap.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $hapticsEnabled) {
                    Text("Haptics")
                        .font(AppFont.regular(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                }
                .tint(.blue)
                .onChange(of: hapticsEnabled) { _, enabled in
                    // Confirm the new setting using the setting itself.
                    if enabled { playHaptic() }
                }

                Text("Vibrate when you tap planets, answers and buttons.")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    private var quizCard: some View {
        card(title: "Quiz", icon: "brain.head.profile.fill") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("High score")
                        .font(AppFont.regular(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(highScore) / 10")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.yellow)
                }
                .accessibilityElement(children: .combine)

                Button {
                    playHaptic()
                    showResetScoreAlert = true
                } label: {
                    Label("Reset high score", systemImage: "arrow.counterclockwise")
                        .font(AppFont.regular(isPhone ? 14 : 20))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(highScore == 0 ? .white.opacity(0.4) : .white)
                        .cornerRadius(14)
                }
                .disabled(highScore == 0)
            }
        }
    }

    /// Switches the app's language in place — no trip to iOS Settings.
    private var languageCard: some View {
        card(title: "Language", icon: "globe") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Language", selection: $language) {
                    ForEach(AppLanguage.allCases) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Text("Changes the whole app right away.")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    private var aboutCard: some View {
        card(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 10) {
                NavigationLink {
                    UserGuideView()
                        .navigationTitle("How to use")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    rowLabel("How to use the app", icon: "book.fill")
                }

                Button(action: replayIntro) {
                    rowLabel("Show the intro again", icon: "sparkles")
                }

                // Hidden until the App ID exists, so the link can't dead-end.
                if let reviewURL = AppStoreLink.reviewURL {
                    Button {
                        playHaptic()
                        openURL(reviewURL)
                    } label: {
                        rowLabel("Rate this app", icon: "star.fill")
                    }
                }

                if let shareURL = AppStoreLink.shareURL {
                    ShareLink(item: shareURL) {
                        rowLabel("Share with a friend", icon: "square.and.arrow.up")
                    }
                }
            }
        }
    }

    /// Dismisses this sheet before clearing the flag, so the walkthrough isn't
    /// swapped in underneath a sheet that's still on screen.
    private func replayIntro() {
        playHaptic()
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            hasSeenInstruction = false
        }
    }

    // MARK: - Building blocks

    private func card<Content: View>(title: LocalizedStringKey, icon: String,
                                     @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.28))
        .cornerRadius(18)
    }

    private func rowLabel(_ text: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 22)
            Text(text)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .font(AppFont.regular(isPhone ? 15 : 21))
        .foregroundColor(.white)
        .padding(.vertical, 11)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
    }
}

#Preview {
    SettingsView()
}
