//
//  MoreView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct MoreView: View {

    @Environment(PlanManager.self) var planManager

    var body: some View {
        @Bindable var planManager = planManager
        NavigationStack {
            List {
                Section("Settings.Targets") {
                    TargetRow(label: String(localized: "Planner.Nutrition.Calories"),
                              value: $planManager.targets.cal, step: 50, unit: "kcal")
                    TargetRow(label: String(localized: "Planner.Nutrition.Protein"),
                              value: $planManager.targets.p, step: 5, unit: "g")
                    TargetRow(label: String(localized: "Planner.Nutrition.Fat"),
                              value: $planManager.targets.f, step: 5, unit: "g")
                    TargetRow(label: String(localized: "Planner.Nutrition.Carbs"),
                              value: $planManager.targets.c, step: 10, unit: "g")
                    TargetRow(label: String(localized: "Planner.Nutrition.Fiber"),
                              value: $planManager.targets.fi, step: 1, unit: "g")
                    Button("Settings.ResetDefaults", role: .destructive) {
                        planManager.targets = NutritionTargets()
                        planManager.saveTargets()
                    }
                }

                Section {
                    Link(destination: URL(string: "https://github.com/katagaki/DonaldApp")!) {
                        HStack {
                            Text(String(localized: "More.GitHub"))
                            Spacer()
                            Text("katagaki/DonaldApp")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)
                    NavigationLink("More.Attributions", value: ViewPath.moreLicenses)
                }
            }
            .orangeGradientBackground()
            .navigationTitle("More.Title")
            .navigationDestination(for: ViewPath.self) { path in
                switch path {
                case .moreLicenses:
                    AttributesView()
                }
            }
            .onChange(of: planManager.targets) {
                planManager.saveTargets()
            }
        }
    }
}
struct AttributesView: View {

    var body: some View {
        List {
            ForEach(Dependency.all) { dependency in
                Section {
                    Text(dependency.licenseText)
                        .font(.caption)
                        .monospaced()
                        .listRowBackground(Color.clear)
                } header: {
                    Text(dependency.name)
                }
            }
        }
        .listStyle(.grouped)
        .orangeGradientBackground()
        .navigationTitle(String(localized: "More.Attribution"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Dependency: Identifiable {
    let id: String
    let name: String
    let license: String
    let licenseText: String

    static let all: [Dependency] = [
        Dependency(
            id: "sqlite-swift",
            name: "SQLite.swift",
            license: "MIT License",
            licenseText: """
            (The MIT License)

            Copyright (c) 2014-2015 Stephen Celis <stephen@stephencelis.com>

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.
            """
        )
    ]
}
