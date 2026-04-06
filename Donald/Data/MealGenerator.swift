//
//  MealGenerator.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation

enum LimitMode: String, CaseIterable, Codable {
    case under
    case close
    case over

    var displayName: String {
        switch self {
        case .under: String(localized: "Generator.LimitMode.Under")
        case .close: String(localized: "Generator.LimitMode.Close")
        case .over: String(localized: "Generator.LimitMode.Over")
        }
    }
}

enum MealSize: String, CaseIterable, Codable {
    case none
    case small
    case normal
    case large

    var displayName: String {
        switch self {
        case .none: String(localized: "Generator.MealSize.None")
        case .small: String(localized: "Generator.MealSize.Small")
        case .normal: String(localized: "Generator.MealSize.Normal")
        case .large: String(localized: "Generator.MealSize.Large")
        }
    }
}

struct GeneratorSettings {
    var macFrequency: Double = 15 // 0-45 percent
    var mealSizes: [MealSlot: MealSize] = [
        .breakfast: .normal,
        .lunch: .normal,
        .dinner: .normal
    ]
    var limitMode: LimitMode = .close
}

struct MealGenerator {

    let allItems: [FoodItem]
    let targets: NutritionTargets
    let settings: GeneratorSettings

    // MARK: - Scoring

    private func scoreItem(_ item: FoodItem, daySoFar: DayTotals, mealsLeft: Int) -> Double {
        let after = DayTotals(
            cal: daySoFar.cal + item.cal,
            p: daySoFar.p + item.p,
            f: daySoFar.f + item.f,
            c: daySoFar.c + item.c,
            fi: daySoFar.fi + item.fi
        )

        let baseOverMul: Double = mealsLeft <= 1 ? 4 : mealsLeft <= 2 ? 2 : 1
        let modeMul: Double = settings.limitMode == .under ? 3 : settings.limitMode == .over ? 0.3 : 1
        let overMul = baseOverMul * modeMul
        let underMul: Double = settings.limitMode == .under ? 0.3 : settings.limitMode == .over ? 1.5 : 1

        var score: Double = 0

        // Calories
        let calDiff = after.cal - targets.cal
        if calDiff > 0 { score += (calDiff / targets.cal) * 3 * overMul }
        else { score += (abs(calDiff) / targets.cal) * 0.5 * underMul }

        // Fat
        let fDiff = after.f - targets.f
        if fDiff > 0 { score += (fDiff / targets.f) * 8 * overMul }
        else { score += (abs(fDiff) / targets.f) * 0.3 * underMul }

        // Protein
        let pDiff = after.p - targets.p
        if pDiff > 0 { score += (pDiff / targets.p) * 1 * overMul }
        else { score += (abs(pDiff) / targets.p) * 1.5 * underMul }

        // Carbs
        let cDiff = after.c - targets.c
        if cDiff > 0 { score += (cDiff / targets.c) * 2 * overMul }
        else { score += (abs(cDiff) / targets.c) * 0.8 * underMul }

        // Fiber
        let fiDiff = after.fi - targets.fi
        if fiDiff > 0 { score += (fiDiff / targets.fi) * 0.3 * overMul }
        else { score += (abs(fiDiff) / targets.fi) * 2 * underMul }

        return score
    }

    // MARK: - Selection

    private func pickBest(from candidates: [FoodItem], daySoFar: DayTotals, mealsLeft: Int) -> FoodItem? {
        guard !candidates.isEmpty else { return nil }

        let maxOver: Double = settings.limitMode == .under ? 0 : settings.limitMode == .over ? 0.5 : 0.2

        var pool = candidates

        if mealsLeft <= 1 || settings.limitMode == .under {
            let filtered = candidates.filter { item in
                let after = DayTotals(
                    cal: daySoFar.cal + item.cal,
                    p: daySoFar.p + item.p,
                    f: daySoFar.f + item.f,
                    c: daySoFar.c + item.c,
                    fi: daySoFar.fi + item.fi
                )
                return after.cal <= targets.cal * (1 + maxOver) &&
                       after.p <= targets.p * (1 + maxOver) &&
                       after.f <= targets.f * (1 + maxOver) &&
                       after.c <= targets.c * (1 + maxOver) &&
                       after.fi <= targets.fi * (1 + maxOver)
            }
            if !filtered.isEmpty {
                pool = filtered
            } else if settings.limitMode == .under {
                return nil
            }
        }

        let scored = pool.map { item in
            (item: item, score: scoreItem(item, daySoFar: daySoFar, mealsLeft: mealsLeft))
        }.sorted { $0.score < $1.score }

        let topN = min(scored.count, max(3, Int(ceil(Double(scored.count) * 0.3))))
        let top = Array(scored.prefix(topN))

        let maxS = top.last!.score
        let minS = top.first!.score
        let range = maxS - minS > 0 ? maxS - minS : 1

        let weights = top.map { 1 + (maxS - $0.score) / range }
        let totalW = weights.reduce(0, +)
        var r = Double.random(in: 0..<totalW)

        for i in 0..<weights.count {
            r -= weights[i]
            if r <= 0 { return top[i].item }
        }
        return top.first?.item
    }

