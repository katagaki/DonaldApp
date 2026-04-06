//
//  ItemPickerView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct ItemPickerView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(DatasetManager.self) var datasetManager
    @Environment(\.dismiss) var dismiss

    let day: DayOfWeek
    let meal: MealSlot

    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?

    var filteredItems: [FoodItem] {
        var result = datasetManager.allItems

        result = result.filter { item in
            item.meal == "any" ||
            item.meal.contains(meal.mealKey) ||
            item.meal.contains(",")
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.sourceLabel.lowercased().contains(query)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.cat == category.rawValue }
        }

        result.sort { $0.f < $1.f }

        return result
    }

    var filterLabel: String {
        selectedCategory?.displayName ?? String(localized: "Data.Filter.All")
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems) { item in
                    Button {
                        planManager.addItem(item, day: day, meal: meal)
                        dismiss()
                    } label: {
                        PickerItemRow(item: item)
                    }
                    .tint(.primary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Picker.Title")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Data.Search.Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.fixed, placement: .bottomBar)
                ToolbarItemGroup(placement: .bottomBar) {
                    Menu {
                        Button {
                            selectedCategory = nil
                        } label: {
                            if selectedCategory == nil {
                                Label("Data.Filter.All", systemImage: "checkmark")
                            } else {
                                Text("Data.Filter.All")
                            }
                        }
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                if selectedCategory == category {
                                    Label(category.displayName, systemImage: "checkmark")
                                } else {
                                    Text(category.displayName)
                                }
                            }
                        }
                    } label: {
                        Label(filterLabel, systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
        }
    }
}

struct PickerItemRow: View {
    let item: FoodItem

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                HStack(spacing: 6) {
                    Text("\(Int(item.cal))kcal")
                    Text("P\(String(format: "%.1f", item.p))g")
                    Text("F\(String(format: "%.1f", item.f))g")
                    Text("C\(String(format: "%.1f", item.c))g")
                    Text("Fi\(String(format: "%.1f", item.fi))g")
                }
                .font(.caption)
                .monospacedDigit()
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text(String(format: "%.1fg", item.f))
                .font(.caption)
                .monospacedDigit()
                .fontWeight(.semibold)
                .foregroundStyle(fatColor(item.f))
        }
    }

    func fatColor(_ fat: Double) -> Color {
        if fat <= 10 { return .green }
        if fat <= 15 { return .orange }
        return .red
    }
}
