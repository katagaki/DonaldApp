//
//  MealPlan.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

enum DayOfWeek: Int, CaseIterable, Codable, Identifiable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .monday: String(localized: "Day.Monday")
        case .tuesday: String(localized: "Day.Tuesday")
        case .wednesday: String(localized: "Day.Wednesday")
        case .thursday: String(localized: "Day.Thursday")
        case .friday: String(localized: "Day.Friday")
        case .saturday: String(localized: "Day.Saturday")
        case .sunday: String(localized: "Day.Sunday")
        }
    }

    var mealKey: String {
        switch self {
        case .monday: "breakfast"
        case .tuesday: "breakfast"
        case .wednesday: "breakfast"
        case .thursday: "breakfast"
        case .friday: "breakfast"
        case .saturday: "any"
        case .sunday: "any"
        }
    }
}

enum MealSlot: Int, CaseIterable, Codable, Identifiable {
    case breakfast = 0, lunch, dinner

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: String(localized: "Meal.Breakfast")
        case .lunch: String(localized: "Meal.Lunch")
        case .dinner: String(localized: "Meal.Dinner")
        }
    }

    var mealKey: String {
        switch self {
        case .breakfast: "breakfast"
        case .lunch: "lunch"
        case .dinner: "dinner"
        }
    }
}

struct PlannedItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let cal: Double
    let p: Double
    let f: Double
    let c: Double
    let fi: Double
    let sourceKey: String
    let sourceLabel: String
    let sourceColor: String

    init(from foodItem: FoodItem) {
        self.id = foodItem.id
        self.name = foodItem.name
        self.cal = foodItem.cal
        self.p = foodItem.p
        self.f = foodItem.f
        self.c = foodItem.c
        self.fi = foodItem.fi
        self.sourceKey = foodItem.sourceKey
        self.sourceLabel = foodItem.sourceLabel
        self.sourceColor = foodItem.sourceColor
    }
}

struct NutritionTargets: Codable, Equatable {
    var cal: Double = 1800
    var p: Double = 60
    var f: Double = 40
    var c: Double = 250
    var fi: Double = 18
}

struct DayTotals {
    var cal: Double = 0
    var p: Double = 0
    var f: Double = 0
    var c: Double = 0
    var fi: Double = 0
}
