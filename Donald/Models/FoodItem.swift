//
//  FoodItem.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

struct FoodItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let cal: Double
    let p: Double
    let f: Double
    let c: Double
    let fi: Double
    let cat: String
    let meal: String

    // Not in JSON, set after decoding
    var sourceKey: String = ""
    var sourceLabel: String = ""
    var sourceColor: String = ""

    enum CodingKeys: String, CodingKey {
        case id, name, cal, p, f, c, fi, cat, meal
    }
}

enum FoodCategory: String, CaseIterable {
    case meal = "meal"
    case protein = "protein"
    case veggie = "veggie"
    case soup = "soup"
    case side = "side"
    case dessert = "dessert"
    case bread = "bread"
    case drink = "drink"

    var displayName: String {
        switch self {
        case .meal: String(localized: "Category.Meal")
        case .protein: String(localized: "Category.Protein")
        case .veggie: String(localized: "Category.Veggie")
        case .soup: String(localized: "Category.Soup")
        case .side: String(localized: "Category.Side")
        case .dessert: String(localized: "Category.Dessert")
        case .bread: String(localized: "Category.Bread")
        case .drink: String(localized: "Category.Drink")
        }
    }
}
