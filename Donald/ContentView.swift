//
//  ContentView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Tab.Planner", systemImage: "calendar", value: 0) {
                PlannerView()
            }
            .customizationID("planner")

            Tab("Tab.Summary", systemImage: "chart.bar", value: 1) {
                SummaryView()
            }
            .customizationID("summary")

            Tab("Tab.Data", systemImage: "list.bullet", value: 2, role: .search) {
                DataView()
            }
            .customizationID("data")

            Tab("Tab.Datasets", systemImage: "cylinder", value: 3) {
                DatasetsView()
            }
            .customizationID("datasets")

            Tab("Tab.More", systemImage: "ellipsis", value: 4) {
                MoreView()
            }
            .customizationID("more")
        }
        .tabViewStyle(.tabBarOnly)
    }
}

#Preview {
    ContentView()
        .environment(DatasetManager())
        .environment(PlanManager())
}
