//
//  PlannerView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct PickerTarget: Identifiable {
    let id = UUID()
    let day: DayOfWeek
    let meal: MealSlot
}

struct PlannerView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(DatasetManager.self) var datasetManager
    @State private var selectedDay: DayOfWeek = .monday
    @State private var pickerTarget: PickerTarget?
    @State private var showingGenerator = false

    var dayTotals: DayTotals {
        planManager.totals(for: selectedDay)
    }

    var body: some View {
        NavigationStack {
            List {
                daySelector
                nutritionSection
                ForEach(MealSlot.allCases) { meal in
                    mealSection(meal)
                }
            }
            .orangeGradientBackground()
            .navigationTitle("Planner.Title")
            .sheet(item: $pickerTarget) { target in
                ItemPickerView(day: target.day, meal: target.meal)
            }
            .sheet(isPresented: $showingGenerator) {
                GeneratorView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingGenerator = true
                    } label: {
                        Label("Planner.Generate", systemImage: "wand.and.stars")
                    }
                }
            }
        }
    }

    // MARK: - Day Selector

    private var daySelector: some View {
        Section {
            Picker("Planner.Day", selection: $selectedDay) {
                ForEach(DayOfWeek.allCases) { day in
                    Text(day.shortName).tag(day)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - Nutrition Section

    private var nutritionSection: some View {
        Section("Planner.Nutrition.Title") {
            MacroBar(label: String(localized: "Planner.Nutrition.Calories"),
                     current: dayTotals.cal, target: planManager.targets.cal, unit: "kcal",
                     color: .blue)
            MacroBar(label: String(localized: "Planner.Nutrition.Protein"),
                     current: dayTotals.p, target: planManager.targets.p, unit: "g",
                     color: .green)
            MacroBar(label: String(localized: "Planner.Nutrition.Fat"),
                     current: dayTotals.f, target: planManager.targets.f, unit: "g",
                     color: .orange)
            MacroBar(label: String(localized: "Planner.Nutrition.Carbs"),
                     current: dayTotals.c, target: planManager.targets.c, unit: "g",
                     color: .indigo)
            MacroBar(label: String(localized: "Planner.Nutrition.Fiber"),
                     current: dayTotals.fi, target: planManager.targets.fi, unit: "g",
                     color: .teal)
        }
    }

    // MARK: - Meal Section

    private func mealSection(_ meal: MealSlot) -> some View {
        Section {
            let items = planManager.items(for: selectedDay, meal: meal)
            if items.isEmpty {
                Button {
                    pickerTarget = PickerTarget(day: selectedDay, meal: meal)
                } label: {
                    Text("Planner.EmptySlot")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color(hex: item.sourceColor))
                            .frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.body)
                            HStack(spacing: 6) {
                                Text("\(Int(item.cal))kcal")
                                Text("P\(String(format: "%.1f", item.p))g")
                                Text("F\(String(format: "%.1f", item.f))g")
                                Text("C\(String(format: "%.1f", item.c))g")
                            }
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            planManager.removeItem(day: selectedDay, meal: meal, at: index)
                        } label: {
                            Label("Shared.Delete", systemImage: "trash")
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text(meal.displayName)
                Spacer()
                Button {
                    pickerTarget = PickerTarget(day: selectedDay, meal: meal)
                } label: {
                    Label("Planner.AddItem", systemImage: "plus")
                        .font(.subheadline)
                }
            }
        }
    }
}

// MARK: - Macro Bar

struct MacroBar: View {
    let label: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color

    var ratio: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var isOver: Bool {
        current > target
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(current))/\(Int(target))\(unit)")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(isOver ? .red : .secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isOver ? .red : color)
                        .frame(width: geometry.size.width * ratio, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
