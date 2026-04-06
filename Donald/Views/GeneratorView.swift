//
//  GeneratorView.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import SwiftUI

struct GeneratorView: View {

    @Environment(PlanManager.self) var planManager
    @Environment(DatasetManager.self) var datasetManager
    @Environment(\.dismiss) var dismiss

    @State private var mealSizes: [MealSlot: MealSize] = [
        .breakfast: .normal,
        .lunch: .normal,
        .dinner: .normal
    ]
    @State private var limitMode: LimitMode = .close
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            List {
                if datasetManager.allItems.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "Data.Empty.Title",
                            systemImage: "tray",
                            description: Text("Data.Empty.Description")
                        )
                    }
                } else {
                    Section("Generator.MealSizes") {
                        ForEach(MealSlot.allCases) { meal in
                            HStack {
                                Text(meal.displayName)
                                Spacer()
                                Picker(meal.displayName, selection: Binding(
                                    get: { mealSizes[meal] ?? .normal },
                                    set: { mealSizes[meal] = $0 }
                                )) {
                                    ForEach(MealSize.allCases, id: \.self) { size in
                                        Text(size.displayName).tag(size)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 240)
                            }
                        }
                    }

                    Section("Generator.LimitMode") {
                        Picker("Generator.LimitMode", selection: $limitMode) {
                            ForEach(LimitMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .orangeGradientBackground()
            .navigationTitle("Generator.Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Generator.Clear", role: .destructive) {
                        planManager.clearAll()
                        dismiss()
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        generate()
                    } label: {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Label("Generator.Generate", systemImage: "wand.and.stars")
                        }
                    }
                    .disabled(isGenerating || datasetManager.allItems.isEmpty)
                }
            }
        }
    }

    func generate() {
        isGenerating = true
        let generator = MealGenerator(
            allItems: datasetManager.allItems,
            targets: planManager.targets,
            settings: GeneratorSettings(
                macFrequency: 0,
                mealSizes: mealSizes,
                limitMode: limitMode
            )
        )
        Task.detached {
            let result = generator.generateWeek()
            await MainActor.run {
                planManager.plan = result
                isGenerating = false
                dismiss()
            }
        }
    }
}
