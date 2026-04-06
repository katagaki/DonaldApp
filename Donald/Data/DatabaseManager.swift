//
//  DatabaseManager.swift
//  Donald
//
//  Created by シン・ジャスティン on 2026/04/06.
//

import Foundation
import SQLite

final class DatabaseManager {

    static let shared = DatabaseManager()

    private var db: Connection?

    // Tables
    private let sources = Table("sources")
    private let items = Table("items")

    // Source columns
    private let sourceKey = SQLite.Expression<String>("key")
    private let sourceLabel = SQLite.Expression<String>("label")
    private let sourceColor = SQLite.Expression<String>("color")

    // Item columns
    private let itemId = SQLite.Expression<String>("id")
    private let itemName = SQLite.Expression<String>("name")
    private let itemCal = SQLite.Expression<Double>("cal")
    private let itemP = SQLite.Expression<Double>("p")
    private let itemF = SQLite.Expression<Double>("f")
    private let itemC = SQLite.Expression<Double>("c")
    private let itemFi = SQLite.Expression<Double>("fi")
    private let itemCat = SQLite.Expression<String>("cat")
    private let itemMeal = SQLite.Expression<String>("meal")
    private let itemSourceKey = SQLite.Expression<String>("source_key")

    private init() {
        do {
            let dbPath = DatabaseManager.databasePath()
            db = try Connection(dbPath)
            try createTables()
        } catch {
            print("Database initialization failed: \(error)")
        }
    }

    private static func databasePath() -> String {
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.tsubuzaki.Donald"
        ) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return groupURL.appendingPathComponent("Dataset.donald").path
    }

    private func createTables() throws {
        guard let db else { return }

        try db.run(sources.create(ifNotExists: true) { t in
            t.column(sourceKey, primaryKey: true)
            t.column(sourceLabel)
            t.column(sourceColor)
        })

        try db.run(items.create(ifNotExists: true) { t in
            t.column(itemId)
            t.column(itemName)
            t.column(itemCal)
            t.column(itemP)
            t.column(itemF)
            t.column(itemC)
            t.column(itemFi)
            t.column(itemCat)
            t.column(itemMeal)
            t.column(itemSourceKey)
            t.primaryKey(itemId, itemSourceKey)
            t.foreignKey(itemSourceKey, references: sources, sourceKey, delete: .cascade)
        })
    }

    // MARK: - Source Operations

    func insertSource(_ source: DataSource) throws {
        guard let db else { return }
        try db.run(sources.insert(or: .replace,
            sourceKey <- source.key,
            sourceLabel <- source.label,
            sourceColor <- source.color
        ))
    }

    func deleteSource(key: String) throws {
        guard let db else { return }
        let query = sources.filter(sourceKey == key)
        try db.run(query.delete())
    }

    func loadedSourceKeys() throws -> Set<String> {
        guard let db else { return [] }
        var keys = Set<String>()
        for row in try db.prepare(sources.select(sourceKey)) {
            keys.insert(row[sourceKey])
        }
        return keys
    }

    // MARK: - Item Operations

    func insertItems(_ foodItems: [FoodItem], forSourceKey key: String) throws {
        guard let db else { return }
        try db.transaction {
            for item in foodItems {
                try db.run(items.insert(or: .replace,
                    itemId <- item.id,
                    itemName <- item.name,
                    itemCal <- item.cal,
                    itemP <- item.p,
                    itemF <- item.f,
                    itemC <- item.c,
                    itemFi <- item.fi,
                    itemCat <- item.cat,
                    itemMeal <- item.meal,
                    itemSourceKey <- key
                ))
            }
        }
    }

    func allItems() throws -> [FoodItem] {
        guard let db else { return [] }
        var result: [FoodItem] = []
        let query = items
            .join(sources, on: itemSourceKey == sources[sourceKey])
        for row in try db.prepare(query) {
            var item = FoodItem(
                id: row[itemId],
                name: row[itemName],
                cal: row[itemCal],
                p: row[itemP],
                f: row[itemF],
                c: row[itemC],
                fi: row[itemFi],
                cat: row[itemCat],
                meal: row[itemMeal]
            )
            item.sourceKey = row[sources[sourceKey]]
            item.sourceLabel = row[sourceLabel]
            item.sourceColor = row[sourceColor]
            result.append(item)
        }
        return result
    }

    func importDataSource(_ source: DataSource) throws {
        try insertSource(source)
        try insertItems(source.items, forSourceKey: source.key)
    }

    func items(forSourceKey key: String) throws -> [FoodItem] {
        guard let db else { return [] }
        var result: [FoodItem] = []
        let query = items
            .join(sources, on: itemSourceKey == sources[sourceKey])
            .filter(sources[sourceKey] == key)
        for row in try db.prepare(query) {
            var item = FoodItem(
                id: row[itemId],
                name: row[itemName],
                cal: row[itemCal],
                p: row[itemP],
                f: row[itemF],
                c: row[itemC],
                fi: row[itemFi],
                cat: row[itemCat],
                meal: row[itemMeal]
            )
            item.sourceKey = row[sources[sourceKey]]
            item.sourceLabel = row[sourceLabel]
            item.sourceColor = row[sourceColor]
            result.append(item)
        }
        return result
    }

    func deleteItem(id: String, sourceKey key: String) throws {
        guard let db else { return }
        let query = items.filter(itemId == id && itemSourceKey == key)
        try db.run(query.delete())
    }

    func source(forKey key: String) throws -> DataSource? {
        guard let db else { return nil }
        let query = sources.filter(sourceKey == key)
        guard let row = try db.pluck(query) else { return nil }
        let sourceItems = try items(forSourceKey: key)
        return DataSource(
            key: row[sourceKey],
            label: row[sourceLabel],
            color: row[sourceColor],
            items: sourceItems
        )
    }
}
