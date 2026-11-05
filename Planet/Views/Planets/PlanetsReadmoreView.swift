//
//  PlanetDetailInfoView.swift
//  Planet
//
//  Created by itkhld on 2024-10-04.
//

import SwiftUI

struct PlanetsReadmoreView: View {

    let planetName: String
    /// Overrides the header image when the asset isn't named after the subject
    /// (the solar system artwork is catalogued as "solar system", lowercased).
    var imageName: String?

    private var headerImageName: String { imageName ?? planetName }

    private var blocks: [InfoBlock] {
        InfoBlock.parse(PlanetDetails.getDescription(for: planetName))
    }

    /// True when the asset catalog has an image matching the planet/star name.
    private var hasImage: Bool {
        UIImage(named: headerImageName) != nil
    }

    var body: some View {
        ZStack {
            Color("ReadMore")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    ForEach(blocks) { block in
                        blockView(block)
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .foregroundColor(Color("ReadMoreFontColor"))
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            if hasImage {
                Image(headerImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 150)
                    .shadow(radius: 10)
            }
            Text(planetName.localizedBodyName)
                .font(AppFont.bold(34))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Block rendering

    @ViewBuilder
    private func blockView(_ block: InfoBlock) -> some View {
        switch block.kind {
        case .header:
            VStack(alignment: .leading, spacing: 6) {
                Text(block.text)
                    .font(AppFont.bold(20))
                Divider()
                    .overlay(Color("ReadMoreFontColor").opacity(0.3))
            }
            .padding(.top, 10)

        case .paragraph:
            Text(block.text)
                .font(AppFont.regular(16))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)

        case .bullet:
            HStack(alignment: .top, spacing: 10) {
                Text("•")
                    .font(AppFont.bold(16))
                    .opacity(0.7)
                bulletText(block.text)
                    .font(AppFont.regular(15))
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    /// Renders a bullet, bolding the "Label:" prefix when present
    /// (e.g. "Type: Terrestrial planet").
    private func bulletText(_ text: String) -> Text {
        if let range = text.range(of: ": ") {
            let label = String(text[..<range.lowerBound])
            let value = String(text[range.upperBound...])
            // Only treat short prefixes as labels, not full sentences.
            if !label.contains(" ") || label.count <= 28 {
                return Text("\(Text(label + ":").bold()) \(value)")
            }
        }
        return Text(text)
    }
}

/// A single renderable piece of a planet description.
struct InfoBlock: Identifiable {
    enum Kind { case header, paragraph, bullet }
    let id = UUID()
    let kind: Kind
    let text: String

    /// Parses the raw multi-line description into headers, paragraphs and bullets.
    static func parse(_ raw: String) -> [InfoBlock] {
        raw
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { line in
                if line.hasPrefix("- ") {
                    return InfoBlock(kind: .bullet, text: String(line.dropFirst(2)))
                } else if line.hasSuffix(":") && line.count < 60 {
                    return InfoBlock(kind: .header, text: String(line.dropLast()))
                } else {
                    return InfoBlock(kind: .paragraph, text: line)
                }
            }
    }
}

#Preview {
    PlanetsReadmoreView(planetName: "Earth")
}
