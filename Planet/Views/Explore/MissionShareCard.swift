//
//  MissionShareCard.swift
//  Planet
//
//  A one-image summary of a planned mission — the orbit diagram plus the key
//  numbers — that Mission Builder can share as a PNG.
//

import SwiftUI
import UniformTypeIdentifiers

/// Everything the card shows, already worked out by Mission Builder, so the
/// card and the screen can't disagree.
struct MissionSummary {
    let origin: String
    let target: String
    let launchDate: Date
    let transfer: TransferOrbit
    let isAligned: Bool
    let travelTime: String
    let deltaV: String
    let wholeMission: String?
}

// MARK: - Card

struct MissionShareCard: View {
    let summary: MissionSummary

    static let width: CGFloat = 360

    private func date(_ d: Date) -> String {
        d.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale))
    }

    private var arrival: Date {
        summary.launchDate.addingTimeInterval(summary.transfer.travelDays * 86_400)
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("My mission to \(summary.target.localizedBodyName)")
                    .font(AppFont.bold(22))
                    .foregroundColor(.white)
                Text(verbatim: "\(summary.origin.localizedBodyName) → \(summary.target.localizedBodyName)")
                    .font(AppFont.regular(14))
                    .foregroundColor(.white.opacity(0.7))
            }

            TransferOrbitDiagram(origin: summary.origin, target: summary.target,
                                 launchDate: summary.launchDate, transfer: summary.transfer,
                                 isAligned: summary.isAligned, stillProgress: 1)

            VStack(spacing: 0) {
                row("Launch date", date(summary.launchDate))
                divider
                row("Travel time", summary.travelTime)
                divider
                row("Arrival", date(arrival))
                divider
                row("Engine burns (Δv)", summary.deltaV)
                if let whole = summary.wholeMission {
                    divider
                    row("Whole mission", whole)
                }
            }
            .appCard()

            Text("Planned with Planet")
                .font(AppFont.regular(12))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(20)
        .frame(width: Self.width)
        .background(AppGradientBackground(stars: 30))
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }

    private func row(_ title: LocalizedStringKey, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.regular(14))
                .foregroundColor(.white.opacity(0.8))
            Spacer(minLength: 8)
            Text(value)
                .font(AppFont.bold(15))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Sharing

/// Rendered only when the user actually shares, not on every slider move.
struct MissionSnapshot: Transferable {
    let summary: MissionSummary

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { snapshot in
            try await snapshot.pngData()
        }
        .suggestedFileName("Mission.png")
    }

    @MainActor
    private func render() throws -> Data {
        let renderer = ImageRenderer(content: MissionShareCard(summary: summary).appLanguageEnvironment())
        renderer.scale = 3
        guard let data = renderer.uiImage?.pngData() else { throw CocoaError(.fileWriteUnknown) }
        return data
    }

    func pngData() async throws -> Data {
        try await MainActor.run { try render() }
    }
}

#Preview {
    if let earth = PlanetMetrics.metrics(for: "Earth"),
       let mars = PlanetMetrics.metrics(for: "Mars"),
       let transfer = TransferOrbit(from: earth, to: mars) {
        MissionShareCard(summary: MissionSummary(origin: "Earth", target: "Mars", launchDate: Date(),
                                                 transfer: transfer, isAligned: true,
                                                 travelTime: "8.5 months", deltaV: "5.6 km/s",
                                                 wholeMission: "2.7 years"))
    }
}