    private func addNutrients(_ totals: DayTotals, _ item: FoodItem) -> DayTotals {
        DayTotals(
            cal: totals.cal + item.cal,
            p: totals.p + item.p,
            f: totals.f + item.f,
            c: totals.c + item.c,
            fi: totals.fi + item.fi
        )
    }

    // MARK: - Generation

    func generateWeek() -> [[[PlannedItem]]] {
        let macPct = settings.macFrequency
        let macDays: Set<Int> = macPct > 0
            ? Set(Array(0..<7).shuffled().prefix(max(1, Int(round(7 * macPct / 100)))))
            : []

        let mcdonaldsItems = allItems.filter { $0.sourceKey == "mcdonalds" }
        let mealKeys: [MealSlot] = [.breakfast, .lunch, .dinner]

        var plan: [[[PlannedItem]]] = (0..<7).map { _ in (0..<3).map { _ in [] } }

        for d in 0..<7 {
            var used = Set<String>()
            var dayTotals = DayTotals()
            let isMac = macDays.contains(d)

            for m in 0..<3 {
                let slot = mealKeys[m]
                let sz = settings.mealSizes[slot] ?? .normal
                if sz == .none {
                    continue
                }

                let mealsLeft = mealKeys[m...].filter { (settings.mealSizes[$0] ?? .normal) != .none }.count

                var items: [FoodItem] = []

                if isMac && m == 1 {
                    // McDonald's lunch
                    let pool = mcdonaldsItems.filter {
                        ($0.meal == "any" || $0.meal.contains("lunch")) && !used.contains($0.id)
                    }
                    let burgers = pool.filter { $0.cat == "meal" }
                    let sides = pool.filter { ["veggie", "dessert"].contains($0.cat) }

                    if let burger = pickBest(from: burgers, daySoFar: dayTotals, mealsLeft: mealsLeft) {
                        if sz == .small {
                            items = [burger]
                        } else {
                            var mealTotals = addNutrients(dayTotals, burger)
                            let sidePool = sides.filter { $0.id != burger.id }
                            let side = pickBest(from: sidePool, daySoFar: mealTotals, mealsLeft: mealsLeft)
                            items = [burger, side].compactMap { $0 }
                            if sz == .large, let side {
                                mealTotals = addNutrients(mealTotals, side)
                                let extra = sides.filter { item in !items.contains(where: { $0.id == item.id }) }
                                if let ex = pickBest(from: extra, daySoFar: mealTotals, mealsLeft: mealsLeft) {
                                    items.append(ex)
                                }
                            }
                        }
                    }
                } else {
                    let pool = allItems.filter {
                        $0.sourceKey != "mcdonalds" &&
                        ($0.meal == "any" || $0.meal.contains(slot.mealKey)) &&
                        !used.contains($0.id)
                    }

                    if slot == .breakfast {
                        let mains = pool.filter { ["meal", "protein"].contains($0.cat) }
                        let sides = pool.filter { ["bread", "veggie", "soup"].contains($0.cat) }

                        let main = pickBest(from: mains, daySoFar: dayTotals, mealsLeft: mealsLeft)
                        if sz == .small {
                            items = [main].compactMap { $0 }
                        } else {
                            var mealTotals = main.map { addNutrients(dayTotals, $0) } ?? dayTotals
                            let sidePool = sides.filter { item in main.map { item.id != $0.id } ?? true }
                            let sd = pickBest(from: sidePool, daySoFar: mealTotals, mealsLeft: mealsLeft)
                            items = [main, sd].compactMap { $0 }
                            if sz == .large, let sd {
                                mealTotals = addNutrients(mealTotals, sd)
                                let extra = sides.filter { item in !items.contains(where: { $0.id == item.id }) }
                                if let ex = pickBest(from: extra, daySoFar: mealTotals, mealsLeft: mealsLeft) {
                                    items.append(ex)
                                }
                            }
                        }
                    } else {
                        // Lunch / Dinner
                        let mealPool = pool.filter { $0.cat == "meal" }
                        if let main = pickBest(from: mealPool, daySoFar: dayTotals, mealsLeft: mealsLeft) {
                            if sz == .small {
                                items = [main]
                            } else {
                                var mealTotals = addNutrients(dayTotals, main)
                                let extras = pool.filter {
                                    $0.id != main.id && ["veggie", "soup", "bread", "protein"].contains($0.cat)
                                }
                                let ex = pickBest(from: extras, daySoFar: mealTotals, mealsLeft: mealsLeft)
                                items = [main, ex].compactMap { $0 }
                                if sz == .large, let ex {
                                    mealTotals = addNutrients(mealTotals, ex)
                                    let extra2 = extras.filter { item in !items.contains(where: { $0.id == item.id }) }
                                    if let ex2 = pickBest(from: extra2, daySoFar: mealTotals, mealsLeft: mealsLeft) {
                                        items.append(ex2)
                                    }
                                }
                            }
                        }
                    }
                }

                for item in items {
                    used.insert(item.id)
                }
                plan[d][m] = items.map { PlannedItem(from: $0) }
                dayTotals = items.reduce(dayTotals) { addNutrients($0, $1) }
            }
        }

        return plan
    }
}
