//
//  DataView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct DataView: View {

    @Environment(DatasetManager.self) var datasetManager
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory?
    @State private var sortOrder: SortOrder = .name

    enum SortOrder: String, CaseIterable {
        case name
        case calAsc
        case calDesc
        case fatAsc
        case fatDesc

        var localizationKey: LocalizedStringKey {
            switch self {
            case .name: "Data.Sort.Name"
            case .calAsc: "Data.Sort.CaloriesAsc"
            case .calDesc: "Data.Sort.CaloriesDesc"
            case .fatAsc: "Data.Sort.FatAsc"
            case .fatDesc: "Data.Sort.FatDesc"
            }
        }
    }

    var filteredItems: [FoodItem] {
        var result = datasetManager.allItems

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.sourceLabel.lowercased().contains(query) ||
                (FoodCategory(rawValue: $0.cat)?.displayName.lowercased().contains(query) ?? false)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.cat == category.rawValue }
        }

        switch sortOrder {
        case .name: result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .calAsc: result.sort { $0.cal < $1.cal }
        case .calDesc: result.sort { $0.cal > $1.cal }
        case .fatAsc: result.sort { $0.f < $1.f }
        case .fatDesc: result.sort { $0.f > $1.f }
        }

        return result
    }

    var filterLabel: String {
        selectedCategory?.displayName ?? String(localized: "Data.Filter.All")
    }

    var body: some View {
        NavigationStack {
            List {
                if datasetManager.allItems.isEmpty {
                    ContentUnavailableView(
                        "Data.Empty.Title",
                        systemImage: "tray",
                        description: Text("Data.Empty.Description")
                    )
                } else {
                    Section {
                        ForEach(filteredItems) { item in
                            FoodItemRow(item: item)
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        Text("Data.Count \(filteredItems.count)")
                    }
                }
            }
            .listStyle(.plain)
            .orangeGradientBackground()
            .navigationTitle("Data.Title")
            .searchable(text: $searchText, prompt: "Data.Search.Prompt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Button {
                                sortOrder = order
                            } label: {
                                if sortOrder == order {
                                    Label(order.localizationKey, systemImage: "checkmark")
                                } else {
                                    Text(order.localizationKey)
                                }
                            }
                        }
                    } label: {
                        Label("Data.Sort.Label", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FoodItemRow: View {
    let item: FoodItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: item.sourceColor))
                    .frame(width: 8, height: 8)
                Text(item.sourceLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                if let category = FoodCategory(rawValue: item.cat) {
                    Text(category.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
            Text(item.name)
                .font(.body)
            HStack(spacing: 12) {
                NutrientLabel(label: String(localized: "Data.Nutrient.Calories"),
                              value: "\(Int(item.cal))", unit: "kcal")
                NutrientLabel(label: "P", value: String(format: "%.1f", item.p), unit: "g")
                NutrientLabel(label: "F", value: String(format: "%.1f", item.f), unit: "g",
                              color: fatColor(item.f))
                NutrientLabel(label: "C", value: String(format: "%.1f", item.c), unit: "g")
                NutrientLabel(label: "Fi", value: String(format: "%.1f", item.fi), unit: "g")
            }
            .font(.caption)
            .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    func fatColor(_ fat: Double) -> Color {
        if fat <= 10 { return .green }
        if fat <= 15 { return .orange }
        return .red
    }
}

struct NutrientLabel: View {
    let label: String
    let value: String
    let unit: String
    var color: Color = .secondary

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .foregroundStyle(.tertiary)
            Text("\(value)\(unit)")
                .foregroundStyle(color)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
