// DashboardView.swift
// Feature 5: Customizable planetary dashboard placeholder implementation

import SwiftUI

/// Represents a single widget that can be placed on the dashboard.
struct DashboardWidget: Identifiable {
    let id = UUID()
    let title: String
    let content: AnyView
}

/// Simple dashboard that allows the user to add predefined widgets.
/// In a full implementation this would support drag‑and‑drop layout editing and persistence via AppStorage.
struct DashboardView: View {
    @State private var widgets: [DashboardWidget] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("My Planet Dashboard")
                .font(.title2)
                .padding(.bottom, 4)
            if widgets.isEmpty {
                Text("Add widgets from the list below.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(widgets) { widget in
                    widget.content
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                        .padding(.bottom, 4)
                }
            }
            Divider()
            // Placeholder widget selection
            HStack {
                Button("Add Distance Widget") { addDistanceWidget() }
                Button("Add Rise/Set Times") { addRiseSetWidget() }
            }
        }
        .padding()
    }

    private func addDistanceWidget() {
        let view = AnyView(Text("Distance from Earth: 42 million km"))
        widgets.append(DashboardWidget(title: "Distance", content: view))
    }
    private func addRiseSetWidget() {
        let view = AnyView(Text("Rise: 06:12, Set: 18:45"))
        widgets.append(DashboardWidget(title: "Rise/Set", content: view))
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
