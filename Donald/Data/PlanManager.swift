//
//  PlanManager.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

@Observable
final class PlanManager {

    // plan[day][meal] = [PlannedItem]
    var plan: [[[PlannedItem]]] = DayOfWeek.allCases.map { _ in
        MealSlot.allCases.map { _ in [] }
    }
    var targets = NutritionTargets()

    private let planKey = "donaldapp_plan"
    private let targetsKey = "donaldapp_targets"

    init() {
        load()
    }

    // MARK: - Plan Operations

    func addItem(_ item: FoodItem, day: DayOfWeek, meal: MealSlot) {
        plan[day.rawValue][meal.rawValue].append(PlannedItem(from: item))
        save()
    }

    func removeItem(day: DayOfWeek, meal: MealSlot, at index: Int) {
        plan[day.rawValue][meal.rawValue].remove(at: index)
        save()
    }

    func clearDay(_ day: DayOfWeek) {
        for meal in MealSlot.allCases {
            plan[day.rawValue][meal.rawValue].removeAll()
        }
        save()
    }

    func clearAll() {
        plan = DayOfWeek.allCases.map { _ in
            MealSlot.allCases.map { _ in [] }
        }
        save()
    }

    func items(for day: DayOfWeek, meal: MealSlot) -> [PlannedItem] {
        plan[day.rawValue][meal.rawValue]
    }

    // MARK: - Nutrition

    func totals(for day: DayOfWeek) -> DayTotals {
        var result = DayTotals()
        for meal in MealSlot.allCases {
            for item in plan[day.rawValue][meal.rawValue] {
                result.cal += item.cal
                result.p += item.p
                result.f += item.f
                result.c += item.c
                result.fi += item.fi
            }
        }
        return result
    }

    func weeklyAverages() -> DayTotals {
        var total = DayTotals()
        var daysWithFood = 0
        for day in DayOfWeek.allCases {
            let dayTotal = totals(for: day)
            if dayTotal.cal > 0 {
                total.cal += dayTotal.cal
                total.p += dayTotal.p
                total.f += dayTotal.f
                total.c += dayTotal.c
                total.fi += dayTotal.fi
                daysWithFood += 1
            }
        }
        guard daysWithFood > 0 else { return total }
        total.cal /= Double(daysWithFood)
        total.p /= Double(daysWithFood)
        total.f /= Double(daysWithFood)
        total.c /= Double(daysWithFood)
        total.fi /= Double(daysWithFood)
        return total
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(data, forKey: planKey)
        }
        if let data = try? JSONEncoder().encode(targets) {
            UserDefaults.standard.set(data, forKey: targetsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: planKey),
           let decoded = try? JSONDecoder().decode([[[PlannedItem]]].self, from: data) {
            plan = decoded
        }
        if let data = UserDefaults.standard.data(forKey: targetsKey),
           let decoded = try? JSONDecoder().decode(NutritionTargets.self, from: data) {
            targets = decoded
        }
    }

    func saveTargets() {
        save()
    }
}
