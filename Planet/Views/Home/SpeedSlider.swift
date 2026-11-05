//
//  SpeedSlider.swift
//  Planet
//
//  The speed control on the Solar System map: a slim slider with marks at a
//  day, a week, a month and a year per second that the thumb snaps to.
//

import SwiftUI

struct SpeedSlider: View {
    /// 0...1 along the track (log scale; see `MapSpeed`).
    @Binding var position: Double
    /// Shown above the thumb while dragging, and read by VoiceOver.
    let valueLabel: String
    /// Called once when the user starts changing the speed.
    var onBegin: () -> Void = {}

    @Environment(\.layoutDirection) private var layoutDirection
    @State private var isDragging = false

    /// How close (in track fraction) the thumb has to come to a mark to snap.
    private let snapZone = 0.035
    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 18
    private let controlHeight: CGFloat = 26

    private var marks: [MapSpeed.Preset] { MapSpeed.presets }

    var body: some View {
        let rtl = layoutDirection == .rightToLeft

        // Laid out left-to-right and flipped by hand for Persian (slow end
        // on the right), so the drag maths stays simple.
        GeometryReader { geo in
            let width = geo.size.width
            let x = { (p: Double) in CGFloat(rtl ? 1 - p : p) * width }
            let midY = controlHeight / 2

            ZStack(alignment: .topLeading) {
                // Track
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: width, height: trackHeight)
                    .position(x: width / 2, y: midY)

                // Fill from the slow end to the thumb
                let fillWidth = CGFloat(position) * width
                Capsule()
                    .fill(LinearGradient(colors: [.cyan.opacity(0.45), .cyan],
                                         startPoint: rtl ? .trailing : .leading,
                                         endPoint: rtl ? .leading : .trailing))
                    .frame(width: fillWidth, height: trackHeight)
                    .position(x: rtl ? width - fillWidth / 2 : fillWidth / 2, y: midY)

                // Marks and their names
                ForEach(marks) { mark in
                    let reached = position >= mark.position - 0.001
                    Circle()
                        .fill(reached ? Color.cyan : Color.white.opacity(0.45))
                        .frame(width: 6, height: 6)
                        .position(x: x(mark.position), y: midY)

                    Text(mark.name)
                        .font(AppFont.regular(9))
                        .foregroundColor(.white.opacity(isNear(mark) ? 0.95 : 0.5))
                        .fixedSize()
                        // The end labels hug the edges instead of
                        // hanging off the card.
                        .frame(width: 60, alignment: labelAlignment(for: mark, rtl: rtl))
                        .position(x: labelX(for: mark, x: x(mark.position), width: width, rtl: rtl),
                                  y: controlHeight + 6)
                }

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .shadow(color: .cyan.opacity(0.8), radius: isDragging ? 8 : 4)
                    .scaleEffect(isDragging ? 1.25 : 1)
                    .position(x: x(position), y: midY)

                // Live value above the thumb while dragging, where the
                // finger doesn't cover it.
                if isDragging {
                    Text(valueLabel)
                        .font(AppFont.bold(12))
                        .monospacedDigit()
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.cyan.opacity(0.85), in: Capsule())
                        .fixedSize()
                        .position(x: min(max(x(position), 30), width - 30), y: -16)
                        .transition(.opacity.combined(with: .scale(scale: 0.8, anchor: .bottom)))
                }
            }
            .frame(width: width, height: controlHeight + 14, alignment: .topLeading)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            onBegin()
                            withAnimation(.easeOut(duration: 0.15)) { isDragging = true }
                        }
                        var p = Double(min(max(value.location.x / max(width, 1), 0), 1))
                        if rtl { p = 1 - p }
                        update(to: snapped(p))
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) { isDragging = false }
                    }
            )
        }
        .frame(height: controlHeight + 14)
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement()
        .accessibilityLabel("Speed")
        .accessibilityValue(valueLabel)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: step(1)
            case .decrement: step(-1)
            @unknown default: break
            }
        }
    }

    // MARK: Behaviour

    private func snapped(_ p: Double) -> Double {
        marks.first { abs($0.position - p) < snapZone }?.position ?? p
    }

    /// Sets the position, with a tick of haptics on landing on a mark.
    private func update(to p: Double) {
        guard p != position else { return }
        let landedOnMark = marks.contains { $0.position == p }
        position = p
        if landedOnMark { playHaptic(.light) }
    }

    /// Moves to the next mark up or down.
    private func step(_ direction: Int) {
        onBegin()
        let target = direction > 0
            ? marks.first { $0.position > position + 0.001 }
            : marks.last { $0.position < position - 0.001 }
        guard let target else { return }
        withAnimation(.easeInOut(duration: 0.2)) { update(to: target.position) }
    }

    private func isNear(_ mark: MapSpeed.Preset) -> Bool {
        abs(mark.position - position) < 0.001
    }

    // MARK: Pieces

    private func labelAlignment(for mark: MapSpeed.Preset, rtl: Bool) -> Alignment {
        let atStart = mark.position == 0, atEnd = mark.position == 1
        if atStart { return rtl ? .trailing : .leading }
        if atEnd { return rtl ? .leading : .trailing }
        return .center
    }

    private func labelX(for mark: MapSpeed.Preset, x: CGFloat, width: CGFloat, rtl: Bool) -> CGFloat {
        // The 60pt label frame is centred on this point: shift the end ones
        // inwards so their text starts or ends at the track's edge.
        switch labelAlignment(for: mark, rtl: rtl) {
        case .leading: return x + 30
        case .trailing: return x - 30
        default: return x
        }
    }
}
