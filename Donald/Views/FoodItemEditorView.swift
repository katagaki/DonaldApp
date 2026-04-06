//
//  FoodItemEditorView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct FoodItemEditorView: View {

    @Environment(\.dismiss) var dismiss

    let onSave: (FoodItem) -> Void

    @State private var name: String = ""
    @State private var cal: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var carbs: String = ""
    @State private var fiber: String = ""
    @State private var category: FoodCategory = .meal
    @State private var mealType: String = "any"

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("FoodItemEditor.Name") {
                    TextField("FoodItemEditor.Name.Placeholder", text: $name)
                }

                Section("FoodItemEditor.Nutrition") {
                    HStack {
                        Text("FoodItemEditor.Calories")
                        Spacer()
                        TextField("0", text: $cal)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("kcal")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("FoodItemEditor.Protein")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("FoodItemEditor.Fat")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("FoodItemEditor.Carbs")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("FoodItemEditor.Fiber")
                        Spacer()
                        TextField("0", text: $fiber)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("FoodItemEditor.Category") {
                    Picker("FoodItemEditor.Category", selection: $category) {
                        ForEach(FoodCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                }

                Section("FoodItemEditor.MealType") {
                    Picker("FoodItemEditor.MealType", selection: $mealType) {
                        Text("FoodItemEditor.MealType.Any").tag("any")
                        Text("Meal.Breakfast").tag("breakfast")
                        Text("Meal.Lunch").tag("lunch")
                        Text("Meal.Dinner").tag("dinner")
                    }
                }
            }
            .orangeGradientBackground()
            .navigationTitle("FoodItemEditor.Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Shared.Save") {
                        let item = FoodItem(
                            id: UUID().uuidString,
                            name: name.trimmingCharacters(in: .whitespaces),
                            cal: Double(cal) ?? 0,
                            p: Double(protein) ?? 0,
                            f: Double(fat) ?? 0,
                            c: Double(carbs) ?? 0,
                            fi: Double(fiber) ?? 0,
                            cat: category.rawValue,
                            meal: mealType
                        )
                        onSave(item)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}
