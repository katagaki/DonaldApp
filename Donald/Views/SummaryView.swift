//
//  SummaryView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct SummaryView: View {

    @Environment(PlanManager.self) var planManager

    var weeklyAvg: DayTotals {
        planManager.weeklyAverages()
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Summary.WeeklyAverage") {
                    MacroBar(label: String(localized: "Planner.Nutrition.Calories"),
                             current: weeklyAvg.cal, target: planManager.targets.cal, unit: "kcal",
                             color: .blue)
                    MacroBar(label: String(localized: "Planner.Nutrition.Protein"),
                             current: weeklyAvg.p, target: planManager.targets.p, unit: "g",
                             color: .green)
                    MacroBar(label: String(localized: "Planner.Nutrition.Fat"),
                             current: weeklyAvg.f, target: planManager.targets.f, unit: "g",
                             color: .orange)
                    MacroBar(label: String(localized: "Planner.Nutrition.Carbs"),
                             current: weeklyAvg.c, target: planManager.targets.c, unit: "g",
                             color: .indigo)
                    MacroBar(label: String(localized: "Planner.Nutrition.Fiber"),
                             current: weeklyAvg.fi, target: planManager.targets.fi, unit: "g",
                             color: .teal)
                }

                Section("Summary.DailyBreakdown") {
                    ForEach(DayOfWeek.allCases) { day in
                        let totals = planManager.totals(for: day)
                        let overFat = totals.f > planManager.targets.f
                        let fatRatio = planManager.targets.f > 0
                            ? min(totals.f / planManager.targets.f, 1.0) : 0

                        HStack(spacing: 8) {
                            Text(day.shortName)
                                .font(.subheadline)
                                .frame(width: 20)
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 12)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(overFat ? .red : .orange)
                                        .frame(width: geometry.size.width * fatRatio, height: 12)
                                }
                            }
                            .frame(height: 12)
                            VStack(alignment: .trailing, spacing: 0) {
                                Text("\(Int(totals.cal))kcal")
                                    .font(.caption2)
                                Text(String(format: "F%.1fg", totals.f))
                                    .font(.caption2)
                                    .foregroundStyle(overFat ? .red : .secondary)
                            }
                            .frame(minWidth: 55, alignment: .trailing)
                        }
                    }
                }

                sourceSection
            }
            .orangeGradientBackground()
            .navigationTitle("Summary.Title")
        }
    }

    @ViewBuilder
    private var sourceSection: some View {
        let sourceCounts = countSources()
        Section("Summary.SourceBreakdown") {
            if sourceCounts.isEmpty {
                Text("Summary.NoData")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sourceCounts, id: \.key) { entry in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: entry.color))
                            .frame(width: 10, height: 10)
                        Text(entry.label)
                        Spacer()
                        Text("\(entry.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func countSources() -> [(key: String, label: String, color: String, count: Int)] {
        var counts: [String: (label: String, color: String, count: Int)] = [:]
        for day in DayOfWeek.allCases {
            for meal in MealSlot.allCases {
                for item in planManager.items(for: day, meal: meal) {
                    if let existing = counts[item.sourceKey] {
                        counts[item.sourceKey] = (existing.label, existing.color, existing.count + 1)
                    } else {
                        counts[item.sourceKey] = (item.sourceLabel, item.sourceColor, 1)
                    }
                }
            }
        }
        return counts.map { (key: $0.key, label: $0.value.label, color: $0.value.color, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
}
