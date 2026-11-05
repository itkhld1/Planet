//
//  MissionComponents.swift
//  Planet
//
//  Pieces shared by Mission Builder and Mission Control.
//

import SwiftUI

/// The cheapest ↔ fastest route slider.
struct RouteSpeedCard: View {
    @Binding var speed: Double
    /// A tap of feedback when the slider reaches either end.
    var hapticAtEnds = false

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Route")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Spacer()
                Text(speed == 0 ? "Cheapest (Hohmann)" : speed == 1 ? "Fastest" : "Faster, more fuel")
                    .font(AppFont.bold(isPhone ? 13 : 18))
                    .foregroundColor(speed == 0 ? Palette.success : Palette.warning)
            }

            Slider(value: $speed, in: 0...1) {
                Text("Route")
            } minimumValueLabel: {
                Image(systemName: "fuelpump.fill")
                    .foregroundColor(Palette.secondaryText)
                    .accessibilityLabel(Text("Cheapest"))
            } maximumValueLabel: {
                Image(systemName: "hare.fill")
                    .foregroundColor(Palette.secondaryText)
                    .accessibilityLabel(Text("Fastest"))
            }
            .tint(Palette.accent)
            .onChange(of: speed == 0 || speed == 1) { _, atEnd in
                if hapticAtEnds && atEnd { playHaptic(.light) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard()
        // The slider runs cheap → fast left to right in every language,
        // matching the fuel / hare icons at each end.
        .environment(\.layoutDirection, .leftToRight)
    }
}

/// The player's spacecraft and crew size, with an "Edit" affordance. The
/// caller wraps it in a link to `SpacecraftView` and adds the padding.
struct SpacecraftSummaryRow: View {
    private var progress: ProgressStore { .shared }

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        HStack(spacing: 12) {
            SpacecraftBadge(colorIndex: progress.spacecraftColor, iconIndex: progress.spacecraftIcon, size: isPhone ? 34 : 46)
            VStack(alignment: .leading, spacing: 2) {
                Text(progress.spacecraftDisplayName)
                    .font(AppFont.bold(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                Text("Crew of \(1 + progress.crew.count)")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(Palette.secondaryText)
            }
            Spacer(minLength: 8)
            Text("Edit")
                .font(AppFont.bold(isPhone ? 14 : 20))
                .foregroundColor(Palette.accent)
            Image(systemName: "chevron.forward")
                .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                .foregroundColor(Palette.secondaryText)
        }
        .contentShape(Rectangle())
    }
}
